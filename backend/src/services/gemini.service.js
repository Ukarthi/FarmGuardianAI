import { ai, config } from '../config.js';
import { dbService } from './db.service.js';

// Mock decision helper based on active anomalies to run seamlessly when offline
function getMockTelemetryAudit(telemetryData, weatherData) {
  let droneLaunchRequired = false;
  let targetZone = null;
  let reasoning = 'All sensor readings are within normal variance. No immediate physical inspection required.';
  const alerts = [];

  for (const [zone, sensors] of Object.entries(telemetryData)) {
    // Audit soil moisture
    if (sensors.soilMoisture < 30) {
      droneLaunchRequired = true;
      targetZone = zone;
      reasoning = `Sensor telemetry for ${zone} (${sensors.cropName}) shows dangerously low soil moisture (${sensors.soilMoisture}%). Immediate drone launch is triggered to inspect leaf wilting or soil cracking.`;
      alerts.push({
        title: `Critical Dryness in ${zone}`,
        description: `Soil moisture in ${sensors.cropName} is at ${sensors.soilMoisture}%. Recommended immediate watering.`,
        severity: 'high'
      });
    }

    // Audit nutrient levels
    if (sensors.nitrogen < 50 || sensors.phosphorus < 20 || sensors.potassium < 100) {
      alerts.push({
        title: `Nutrient Deficit in ${zone}`,
        description: `Low NPK levels detected: N=${sensors.nitrogen}, P=${sensors.phosphorus}, K=${sensors.potassium} mg/kg. Apply fertilizer.`,
        severity: 'medium'
      });
    }

    // Audit manual triggers (e.g. pests, disease) that need visual confirmation
    if (sensors.anomalies.includes('pests') || sensors.anomalies.includes('disease')) {
      droneLaunchRequired = true;
      targetZone = zone;
      reasoning = `Sensors registered biological stress warning in ${zone} (${sensors.cropName}). Activating autonomous drone inspection to capture high-res crop imagery for pathogen detection.`;
      alerts.push({
        title: `Crop Stress in ${zone}`,
        description: `Unusual leaf transpiration changes detected. Visual survey scheduled.`,
        severity: 'medium'
      });
    }
  }

  // Weather events
  if (weatherData.stormWarning) {
    alerts.push({
      title: 'High Winds Warning',
      description: 'Severe weather could lead to crop damage. Prepare post-storm drone assessment.',
      severity: 'high'
    });
  }

  return {
    droneLaunchRequired,
    targetZone,
    reasoning,
    alerts
  };
}

