import express from 'express';
import cors from 'cors';
import { config } from './config.js';
import { dbService } from './services/db.service.js';
import { weatherService } from './services/weather.service.js';
import { sensorService } from './services/sensor.service.js';
import { geminiService } from './services/gemini.service.js';

const app = express();

app.use(cors());
app.use(express.json({ limit: '10mb' })); // support image base64 posts

// Store ongoing background intervals
let telemetryIntervalId = null;
let auditIntervalId = null;

// Audit sensors against thresholds and save notifications
function auditThresholdsAndNotify(telemetry) {
  const settings = dbService.getNotificationSettings();
  const unreadNotifications = dbService.getNotifications().filter(n => !n.read);
  
  for (const [zone, sensors] of Object.entries(telemetry)) {
    // Moisture Min
    if (sensors.soilMoisture < settings.moistureThresholdMin) {
      const type = `moisture_low_${zone}`;
      if (!unreadNotifications.some(n => n.type === type)) {
        dbService.saveNotification({
          zone,
          type,
          level: 'warning',
          message: `Soil moisture in ${zone} (${sensors.cropName}) is critical: ${sensors.soilMoisture}% (Threshold: <${settings.moistureThresholdMin}%)`
        });
      }
    }
    
    // Moisture Max
    if (sensors.soilMoisture > settings.moistureThresholdMax) {
      const type = `moisture_high_${zone}`;
      if (!unreadNotifications.some(n => n.type === type)) {
        dbService.saveNotification({
          zone,
          type,
          level: 'warning',
          message: `Excess soil moisture in ${zone} (${sensors.cropName}): ${sensors.soilMoisture}% (Threshold: >${settings.moistureThresholdMax}%)`
        });
      }
    }

    // Temperature Max
    if (sensors.temperature > settings.tempThresholdMax) {
      const type = `temp_high_${zone}`;
      if (!unreadNotifications.some(n => n.type === type)) {
        dbService.saveNotification({
          zone,
          type,
          level: 'warning',
          message: `High temperature in ${zone} (${sensors.cropName}): ${sensors.temperature}°C (Threshold: >${settings.tempThresholdMax}°C)`
        });
      }
    }

    // Temperature Min
    if (sensors.temperature < settings.tempThresholdMin) {
      const type = `temp_low_${zone}`;
      if (!unreadNotifications.some(n => n.type === type)) {
        dbService.saveNotification({
          zone,
          type,
          level: 'warning',
          message: `Low temperature in ${zone} (${sensors.cropName}): ${sensors.temperature}°C (Threshold: <${settings.tempThresholdMin}°C)`
        });
      }
    }
    
    // Nitrogen Low
    if (sensors.nitrogen < settings.npkThresholdN) {
      const type = `nitrogen_low_${zone}`;
      if (!unreadNotifications.some(n => n.type === type)) {
        dbService.saveNotification({
          zone,
          type,
          level: 'warning',
          message: `Low Nitrogen (NPK) in ${zone} (${sensors.cropName}): N=${sensors.nitrogen} mg/kg (Threshold: <${settings.npkThresholdN} mg/kg)`
        });
      }
    }
  }
}

// Helper to launch drone mission autonomously
async function triggerAutonomousDrone(zone, reasoning) {
  const currentSensors = sensorService.getSensors();
  const zoneInfo = currentSensors[zone];
  
  if (!zoneInfo) return;

  // Check if there is already an active/pending flight for this zone to avoid duplicates
  const activeMissions = dbService.getDroneMissions().filter(m => 
    (m.status === 'pending' || m.status === 'launching' || m.status === 'active') && m.zone === zone
  );
  
  if (activeMissions.length > 0) {
    return; // Already inspecting
  }

  dbService.saveLog({
    level: 'critical',
    source: 'GeminiDecisionEngine',
    message: `AUTONOMOUS INITIATIVE: Gemini triggered drone launch for ${zone} (${zoneInfo.cropName}). Reasoning: ${reasoning}`
  });

  dbService.saveDroneMission({
    zone,
    cropName: zoneInfo.cropName,
    status: 'launching',
    reason: reasoning,
    triggerType: 'autonomous',
    battery: 100
  });
}

// ----------------------------------------------------
// API ROUTES
// ----------------------------------------------------

// Weather Endpoint
app.get('/api/weather', (req, res) => {
  res.json({
    current: weatherService.getCurrentWeather(),
    forecast: weatherService.getWeatherForecast()
  });
});

app.post('/api/weather/event', (req, res) => {
  const { event } = req.body;
  const newWeather = weatherService.triggerWeatherEvent(event);
  
  // Notify weather event
  dbService.saveNotification({
    zone: 'All Zones',
    type: `weather_${event}`,
    level: event === 'normal' ? 'info' : 'critical',
    message: event === 'normal' ? 'Weather conditions stabilized.' : `Severe weather event active: ${event.replace('_', ' ').toUpperCase()}`
  });

  // Immediately update sensors to reflect weather change
  const currentTelemetry = sensorService.simulateTelemetryTick();
  auditThresholdsAndNotify(currentTelemetry);
  
  res.json({ success: true, weather: newWeather });
});

