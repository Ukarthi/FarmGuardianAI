# FarmGuardian AI 🌾🛸

FarmGuardian AI is an autonomous, AI-powered precision agriculture platform built for the **Google AI Hackathon**.

The platform continuously monitors a simulated farm across four distinct crop zones using simulated IoT sensors and weather metrics. It leverages **Google Gemini 3.5 Flash / Pro** as an autonomous decision engine to auditor telemetry. When the AI determines that visual inspection is required, it triggers a drone survey, receives captured imagery, diagnoses crop conditions (pest infestation, fungal disease, drought, nutrient deficiency), and registers actionable agronomic prescriptions—all synchronized in a visually stunning glassmorphic HUD dashboard.

---

## 🚀 Key Features

*   **Autonomous AI Decision Loop:** The backend regularly audits sensor telemetry and forecast conditions, deciding if a visual drone inspection is required.
*   **Multispectral Drone Visual Diagnostics:** Simulates high-resolution crop scans which are analyzed by Gemini to identify stress severity, biological pests, diseases, and water loss.
*   **Weather Control Console:** Trigger severe weather events (Frost, Heatwaves, Storms) manually to test system responsiveness and watch sensors decay/recover.
*   **Interactive HUD Dashboard:** Real-time charting, drone flight path visualizer, recommendations, and Farm Memory log timeline.
*   **Gemini Farm AI Consultant:** A chat interface contextually aware of the current farm conditions, history, and active recommendations.

---

## 🛠️ Technology Stack

*   **Frontend:** React + Vite + Vanilla CSS (Glassmorphism & animated dark theme styling)
*   **Data Visualization:** Recharts
*   **Icons:** Lucide React
*   **Backend:** Node.js + Express (ES Modules)
*   **AI Engine:** Google Gen AI SDK (`@google/genai`)
*   **Farm Memory Database:** Lightweight, serverless JSON database (Zero native build dependencies!)

---

## 📂 Project Structure

```text
FarmGuardianAI/
├── backend/
│   ├── src/
│   │   ├── config.js         # API and Env configuration
│   │   ├── index.js          # Express endpoints & simulation cycles
│   │   └── services/         # Gemini, weather, sensor, & DB services
│   ├── .env                  # Port & API Keys configuration
│   └── package.json
├── frontend/
│   ├── src/
│   │   ├── App.jsx           # Dashboard Core UI View
│   │   ├── index.css         # Glassmorphic Custom Theme
│   │   └── main.jsx          # Mount Entrypoint
│   ├── index.html
│   ├── vite.config.js        # Vite + React configuration with Proxy
│   └── package.json
└── package.json              # Monorepo Launcher scripts
```

---

## ⚙️ Quick Start Setup

### Prerequisites
Make sure you have [Node.js (v18+)](https://nodejs.org/) and `npm` installed on your machine.

### 1. Install Dependencies
In the root directory, run the install script to bootstrap both frontend and backend dependencies:
```bash
npm run install:all
```

### 2. Configure Gemini API Key
To enable live Gemini AI integration:
1. Navigate to `backend/.env`
2. Enter your API Key from Google AI Studio:
   ```env
   GEMINI_API_KEY=your_actual_gemini_api_key
   ```
*(Note: If left empty, the application runs in a fully functional **Simulation Mode** using structured mock responses so the dashboard is immediately interactive and demonstrable out of the box).*

### 3. Run the Platform
Launch both backend and frontend development servers concurrently:
```bash
npm run dev
```

The application will launch at:
*   **Frontend Dashboard:** [http://localhost:5173](http://localhost:5173)
*   **Backend API:** [http://localhost:5000](http://localhost:5000)

---

## 🧪 Interaction Walkthrough

1.  **Launch Dashboard:** Open [http://localhost:5173](http://localhost:5173). Notice normal, baseline sunny telemetry ticking.
2.  **Trigger Anomaly:** In the **IoT Zone Telemetry Grid**, click the dropdown for **Zone A (Lettuce Field)** and select **Pest Attack**.
3.  **Watch Autonomous Trigger:** 
    *   The sensor state changes to `Warning`.
    *   Within 25 seconds, the scheduled **Gemini Telemetry Audit** will evaluate the warning.
    *   Gemini will trigger an autonomous drone inspection, prompting a banner on the screen: `LAUNCHING AUTONOMOUS INSPECTION SWEEP...`.
4.  **Observe Drone Sweep:** The drone progresses from **Launching** ➡️ **Active (Flight)** ➡️ **Scanning (Camera active)**.
5.  **View Diagnostics:** Once completed, check the **Drone Inspection Analytics** pane. You will see a detailed visual crop feed and a diagnosis detailing *Pest Infestation (Aphids & Spider Mites)* with specific organic agronomy recommendations.
6.  **Review Farm Memory:** Review the timeline in the bottom right showing all chronological event logs.
7.  **Consult AI:** In the chat panel, ask: *"How should I treat the pest issue in the Apple Orchard?"* The Gemini model will answer contextually, recommending neem oil treatments and ladybug biological controls.