function getMockImageDiagnosis(zoneName, cropName, anomalyType) {
  const reports = {
    'drought': {
      cropHealthStatus: 'stressed',
      issueDetected: 'Water Deficiency (Drought stress)',
      severity: 'critical',
      confidence: 94,
      findings: `High-resolution aerial imagery of the ${cropName} in ${zoneName} reveals distinct leaf curling, greyish-green color shifts, and visible soil crust cracking. Upper canopy shows initial signs of tip burn.`,
      recommendations: [
        'Initiate drip-irrigation cycle immediately for 120 minutes.',
        'Apply organic straw mulch to reduce evaporation rates.'
      ]
    },
    'nutrient_def': {
      cropHealthStatus: 'stressed',
      issueDetected: 'Nitrogen Deficiency (Chlorosis)',
      severity: 'warning',
      confidence: 88,
      findings: `Visual inspection of ${cropName} leaves in ${zoneName} indicates generalized yellowing starting from older lower leaves, while veins remain faintly green. Stunted shoot growth is apparent compared to healthy zones.`,
      recommendations: [
        'Inject soluble liquid ammonium-nitrate fertilizer via fertigation.',
        'Conduct a detailed leaf tissue test to evaluate micro-nutrients.'
      ]
    },
    'pests': {
      cropHealthStatus: 'diseased',
      issueDetected: 'Pest Infestation (Aphids & Spider Mites)',
      severity: 'warning',
      confidence: 85,
      findings: `Close-up multispectral drone imagery detects heavy speckling on leaf surfaces, fine web structures on undersides, and sticky honeydew deposits. Curled leaf margins host dense insect clusters.`,
      recommendations: [
        'Release predatory ladybugs (Hippodamia convergens) as biological control agents.',
        'Apply localized organic neem oil solution in early morning hours.'
      ]
    },
    'disease': {
      cropHealthStatus: 'diseased',
      issueDetected: 'Fungal Infection (Powdery Mildew)',
      severity: 'warning',
      confidence: 90,
      findings: `White, talcum-powder-like circular patches detected covering extensive portions of leaf surfaces and stems in the ${cropName} canopy. Lower leaves exhibit premature drying and leaf drop.`,
      recommendations: [
        'Apply organic sulfur-based fungicide or potassium bicarbonate spray.',
        'Prune lower leaves to improve airflow and reduce microclimate humidity.'
      ]
    },
    'default': {
      cropHealthStatus: 'healthy',
      issueDetected: 'None',
      severity: 'normal',
      confidence: 97,
      findings: `No crop stress detected in ${zoneName}. Leaf canopy displays robust turgor pressure, uniform deep green chlorophyll density, and normal transpiration rate. No visible pests, weeds, or structural issues.`,
      recommendations: [
        'Maintain current watering schedules.',
        'Standard sensor monitoring continues.'
      ]
    }
  };

  return reports[anomalyType] || reports['default'];
}