// Sensors Endpoint
app.get('/api/sensors', (req, res) => {
  res.json(sensorService.getSensors());
});

app.get('/api/sensors/history', (req, res) => {
  const limit = req.query.limit ? parseInt(req.query.limit) : 50;
  res.json(dbService.getTelemetryHistory(limit));
});

app.post('/api/sensors/anomaly', (req, res) => {
  const { zone, anomaly } = req.body;
  const updatedSensors = sensorService.triggerAnomaly(zone, anomaly);
  
  if (!updatedSensors) {
    return res.status(400).json({ error: 'Invalid zone specified' });
  }

  // Force an immediate audit if anomaly is triggered to speed up drone response
  if (anomaly !== 'clear') {
    setTimeout(async () => {
      const weather = weatherService.getCurrentWeather();
      const currentTelemetry = sensorService.getSensors();
      const audit = await geminiService.auditTelemetry(currentTelemetry, weather);
      if (audit.droneLaunchRequired && audit.targetZone) {
        await triggerAutonomousDrone(audit.targetZone, audit.reasoning);
      }
    }, 500);
  }

  res.json({ success: true, sensors: updatedSensors });
});

// Drone Missions Endpoint
app.get('/api/drone/missions', (req, res) => {
  const limit = req.query.limit ? parseInt(req.query.limit) : 20;
  res.json(dbService.getDroneMissions(limit));
});

// Manual Drone Launch Request
app.post('/api/drone/launch', (req, res) => {
  const { zone, reason } = req.body;
  const currentSensors = sensorService.getSensors();
  const zoneInfo = currentSensors[zone];

  if (!zoneInfo) {
    return res.status(400).json({ error: 'Invalid zone specified' });
  }

  const mission = dbService.saveDroneMission({
    zone,
    cropName: zoneInfo.cropName,
    status: 'launching',
    reason: reason || 'Manual command operator survey',
    triggerType: 'manual',
    battery: 100
  });

  res.json({ success: true, mission });
});

// Update mission status (e.g. from launching -> active -> completed)
app.put('/api/drone/mission/:id', (req, res) => {
  const { id } = req.params;
  const { status, battery, flightPath, capturedImages } = req.body;
  
  const updated = dbService.updateDroneMission(id, { status, battery, flightPath, capturedImages });
  if (!updated) {
    return res.status(404).json({ error: 'Mission not found' });
  }
  res.json({ success: true, mission: updated });
});

// Complete Drone Mission & Analyze Image using Gemini
app.post('/api/drone/mission/:id/complete', async (req, res) => {
  const { id } = req.params;
  const { imageBase64, activeAnomaly } = req.body;
  
  const missions = dbService.getDroneMissions();
  const mission = missions.find(m => m.id === id);
  
  if (!mission) {
    return res.status(404).json({ error: 'Mission not found' });
  }

  // Set to scanning state
  dbService.updateDroneMission(id, { status: 'scanning' });
  
  try {
    const currentSensors = sensorService.getSensors();
    const zoneTelemetry = currentSensors[mission.zone] || {};
    
    // Call Gemini to analyze the image
    const diagnosis = await geminiService.analyzeDroneImage(
      imageBase64,
      mission.zone,
      mission.cropName,
      zoneTelemetry,
      activeAnomaly
    );

    // Save diagnosis to mission
    const updatedMission = dbService.updateDroneMission(id, {
      status: 'completed',
      battery: mission.battery - 35, // flight cost
      diagnostics: diagnosis
    });

    dbService.saveNotification({
      zone: mission.zone,
      type: `drone_scan_${id}`,
      level: diagnosis.severity === 'critical' ? 'critical' : diagnosis.severity === 'warning' ? 'warning' : 'info',
      message: `Drone sweep completed for ${mission.zone} (${mission.cropName}). Diagnosis: ${diagnosis.issueDetected}.`
    });

    // Save recommendations generated by Gemini
    if (diagnosis.issueDetected !== 'None') {
      dbService.saveRecommendation({
        zone: mission.zone,
        cropName: mission.cropName,
        title: diagnosis.issueDetected,
        description: diagnosis.findings,
        severity: diagnosis.severity,
        recommendations: diagnosis.recommendations,
        missionId: id
      });
    }

    res.json({ success: true, mission: updatedMission });
  } catch (error) {
    console.error('Error conducting image scan audit:', error);
    res.status(500).json({ error: 'Failed to process crop scan image' });
  }
});

// Recommendations Endpoint
app.get('/api/recommendations', (req, res) => {
  res.json(dbService.getRecommendations());
});

app.post('/api/recommendations/:id/resolve', (req, res) => {
  const { id } = req.params;
  const resolved = dbService.resolveRecommendation(id);
  
  if (!resolved) {
    return res.status(404).json({ error: 'Recommendation not found' });
  }
  
  // Clear the corresponding anomaly on the sensor as it's been resolved
  sensorService.triggerAnomaly(resolved.zone, 'clear');

  res.json({ success: true, recommendation: resolved });
});

