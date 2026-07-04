import { initializeApp } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import { onDocumentCreated, onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { GoogleGenAI } from '@google/genai';

// Initialize Firebase Admin
initializeApp();
const db = getFirestore();
const messaging = getMessaging();

// Initialize Google Gen AI SDK
const geminiKey = process.env.GEMINI_API_KEY || '';
const ai = geminiKey ? new GoogleGenAI({ apiKey: geminiKey }) : null;

if (!geminiKey) {
  console.warn('⚠️ WARNING: GEMINI_API_KEY environment variable is missing. Cloud Functions will run in offline simulation fallback mode.');
}

// ----------------------------------------------------
// 1. Telemetry Auditor Firestore Trigger
// ----------------------------------------------------
export const auditTelemetry = onDocumentCreated('telemetry/{telemetryId}', async (event) => {
  const snapshot = event.data;
  if (!snapshot) return;

  const data = snapshot.data();
  const farmId = data.farmId;
  const readings = data.readings || {};
  const timestamp = data.timestamp;

  console.log(`[TelemetryAuditor] Auditing farmId: ${farmId}, document: ${event.params.telemetryId}`);

  // 1. Audit logic - Check for active anomalies or critical levels
  let droneLaunchRequired = false;
  let targetZone = null;
  let reason = '';
  const alerts = [];

  for (const [zone, sensors] of Object.entries(readings)) {
    const cropName = sensors.cropName || 'Crop';
    const anomalies = sensors.anomalies || [];
    const moisture = sensors.soilMoisture || 50;

    // Trigger drone if soil moisture falls below threshold or pests/disease are flagged
    if (moisture < 35) {
      droneLaunchRequired = true;
      targetZone = zone;
      reason = `Critical soil moisture drop in ${zone} (${cropName}) down to ${moisture}%. Launching drone for thermal scan.`;
      alerts.push({
        zone,
        cropName,
        title: `Low Hydration in ${zone}`,
        description: `Soil moisture dropped to ${moisture}%.`,
        severity: 'critical'
      });
    }

    if (anomalies.includes('pests') || anomalies.includes('disease')) {
      droneLaunchRequired = true;
      targetZone = zone;
      reason = `Biological stress anomaly detected in ${zone} (${cropName}). Dispatched drone sweep for leaf tissue pathogen audit.`;
      alerts.push({
        zone,
        cropName,
        title: `Biological Stress in ${zone}`,
        description: `Sensors indicate biological stress anomalies: ${anomalies.join(', ')}.`,
        severity: 'warning'
      });
    }
  }

  // 2. Launch Drone autonomously if required
  if (droneLaunchRequired && targetZone) {
    console.log(`[TelemetryAuditor] Autonomous Drone Inspection triggered for ${targetZone}. Reason: ${reason}`);

    // Check if there is already an active mission to avoid duplicates
    const activeMissions = await db.collection('drone_missions')
        .where('farmId', '==', farmId)
        .where('zone', '==', targetZone)
        .where('status', 'in', ['pending', 'launching', 'active', 'scanning'])
        .limit(1)
        .get();

    if (activeMissions.empty) {
      // Create new drone mission
      const missionRef = await db.collection('drone_missions').add({
        farmId,
        zone: targetZone,
        cropName: readings[targetZone]?.cropName || 'Crop',
        status: 'launching',
        reason,
        triggerType: 'autonomous',
        battery: 100,
        timestamp: FieldValue.serverTimestamp()
      });

      console.log(`[TelemetryAuditor] Created drone mission ID: ${missionRef.id}`);

      // Save System Log
      await db.collection('logs').add({
        farmId,
        timestamp: FieldValue.serverTimestamp(),
        level: 'critical',
        source: 'GeminiDecisionEngine',
        message: `AUTONOMOUS DEPLOYMENT: Drone mission scheduled for ${targetZone}. Reason: ${reason}`
      });

      // Dispatch Push Notification to Operator FCM topic
      const topic = `farm_${farmId}_alerts`;
      const notificationPayload = {
        topic,
        notification: {
          title: '🛸 Autonomous Drone Launched',
          body: `Inspecting ${targetZone} due to: ${reason}`
        },
        data: {
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
          farmId,
          missionId: missionRef.id,
          zone: targetZone
        }
      };

      try {
        await messaging.send(notificationPayload);
        console.log(`[TelemetryAuditor] Dispatched push notification for topic: ${topic}`);
      } catch (err) {
        console.error('[TelemetryAuditor] Messaging notify failed:', err);
      }
    }
  }

  // Write new general recommendations logs to database
  for (const alert of alerts) {
    const existingAlerts = await db.collection('recommendations')
        .where('farmId', '==', farmId)
        .where('zone', '==', alert.zone)
        .where('title', '==', alert.title)
        .where('resolved', '==', false)
        .get();

    if (existingAlerts.empty) {
      await db.collection('recommendations').add({
        farmId,
        zone: alert.zone,
        cropName: alert.cropName,
        title: alert.title,
        description: alert.description,
        severity: alert.severity,
        recommendations: ['Perform field inspection.', 'Monitor telemetry updates closely.'],
        resolved: false,
        timestamp: FieldValue.serverTimestamp()
      });
    }
  }
});

// ----------------------------------------------------
// 2. Drone Image Diagnostic Trigger
// ----------------------------------------------------
export const processDroneImage = onDocumentUpdated('drone_missions/{missionId}', async (event) => {
  const beforeData = event.data.before.data();
  const afterData = event.data.after.data();

  // Trigger only when imageUrl changes or when mission status transitions to 'scanning'
  const isImageAvailable = afterData.imageUrl && afterData.imageUrl !== beforeData.imageUrl;
  const isScanningTrigger = afterData.status === 'scanning' && beforeData.status !== 'scanning';

  if (!isImageAvailable && !isScanningTrigger) return;

  const missionId = event.params.missionId;
  const farmId = afterData.farmId;
  const zone = afterData.zone;
  const cropName = afterData.cropName;

  console.log(`[ImageProcessor] Process request for mission: ${missionId}, zone: ${zone}`);

  let diagnosisResult = null;

  if (!ai) {
    // Offline simulation diagnostic fallback
    console.log('[ImageProcessor] Running simulation fallback analysis...');
    
    // Read the latest telemetry to identify what anomaly was triggered
    const recentTelemetry = await db.collection('telemetry')
        .where('farmId', '==', farmId)
        .orderBy('timestamp', 'desc')
        .limit(1)
        .get();

    let activeAnomaly = 'none';
    if (!recentTelemetry.empty) {
      const readings = recentTelemetry.docs[0].data().readings || {};
      const zoneReadings = readings[zone] || {};
      const anomalies = zoneReadings.anomalies || [];
      if (anomalies.length > 0) activeAnomaly = anomalies[0];
    }

    diagnosisResult = getMockImageDiagnosis(zone, cropName, activeAnomaly);
  } else {
    // Live Gemini Vision Diagnostic API call
    try {
      let imageContent = null;
      if (afterData.imageUrl) {
        // Fetch image as base64 from firebase storage url
        const response = await fetch(afterData.imageUrl);
        const buffer = await response.arrayBuffer();
        imageContent = {
          inlineData: {
            data: Buffer.from(buffer).toString('base64'),
            mimeType: 'image/jpeg'
          }
        };
      } else {
        // Fallback: supply placeholder empty base64 or run text audit
        imageContent = {
          inlineData: {
            data: 'R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7', // 1x1 empty pixel
            mimeType: 'image/jpeg'
          }
        };
      }

      const prompt = `
      You are an expert visual agronomist AI for FarmGuardian AI.
      Analyze this multispectral close-up crop leaf image of ${cropName} in ${zone}.
      Detect any symptoms of crop stress: water deficit, pests (aphids, mites), fungal diseases, or chemical nutrient deficits.
      
      Output ONLY structured JSON using this layout:
      {
        "cropHealthStatus": "healthy" | "stressed" | "diseased" | "damaged",
        "issueDetected": "Specific diagnosis name (e.g. Leaf Spot Disease)",
        "severity": "critical" | "warning" | "normal",
        "confidence": number,
        "findings": "Details of spotting, insect damage, wilting, or physical change.",
        "recommendations": [
          "Actionable recommendation 1",
          "Actionable recommendation 2"
        ]
      }
      `;

      const contents = [imageContent, prompt];
      const modelResponse = await ai.models.generateContent({
        model: 'gemini-2.5-flash',
        contents,
        config: {
          responseMimeType: 'application/json'
        }
      });

      const responseText = modelResponse.text || modelResponse.candidates?.[0]?.content?.parts?.[0]?.text;
      diagnosisResult = JSON.parse(responseText);
    } catch (err) {
      console.error('[ImageProcessor] Gemini vision API call failed, falling back:', err);
      diagnosisResult = getMockImageDiagnosis(zone, cropName, 'none');
    }
  }

  // Update drone mission with completed diagnostics
  await db.collection('drone_missions').doc(missionId).update({
    status: 'completed',
    diagnostics: diagnosisResult,
    completedAt: FieldValue.serverTimestamp()
  });

  console.log(`[ImageProcessor] Completed diagnosis for mission: ${missionId}`);

  // Create Recommendation log if issue exists
  if (diagnosisResult.issueDetected !== 'None') {
    await db.collection('recommendations').add({
      farmId,
      zone,
      cropName,
      title: diagnosisResult.issueDetected,
      description: diagnosisResult.findings,
      severity: diagnosisResult.severity,
      recommendations: diagnosisResult.recommendations,
      resolved: false,
      missionId,
      timestamp: FieldValue.serverTimestamp()
    });

    // Save System Log
    await db.collection('logs').add({
      farmId,
      timestamp: FieldValue.serverTimestamp(),
      level: 'warning',
      source: 'GeminiDecisionEngine',
      message: `PRESCRIPTION REGISTERED: ${diagnosisResult.issueDetected} in ${zone} (${cropName}).`
    });
  }
});

// Helper for Mock Vision Diagnostics
function getMockImageDiagnosis(zone, cropName, anomaly) {
  if (anomaly === 'drought') {
    return {
      cropHealthStatus: 'stressed',
      issueDetected: 'Water Deficiency (Drought stress)',
      severity: 'critical',
      confidence: 94,
      findings: `Aerial multispectral imagery of ${cropName} in ${zone} reveals leaf margin curling, greyish-green color shifts, and visible soil crust cracking due to low moisture.`,
      recommendations: [
        'Initiate drip-irrigation cycle immediately for 120 minutes.',
        'Apply organic straw mulch to reduce evaporation rates.'
      ]
    };
  } else if (anomaly === 'nutrient_def') {
    return {
      cropHealthStatus: 'stressed',
      issueDetected: 'Nitrogen Deficiency (Chlorosis)',
      severity: 'warning',
      confidence: 88,
      findings: `Visual leaf assessment indicates yellowing starting from older lower leaves, indicating Nitrogen deficits.`,
      recommendations: [
        'Inject liquid NPK fertilizer custom mixture via fertigation.',
        'Monitor telemetry history charts.'
      ]
    };
  } else if (anomaly === 'pests') {
    return {
      cropHealthStatus: 'diseased',
      issueDetected: 'Pest Infestation (Aphids)',
      severity: 'warning',
      confidence: 91,
      findings: `High resolution zoom captures locate dense insect cluster colonies along crop stalks, resulting in leaf margins curling.`,
      recommendations: [
        'Distribute localized organic bio-pesticide spray.',
        'Release ladybug biological predators.'
      ]
    };
  } else if (anomaly === 'disease') {
    return {
      cropHealthStatus: 'diseased',
      issueDetected: 'Fungal Infection (Powdery Mildew)',
      severity: 'warning',
      confidence: 90,
      findings: `White circular powdery mildew patches detected along crop foliage surfaces.`,
      recommendations: [
        'Apply organic sulfur fungicide spray.',
        'Thin out lower foliage branches to boost ventilation airflow.'
      ]
    };
  } else {
    return {
      cropHealthStatus: 'healthy',
      issueDetected: 'None',
      severity: 'normal',
      confidence: 98,
      findings: 'Leaf chlorophyll levels are robust and uniform. Hydration turgor and leaf temperatures are nominal. No active stress indicators detected.',
      recommendations: [
        'Maintain regular irrigation schedules.',
        'Perform next audit in 7 days.'
      ]
    };
  }
}

// ----------------------------------------------------
// 3. Gemini Chat Consultant Callable Function
// ----------------------------------------------------
export const consultAI = onCall(async (request) => {
  const { farmId, message, history } = request.data;
  
  if (!message) {
    throw new HttpsError('invalid-argument', 'The message parameter is required.');
  }

  console.log(`[ConsultAI] Message received from farm: ${farmId}`);

  // Fetch contextual details from DB
  const recentLogsSnapshot = await db.collection('logs')
      .where('farmId', '==', farmId)
      .orderBy('timestamp', 'desc')
      .limit(10)
      .get();
  
  const recentLogs = recentLogsSnapshot.docs.map(doc => {
    const data = doc.data();
    return `[${data.source}] ${data.message}`;
  });

  const recentRecsSnapshot = await db.collection('recommendations')
      .where('farmId', '==', farmId)
      .where('resolved', '==', false)
      .limit(5)
      .get();

  const recentRecs = recentRecsSnapshot.docs.map(doc => doc.data().title);

  const contextPrompt = `
  You are the Lead FarmGuardian AI Agronomist Chat Consultant.
  You help a farmer manage their crop yields using real-time telemetry, weather data, and chronological logs.
  
  Current Farm Context:
  - Farm ID: ${farmId}
  - Unresolved AI recommendations: ${JSON.stringify(recentRecs)}
  - Recent Facility logs: ${JSON.stringify(recentLogs)}
  
  Instructions:
  - Provide highly practical agronomical answers (details on watering, NPK ratios, biological treatments, pruning).
  - Use brief, clear formatting, headers, and bullet points.
  - Keep the tone warm, helpful, and professional.
  `;

  if (!ai) {
    // Offline simulation consult fallback
    const msgLower = message.toLowerCase();
    let reply = "Hello! I am your FarmGuardian AI Agronomy Consultant. Current farm probes look stable. How can I assist you today?";
    
    if (msgLower.includes('water') || msgLower.includes('dry') || msgLower.includes('irrigate')) {
      reply = "Telemetry registers normal soil moisture across most zones, but if a drought warning is active, I suggest increase watering cycles by 15 minutes early in the morning to mitigate heat evaporation.";
    } else if (msgLower.includes('pest') || msgLower.includes('insect') || msgLower.includes('bug')) {
      reply = "Our drone logs show minor aphid risks. You can apply an organic 2% neem oil solution, or release natural predators like ladybugs.";
    }
    return { response: reply };
  }

  try {
    // Format chat history for Gemini API
    const contents = [
      { role: 'user', parts: [{ text: contextPrompt }] }
    ];

    if (history && Array.isArray(history)) {
      for (const chat of history) {
        contents.push({
          role: chat.role === 'user' ? 'user' : 'model',
          parts: [{ text: chat.message }]
        });
      }
    }

    // Add latest message
    contents.push({
      role: 'user',
      parts: [{ text: message }]
    });

    const modelResponse = await ai.models.generateContent({
      model: 'gemini-2.5-flash',
      contents
    });

    const reply = modelResponse.text || modelResponse.candidates?.[0]?.content?.parts?.[0]?.text;
    return { response: reply };
  } catch (err) {
    console.error('[ConsultAI] Gemini chat consultation failed:', err);
    throw new HttpsError('internal', 'Gemini API query execution failed.');
  }
});