export const geminiService = {
  /**
   * Periodically audits the entire farm's sensor readings and regional weather
   */
  async auditTelemetry(telemetryData, weatherData) {
    if (config.isMockMode) {
      // Mock response
      return getMockTelemetryAudit(telemetryData, weatherData);
    }

    try {
      const prompt = `
      You are the core AI Decision Engine for FarmGuardian AI, an autonomous precision farming system.
      Analyze the following sensor data and current weather forecast:
      
      Weather Data:
      ${JSON.stringify(weatherData, null, 2)}
      
      Real-Time Sensor Telemetry (by Zone):
      ${JSON.stringify(telemetryData, null, 2)}

      Your task:
      1. Audit if any zone is showing signs of critical stress (e.g. soil moisture drop, weather hazards, active crop anomalies, nutrient deficiency).
      2. Decide if we need to autonomously launch a drone for visual aerial inspection of a specific zone. Set "droneLaunchRequired" to true only if there is a warning state, significant anomaly, or severe weather warning. Indicate which zone should be surveyed in "targetZone" (e.g. "Zone A").
      3. Outline your analytical reasoning in "reasoning".
      4. Generate actionable alerts to show on the dashboard. Specify title, description, and severity (high, medium, low).

      Respond ONLY in valid JSON. Use this structure:
      {
        "droneLaunchRequired": boolean,
        "targetZone": string or null,
        "reasoning": "...",
        "alerts": [
          { "title": "Alert Title", "description": "Alert description detailing metrics and solution", "severity": "high" | "medium" | "low" }
        ]
      }
      `;

      const response = await ai.models.generateContent({
        model: 'gemini-2.5-flash',
        contents: prompt,
        config: {
          responseMimeType: 'application/json'
        }
      });

      const responseText = response.text || response.candidates?.[0]?.content?.parts?.[0]?.text;
      return JSON.parse(responseText);
    } catch (error) {
      console.error('Gemini audit API error, falling back to mock:', error);
      return getMockTelemetryAudit(telemetryData, weatherData);
    }
  },

  /**
   * Diagnoses crop health using drone-captured images and metadata
   */
  async analyzeDroneImage(imageBase64, zoneName, cropName, telemetryContext, activeAnomaly = 'none') {
    if (config.isMockMode || !imageBase64) {
      // Simulate real diagnostics
      return getMockImageDiagnosis(zoneName, cropName, activeAnomaly);
    }

    try {
      const prompt = `
      You are an expert agronomist and visual diagnostics AI for FarmGuardian AI.
      We have launched a drone to inspect a crop showing stress in ${zoneName} (${cropName}).
      
      Telemetry context:
      ${JSON.stringify(telemetryContext, null, 2)}

      Analyze the attached image. Look closely for:
      - Insect damage / pests
      - Fungal/viral/bacterial disease symptoms (leaf spots, powdery mildew, rust)
      - Water stress (wilting, dryness, soil cracks)
      - Wind, hail, or storm lodging/damage
      - Nutrient deficiencies visible in leaf chlorosis or discoloration
      
      Provide a highly professional assessment. Return JSON ONLY using the following structure:
      {
        "cropHealthStatus": "healthy" | "stressed" | "diseased" | "damaged",
        "issueDetected": "Specific diagnosis name (e.g. Fungal Blight, Spider Mites)",
        "severity": "critical" | "warning" | "normal",
        "confidence": number (percentage between 0-100),
        "findings": "Detailed description of leaf spotting, insect presence, or physical changes visible in the photo.",
        "recommendations": [
          "Actionable recommendation 1",
          "Actionable recommendation 2"
        ]
      }
      `;

      const contents = [
        {
          inlineData: {
            data: imageBase64,
            mimeType: 'image/jpeg'
          }
        },
        prompt
      ];

      const response = await ai.models.generateContent({
        model: 'gemini-2.5-flash',
        contents: contents,
        config: {
          responseMimeType: 'application/json'
        }
      });

      const responseText = response.text || response.candidates?.[0]?.content?.parts?.[0]?.text;
      return JSON.parse(responseText);
    } catch (error) {
      console.error('Gemini image diagnostic API error, falling back to mock:', error);
      return getMockImageDiagnosis(zoneName, cropName, activeAnomaly);
    }
  },

  /**
   * Consultation chat with Gemini AI using Farm Memory and live status
   */
  async consultFarmAI(userMessage, chatHistory = []) {
    // Prepare farm memory context
    const recentLogs = dbService.getLogs(15);
    const recentRecs = dbService.getRecommendations(5);
    const telemetry = dbService.getTelemetryHistory(1)[0] || {};
    
    const contextPrompt = `
    You are the lead FarmGuardian AI agronomy consultant. 
    You are helping a farmer manage their crop yields using real-time telemetry, weather data, and historical logs.
    
    Current Farm Context:
    - Recent Telemetry: ${JSON.stringify(telemetry, null, 2)}
    - Recent AI Recommendations: ${JSON.stringify(recentRecs, null, 2)}
    - Recent System Events: ${JSON.stringify(recentLogs.map(l => `[${l.timestamp}] [${l.source}] ${l.message}`), null, 2)}
    
    Instructions:
    - Respond in a warm, professional, helpful tone.
    - Provide deep agronomical advice based on the context.
    - Use bullet points and clean formatting.
    - Keep responses concise and focused on practical field operations (e.g. irrigation rates, bio-pest control, soil conditioning).
    `;

    if (config.isMockMode) {
      // Mock consulting responses for offline demo
      const messageLower = userMessage.toLowerCase();
      if (messageLower.includes('water') || messageLower.includes('irrigate') || messageLower.includes('dry')) {
        return `Based on current telemetry, the lettuce fields (**Zone A**) are drying out faster than average due to ambient heat. I recommend increasing the watering intervals:
*   **Action:** Transition drip irrigation from 30 mins to 45 mins daily.
*   **Time:** Schedule irrigation for 5:00 AM to minimize evaporation loss.
*   **Sensor Check:** Keep soil moisture target above 65%. Let me know if you need to schedule a localized drone survey.`;
      }
      if (messageLower.includes('pest') || messageLower.includes('bug') || messageLower.includes('insect')) {
        return `My visual logs indicate a moderate aphid presence in the Apple Orchard (**Zone B**). 
*   **Recommended Control:** Apply a 2% dilution of cold-pressed organic Neem Oil spray.
*   **Biological Agent:** Consider releasing lacewings or ladybugs to regulate populations naturally.
*   **Drone Inspection:** I can schedule a thermal camera sweep of the orchard canopy to check for micro-transpiration drops.`;
      }
      return `Hello! I am your FarmGuardian AI Agronomy Consultant. I monitor all 4 zones (Lettuce, Apple, Grapes, and Wheat) using IoT telemetry, local weather, and autonomous drone sweeps.

I am aware of our recent logs:
*   We've captured sensor updates showing a baseline weather temperature of 24°C.
*   The Drone is fully charged and ready for autonomous inspection loops.

How can I assist you with your farming strategy, soil conditions, or crop health questions today?`;
    }

    try {
      // Setup chat history format
      const formattedContents = [
        { role: 'user', parts: [{ text: contextPrompt }] }
      ];

      for (const chat of chatHistory) {
        formattedContents.push({
          role: chat.role === 'user' ? 'user' : 'model',
          parts: [{ text: chat.message }]
        });
      }

      // Add the latest user message
      formattedContents.push({
        role: 'user',
        parts: [{ text: userMessage }]
      });

      const response = await ai.models.generateContent({
        model: 'gemini-2.5-flash',
        contents: formattedContents
      });

      return response.text || response.candidates?.[0]?.content?.parts?.[0]?.text;
    } catch (error) {
      console.error('Gemini chat API error:', error);
      return `I encountered an issue connecting to the Gemini AI API. Here is a local analysis: 
      Please ensure your \`GEMINI_API_KEY\` is loaded. Current sensor readings look stable, but monitor Zone A soil moisture as it is showing higher temperatures.`;
    }
  },

  /**
   * Generates a comprehensive agricultural report based on recent telemetry and recommendations
   */
  async generateReport(telemetryHistory, recommendations, weather) {
    if (config.isMockMode) {
      return getMockFarmReport(telemetryHistory[0] || {}, recommendations, weather);
    }

    try {
      const prompt = `
      You are the chief AI agronomic analyst for FarmGuardian AI.
      Create a comprehensive, professional farm analysis report in beautiful Markdown format based on this data:
      
      Current Weather:
      ${JSON.stringify(weather, null, 2)}
      
      Telemetry History (latest reading first):
      ${JSON.stringify(telemetryHistory.slice(0, 3), null, 2)}
      
      Active Recommendations (unresolved):
      ${JSON.stringify(recommendations, null, 2)}

      Write a detailed farm status report. Organize it with headers, markdown tables, and checklists. It must include:
      1. Executive Summary: Overall farm condition and weather implications.
      2. Comprehensive Zone Matrix: A markdown table containing Zone name, Crop, Moisture %, Health Status, and Predicted Yield (from the predictions field in telemetry).
      3. Soil & Nutrient Balance: Analysis of soil pH and NPK levels, pointing out any nutrient deficits.
      4. Prescription Review: Summary of active recommendations and treatments.
      5. Actionable Task List: Checklist of actions for the farmer with high/medium/low priority levels.
      
      Output ONLY clean Markdown. Do NOT wrap it in JSON.
      `;

      const response = await ai.models.generateContent({
        model: 'gemini-2.5-flash',
        contents: prompt
      });

      return response.text || response.candidates?.[0]?.content?.parts?.[0]?.text;
    } catch (error) {
      console.error('Gemini report API error, falling back to mock:', error);
      return getMockFarmReport(telemetryHistory[0] || {}, recommendations, weather);
    }
  }
};

