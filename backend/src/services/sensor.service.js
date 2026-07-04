import { dbService } from './db.service.js';
import { weatherService } from './weather.service.js';

// Base crop profiles
const cropProfiles = {
  'Zone A': { name: 'Lettuce Field', optimalMoisture: 70, optTemp: 20 },
  'Zone B': { name: 'Apple Orchard', optimalMoisture: 55, optTemp: 22 },
  'Zone C': { name: 'Vineyard', optimalMoisture: 45, optTemp: 25 },
  'Zone D': { name: 'Wheat Fields', optimalMoisture: 50, optTemp: 21 }
};

// Current in-memory sensor values for the 4 zones
let zonesSensors = {
  'Zone A': {
    temperature: 20.4,
    soilMoisture: 68,
    ph: 6.2,
    nitrogen: 140, // optimal 120-160
    phosphorus: 48, // optimal 40-60
    potassium: 210, // optimal 180-240
    status: 'Online',
    anomalies: [], // list of active anomalies: 'drought', 'pests', 'disease', 'nutrient_def'
    predictions: {
      expectedYieldTons: 12.5,
      yieldTargetTons: 12.5,
      irrigation3DayLiters: 120,
      diseaseRisk: { disease: 'Leaf Rust', probability: 8, factor: 'Optimal environmental parameters.' }
    }
  },
  'Zone B': {
    temperature: 21.8,
    soilMoisture: 56,
    ph: 6.5,
    nitrogen: 110,
    phosphorus: 38,
    potassium: 195,
    status: 'Online',
    anomalies: [],
    predictions: {
      expectedYieldTons: 8.5,
      yieldTargetTons: 8.5,
      irrigation3DayLiters: 110,
      diseaseRisk: { disease: 'Aphid Sooty Mold', probability: 5, factor: 'Optimal environmental parameters.' }
    }
  },
  'Zone C': {
    temperature: 23.5,
    soilMoisture: 47,
    ph: 6.8,
    nitrogen: 95,
    phosphorus: 35,
    potassium: 170,
    status: 'Online',
    anomalies: [],
    predictions: {
      expectedYieldTons: 15.0,
      yieldTargetTons: 15.0,
      irrigation3DayLiters: 90,
      diseaseRisk: { disease: 'Powdery Mildew', probability: 9, factor: 'Optimal environmental parameters.' }
    }
  },
  'Zone D': {
    temperature: 20.9,
    soilMoisture: 51,
    ph: 6.0,
    nitrogen: 130,
    phosphorus: 42,
    potassium: 205,
    status: 'Online',
    anomalies: [],
    predictions: {
      expectedYieldTons: 22.0,
      yieldTargetTons: 22.0,
      irrigation3DayLiters: 140,
      diseaseRisk: { disease: 'Root Rot', probability: 6, factor: 'Optimal environmental parameters.' }
    }
  }
};