// Logs Endpoint
app.get('/api/logs', (req, res) => {
  res.json(dbService.getLogs());
});

// Consult Gemini Agent Chat
app.post('/api/consult', async (req, res) => {
  const { message, history } = req.body;
  if (!message) {
    return res.status(400).json({ error: 'Message content is required' });
  }

  try {
    const aiResponse = await geminiService.consultFarmAI(message, history);
    res.json({ response: aiResponse });
  } catch (error) {
    res.status(500).json({ error: 'Agent failed to resolve consultation query' });
  }
});

// Reset database
app.post('/api/reset', (req, res) => {
  dbService.clearAll();
  res.json({ success: true, message: 'Database reset successfully' });
});

// Generate Farm Report
app.post('/api/reports/generate', async (req, res) => {
  try {
    const history = dbService.getTelemetryHistory(50);
    const recommendations = dbService.getRecommendations();
    const weather = weatherService.getCurrentWeather();
    
    const reportText = await geminiService.generateReport(history, recommendations, weather);
    
    dbService.saveLog({
      level: 'info',
      source: 'ReportsEngine',
      message: 'Generated comprehensive AI agricultural health analysis report.'
    });

    res.json({ success: true, report: reportText });
  } catch (error) {
    console.error('Error generating AI report:', error);
    res.status(500).json({ error: 'Failed to generate AI report' });
  }
});

// Notifications
app.get('/api/notifications', (req, res) => {
  res.json(dbService.getNotifications());
});

app.post('/api/notifications/read', (req, res) => {
  const { id, all } = req.body;
  if (all) {
    dbService.markAllNotificationsRead();
    return res.json({ success: true });
  }
  const updated = dbService.markNotificationRead(id);
  if (!updated) {
    return res.status(404).json({ error: 'Notification not found' });
  }
  res.json({ success: true, notification: updated });
});

// Settings Thresholds
app.get('/api/notifications/settings', (req, res) => {
  res.json(dbService.getNotificationSettings());
});

app.post('/api/notifications/settings', (req, res) => {
  const updated = dbService.updateNotificationSettings(req.body);
  res.json({ success: true, settings: updated });
});

// Start background loops
function startSimulationLoops() {
  // Every 8 seconds: tick weather and telemetry
  telemetryIntervalId = setInterval(() => {
    weatherService.updateWeatherSimulation();
    const currentTelemetry = sensorService.simulateTelemetryTick();
    auditThresholdsAndNotify(currentTelemetry);
  }, 8000);

  // Every 25 seconds: Audit sensors using Gemini to decide if we should launch drone autonomously
  auditIntervalId = setInterval(async () => {
    const weather = weatherService.getCurrentWeather();
    const currentTelemetry = sensorService.getSensors();
    
    dbService.saveLog({
      level: 'info',
      source: 'GeminiDecisionEngine',
      message: 'Running scheduled AI telemetry audit...'
    });

    const audit = await geminiService.auditTelemetry(currentTelemetry, weather);
    
    // Save Gemini alerts to Recommendations if not duplicate
    if (audit.alerts && audit.alerts.length > 0) {
      const activeRecs = dbService.getRecommendations().filter(r => !r.resolved);
      for (const alert of audit.alerts) {
        if (!activeRecs.some(r => r.title === alert.title)) {
          // Identify zone based on title parsing or select a default/parsed field
          let matchedZone = 'Zone A';
          for (const zone of ['Zone A', 'Zone B', 'Zone C', 'Zone D']) {
            if (alert.title.includes(zone) || alert.description.includes(zone)) {
              matchedZone = zone;
            }
          }
          const currentSensors = sensorService.getSensors();
          dbService.saveRecommendation({
            zone: matchedZone,
            cropName: currentSensors[matchedZone]?.cropName || 'Farm',
            title: alert.title,
            description: alert.description,
            severity: alert.severity || 'medium',
            recommendations: ['Check soil parameters.', 'Monitor zone telemetry charts closely.'],
            missionId: null
          });
        }
      }
    }

    if (audit.droneLaunchRequired && audit.targetZone) {
      await triggerAutonomousDrone(audit.targetZone, audit.reasoning);
    }
  }, 25000);

  dbService.saveLog({
    level: 'info',
    source: 'System',
    message: 'FarmGuardian AI simulation loops started.'
  });
}

// Start Server
app.listen(config.port, () => {
  console.log(`🚀 FarmGuardian AI Backend running on port ${config.port}`);
  
  // Seed initial data
  dbService.clearAll();
  sensorService.simulateTelemetryTick();
  
  // Start simulation cycles
  startSimulationLoops();
});

// Graceful shutdown
process.on('SIGTERM', () => {
  clearInterval(telemetryIntervalId);
  clearInterval(auditIntervalId);
  process.exit(0);
});