function getMockFarmReport(latestTelemetry, recommendations, weather) {
  // Extract zone metrics or fall back to baseline values
  const zoneA = latestTelemetry['Zone A'] || { soilMoisture: 68, status: 'Online', predictions: { expectedYieldTons: 12.5 } };
  const zoneB = latestTelemetry['Zone B'] || { soilMoisture: 56, status: 'Online', predictions: { expectedYieldTons: 8.5 } };
  const zoneC = latestTelemetry['Zone C'] || { soilMoisture: 47, status: 'Online', predictions: { expectedYieldTons: 15.0 } };
  const zoneD = latestTelemetry['Zone D'] || { soilMoisture: 51, status: 'Online', predictions: { expectedYieldTons: 22.0 } };

  const unresolvedRecs = recommendations.filter(r => !r.resolved);

  return `# 🌾 FarmGuardian AI - Autonomous Farm Status Report
**Generated:** ${new Date().toLocaleDateString()} at ${new Date().toLocaleTimeString()}
**Overall Farm Health Index:** 88% (Good)

---

### 📋 Executive Summary
The farm is currently operating under stable parameters, with a warning state active in selected zones due to soil moisture drying. Weather conditions are currently **${weather.condition}** with an average temperature of **${weather.temperature}°C** and humidity at **${weather.humidity}%**.

---

### 📊 Zone Health & Yield Outlook

| Zone | Crop Type | Soil Moisture | Health Status | Yield Projection |
| :--- | :--- | :--- | :--- | :--- |
| **Zone A** | Lettuce Field | ${zoneA.soilMoisture}% | ${zoneA.status} | ${zoneA.predictions?.expectedYieldTons || 12.5} / 12.5 Tons |
| **Zone B** | Apple Orchard | ${zoneB.soilMoisture}% | ${zoneB.status} | ${zoneB.predictions?.expectedYieldTons || 8.5} / 8.5 Tons |
| **Zone C** | Vineyard | ${zoneC.soilMoisture}% | ${zoneC.status} | ${zoneC.predictions?.expectedYieldTons || 15.0} / 15.0 Tons |
| **Zone D** | Wheat Fields | ${zoneD.soilMoisture}% | ${zoneD.status} | ${zoneD.predictions?.expectedYieldTons || 22.0} / 22.0 Tons |

---

### 🧪 Nutrient (NPK) & Soil pH Status
- **Zone A (Lettuce):** NPK Ratio is **${zoneA.nitrogen || 140}:${zoneA.phosphorus || 48}:${zoneA.potassium || 210}** mg/kg (Optimal). Soil pH is **${zoneA.ph || 6.2}**.
- **Zone B (Apple):** NPK Ratio is **${zoneB.nitrogen || 110}:${zoneB.phosphorus || 38}:${zoneB.potassium || 195}** mg/kg (Normal). Soil pH is **${zoneB.ph || 6.5}**.
- **Zone C (Vineyard):** NPK Ratio is **${zoneC.nitrogen || 95}:${zoneC.phosphorus || 35}:${zoneC.potassium || 170}** mg/kg (Stable). Soil pH is **${zoneC.ph || 6.8}**.
- **Zone D (Wheat):** NPK Ratio is **${zoneD.nitrogen || 130}:${zoneD.phosphorus || 42}:${zoneD.potassium || 205}** mg/kg (Balanced). Soil pH is **${zoneD.ph || 6.0}**.

---

### 🛠️ Active Recommendations & Prescriptions
${unresolvedRecs.length === 0 ? '*No critical issues detected. Soil chemistry and irrigation parameters are fully optimized.*' : 
unresolvedRecs.map(r => `- **[${r.severity.toUpperCase()}] ${r.title} (${r.zone}):** ${r.description} (Cure: *${r.recommendations?.join(', ') || 'Monitor zone telemetry.'}*)`).join('\n')}

---

### 📅 AI-Recommended Tasks & Operational Checklist
1.  **[High Priority]** Monitor soil moisture in Zones displaying under 45% moisture.
2.  **[Medium Priority]** Release ladybugs in Zone B if Aphid vectors rise.
3.  **[Info]** Standard automated multispectral drone sweeps scheduled every 25 seconds.
`;
}