export const sensorService = {
  getSensors() {
    return zonesSensors;
  },

  // Set manual anomaly
  triggerAnomaly(zone, anomalyType) {
    if (!zonesSensors[zone]) return null;
    
    const sensors = zonesSensors[zone];
    
    // Clear other anomalies of the same category, or add to list
    if (anomalyType === 'clear') {
      sensors.anomalies = [];
      sensors.status = 'Online';
      // Reset values back toward normal
      const profile = cropProfiles[zone];
      sensors.soilMoisture = profile.optimalMoisture;
      sensors.nitrogen = 130;
      sensors.phosphorus = 45;
      sensors.potassium = 200;
      
      dbService.saveLog({
        level: 'info',
        source: 'SensorMonitor',
        message: `Anomalies cleared for ${zone} (${cropProfiles[zone].name}). Telemetry stabilizing.`
      });
      return sensors;
    }

    if (!sensors.anomalies.includes(anomalyType)) {
      sensors.anomalies.push(anomalyType);
    }
    
    sensors.status = 'Warning';

    // Apply immediate sensor changes based on anomaly type to provoke Gemini response
    switch (anomalyType) {
      case 'drought':
        sensors.soilMoisture = Math.round(sensors.soilMoisture * 0.4); // drops significantly
        break;
      case 'nutrient_def':
        sensors.nitrogen = Math.round(sensors.nitrogen * 0.3); // N level tanks
        sensors.phosphorus = Math.round(sensors.phosphorus * 0.4); // P level tanks
        sensors.potassium = Math.round(sensors.potassium * 0.5); // K level tanks
        break;
      case 'pests':
      case 'disease':
        // Pests and diseases don't change chemistry instantly, but sensors can register a mild humidity warning 
        // or trigger visual inspection via image diagnostics.
        sensors.status = 'Warning';
        break;
      default:
        break;
    }

    dbService.saveLog({
      level: 'warning',
      source: 'SensorMonitor',
      message: `Anomaly [${anomalyType.toUpperCase()}] triggered in ${zone} (${cropProfiles[zone].name}).`
    });

    return sensors;
  },

  // Periodic updates to simulate real agricultural cycles
  simulateTelemetryTick() {
    const weather = weatherService.getCurrentWeather();
    const tickData = {};

    for (const [zone, sensors] of Object.entries(zonesSensors)) {
      const profile = cropProfiles[zone];
      
      // Update sensor temperature based on weather + minor offset
      sensors.temperature = parseFloat((weather.temperature + (Math.random() * 2 - 1)).toFixed(1));
      
      // Soil moisture dynamics
      if (weather.condition === 'Stormy' || weather.condition === 'Rainy') {
        sensors.soilMoisture = Math.min(95, sensors.soilMoisture + Math.floor(Math.random() * 6 + 4));
      } else if (weather.condition === 'HeatWave' || sensors.anomalies.includes('drought')) {
        sensors.soilMoisture = Math.max(8, sensors.soilMoisture - Math.floor(Math.random() * 4 + 2));
      } else {
        // Natural drying or stabilization around optimal moisture
        if (sensors.soilMoisture > profile.optimalMoisture) {
          sensors.soilMoisture -= Math.floor(Math.random() * 2);
        } else if (sensors.soilMoisture < profile.optimalMoisture) {
          sensors.soilMoisture += Math.floor(Math.random() * 2);
        }
      }

      // Nutrient fluctuations
      if (sensors.anomalies.includes('nutrient_def')) {
        sensors.nitrogen = Math.max(10, sensors.nitrogen - Math.floor(Math.random() * 3));
        sensors.phosphorus = Math.max(5, sensors.phosphorus - Math.floor(Math.random() * 2));
        sensors.potassium = Math.max(20, sensors.potassium - Math.floor(Math.random() * 4));
      } else {
        // Slow natural draw & restoration
        sensors.nitrogen = Math.round(sensors.nitrogen + (Math.random() * 4 - 2));
        sensors.phosphorus = Math.round(sensors.phosphorus + (Math.random() * 2 - 1));
        sensors.potassium = Math.round(sensors.potassium + (Math.random() * 6 - 3));
      }

      // Constrain nutrients to reasonable bounds
      sensors.nitrogen = Math.min(250, Math.max(5, sensors.nitrogen));
      sensors.phosphorus = Math.min(100, Math.max(2, sensors.phosphorus));
      sensors.potassium = Math.min(400, Math.max(10, sensors.potassium));
      
      // Constrain pH
      sensors.ph = parseFloat((sensors.ph + (Math.random() * 0.1 - 0.05)).toFixed(2));
      sensors.ph = Math.min(8.5, Math.max(4.5, sensors.ph));

      // Determine Status
      if (sensors.anomalies.length > 0) {
        sensors.status = 'Warning';
      } else if (
        sensors.soilMoisture < (profile.optimalMoisture - 20) ||
        sensors.soilMoisture > (profile.optimalMoisture + 25) ||
        sensors.nitrogen < 70 ||
        sensors.potassium < 120
      ) {
        sensors.status = 'Warning';
      } else {
        sensors.status = 'Online';
      }

      // Calculate Crop Yield Prediction
      let expectedYield = 10.0;
      let targetYield = 10.0;
      if (zone === 'Zone A') { targetYield = 12.5; expectedYield = 12.5; }
      else if (zone === 'Zone B') { targetYield = 8.5; expectedYield = 8.5; }
      else if (zone === 'Zone C') { targetYield = 15.0; expectedYield = 15.0; }
      else if (zone === 'Zone D') { targetYield = 22.0; expectedYield = 22.0; }

      if (sensors.anomalies.includes('drought')) {
        expectedYield = parseFloat((expectedYield * 0.65).toFixed(1));
      } else if (sensors.anomalies.includes('pests')) {
        expectedYield = parseFloat((expectedYield * 0.82).toFixed(1));
      } else if (sensors.anomalies.includes('disease')) {
        expectedYield = parseFloat((expectedYield * 0.78).toFixed(1));
      } else if (sensors.anomalies.includes('nutrient_def')) {
        expectedYield = parseFloat((expectedYield * 0.85).toFixed(1));
      } else {
        // slight normal variation
        const change = (Math.random() * 0.3);
        expectedYield = parseFloat((expectedYield - change).toFixed(1));
      }

      // Calculate 3-Day Irrigation Needs (in Liters)
      let optimalMoisture = profile.optimalMoisture;
      let diff = optimalMoisture - sensors.soilMoisture;
      let irrNeed = Math.max(30, Math.round(diff * 4 + 100)); // base line needs
      if (sensors.anomalies.includes('drought')) {
        irrNeed += 250;
      }
      if (weather.condition === 'HeatWave') {
        irrNeed += 120;
      } else if (weather.condition === 'Stormy' || weather.condition === 'Rainy') {
        irrNeed = Math.max(10, irrNeed - 80);
      }

      // Pre-symptomatic Disease Risk Prediction
      let riskPct = Math.round(5 + Math.random() * 8);
      let diseaseType = 'Leaf Rust';
      let riskFactor = 'Optimal environmental parameters.';

      if (sensors.anomalies.includes('disease')) {
        riskPct = 96;
        diseaseType = 'Fungal Powdery Mildew';
        riskFactor = 'Active fungal symptoms detected in canopy.';
      } else if (sensors.anomalies.includes('pests')) {
        riskPct = 82;
        diseaseType = 'Sooty Mold';
        riskFactor = 'Pest vectors present; high honeydew secretion hazard.';
      } else if (sensors.soilMoisture > 82) {
        riskPct = Math.round(62 + Math.random() * 15);
        diseaseType = 'Root Rot';
        riskFactor = 'Excess soil saturation triggering root decay path.';
      } else if (weather.condition === 'Frosty' || sensors.temperature < 11) {
        riskPct = Math.round(55 + Math.random() * 18);
        diseaseType = 'Frost Necrosis';
        riskFactor = 'Sub-optimal canopy temperature cell wall stress.';
      } else if (weather.humidity > 80) {
        riskPct = Math.round(48 + Math.random() * 15);
        diseaseType = 'Powdery Mildew';
        riskFactor = 'Elevated microclimate humidity accelerates spore growth.';
      }

      sensors.predictions = {
        expectedYieldTons: expectedYield,
        yieldTargetTons: targetYield,
        irrigation3DayLiters: irrNeed,
        diseaseRisk: {
          disease: diseaseType,
          probability: riskPct,
          factor: riskFactor
        }
      };

      tickData[zone] = { ...sensors, cropName: profile.name };
    }

    // Save consolidated reading in Database
    dbService.saveTelemetry(tickData);
    return tickData;
  }
};
