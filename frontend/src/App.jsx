import React, { useState, useEffect, useRef } from 'react';
import {
  Activity,
  Wind,
  Droplets,
  Thermometer,
  Database,
  Navigation,
  Battery,
  Send,
  Cpu,
  Trash2,
  CloudLightning,
  AlertTriangle,
  Sparkles,
  CheckCircle2,
  RotateCcw,
  Gauge,
  Sprout,
  HelpCircle,
  FileText,
  Bell,
  Sliders,
  Upload,
  Camera,
  Layers,
  ChevronRight,
  Map
} from 'lucide-react';
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer
} from 'recharts';
import { SAMPLE_CROP_IMAGES } from './assets/sampleCropImages';
import farmSatelliteMap from './assets/farm_satellite_map.png';

// Custom simulated SVG Crop Views representing the "Drone Multispectral Cam Feed"
function CropCamFeed({ condition, zone }) {
  const getColorsAndPaths = () => {
    switch (condition) {
      case 'drought':
        return {
          bgColor: '#2a1a08',
          borderColor: '#f59e0b',
          textColor: '#f59e0b',
          label: 'CRITICAL DRINESS DETECTED',
          elements: (
            <>
              <path d="M 10,150 L 190,150 M 50,150 L 80,190 M 120,150 L 100,185 M 150,150 L 170,180" stroke="#4a3525" strokeWidth="3" />
              <path d="M 100,150 C 95,110 80,95 65,95 C 65,95 75,110 95,130" fill="none" stroke="#855b32" strokeWidth="4" />
              <path d="M 100,150 C 105,100 125,85 135,90 C 135,90 120,105 105,135" fill="none" stroke="#855b32" strokeWidth="4" />
              <path d="M 65,95 C 50,95 40,110 45,120 C 50,110 60,100 65,95 Z" fill="#786c3b" />
              <path d="M 135,90 C 145,95 150,110 145,120 C 140,110 135,95 135,90 Z" fill="#786c3b" />
            </>
          )
        };
      case 'pests':
        return {
          bgColor: '#1c1b18',
          borderColor: '#ef4444',
          textColor: '#ef4444',
          label: 'INSECT INFESTATION DETECTED',
          elements: (
            <>
              <path d="M 100,160 Q 95,100 100,50" fill="none" stroke="#059669" strokeWidth="4" />
              <path d="M 100,120 C 60,100 70,80 100,100 Z" fill="#047857" />
              <circle cx="75" cy="95" r="4" fill="#1c1b18" />
              <circle cx="82" cy="90" r="3" fill="#1c1b18" />
              <path d="M 100,80 C 140,60 130,40 100,60 Z" fill="#047857" />
              <circle cx="120" cy="55" r="4" fill="#ef4444" />
              <line x1="120" y1="55" x2="124" y2="51" stroke="#ef4444" strokeWidth="1" />
              <line x1="120" y1="55" x2="116" y2="59" stroke="#ef4444" strokeWidth="1" />
              <line x1="120" y1="55" x2="124" y2="59" stroke="#ef4444" strokeWidth="1" />
              <circle cx="85" cy="110" r="4" fill="#ef4444" />
              <line x1="85" y1="110" x2="89" y2="106" stroke="#ef4444" strokeWidth="1" />
              <line x1="85" y1="110" x2="81" y2="114" stroke="#ef4444" strokeWidth="1" />
            </>
          )
        };
      case 'disease':
        return {
          bgColor: '#161c24',
          borderColor: '#8b5cf6',
          textColor: '#c084fc',
          label: 'BIOLOGICAL DISEASE SPOTS DETECTED',
          elements: (
            <>
              <path d="M 100,160 Q 105,100 100,50" fill="none" stroke="#10b981" strokeWidth="4" />
              <path d="M 100,110 C 60,100 65,70 100,90 Z" fill="#047857" />
              <path d="M 100,75 C 140,65 135,35 100,55 Z" fill="#047857" />
              <circle cx="78" cy="92" r="5" fill="rgba(255,255,255,0.7)" />
              <circle cx="88" cy="85" r="3" fill="rgba(255,255,255,0.6)" />
              <circle cx="118" cy="58" r="6" fill="rgba(255,255,255,0.7)" />
              <circle cx="125" cy="50" r="4" fill="rgba(255,255,255,0.6)" />
            </>
          )
        };
      case 'nutrient_def':
        return {
          bgColor: '#1d231e',
          borderColor: '#eab308',
          textColor: '#eab308',
          label: 'NPK NUTRIENT DEFICIT (CHLOROSIS)',
          elements: (
            <>
              <path d="M 100,160 Q 98,90 100,50" fill="none" stroke="#854d0e" strokeWidth="4" />
              <path d="M 100,120 C 60,110 60,80 100,100 Z" fill="#ca8a04" />
              <path d="M 100,80 C 140,70 140,40 100,60 Z" fill="#ca8a04" />
              <path d="M 100,100 C 85,98 75,98 70,102 M 85,98 L 88,94 M 78,99 L 80,95" stroke="#15803d" strokeWidth="2" fill="none" />
              <path d="M 100,60 C 115,58 125,58 130,62 M 115,58 L 112,54 M 125,59 L 122,55" stroke="#15803d" stroke-width="2" fill="none" />
            </>
          )
        };
      case 'healthy':
      default:
        return {
          bgColor: '#08251e',
          borderColor: '#10b981',
          textColor: '#10b981',
          label: 'OPTIMAL VEGETATION TURGOR',
          elements: (
            <>
              <path d="M 100,160 Q 100,100 100,40" fill="none" stroke="#059669" strokeWidth="5" />
              <path d="M 100,115 C 50,95 60,65 100,85 Z" fill="#10b981" />
              <path d="M 100,75 C 150,55 140,25 100,45 Z" fill="#10b981" />
              <circle cx="80" cy="85" r="2.5" fill="#38bdf8" opacity="0.8" />
              <circle cx="120" cy="48" r="2.5" fill="#38bdf8" opacity="0.8" />
            </>
          )
        };
    }
  };

  const config = getColorsAndPaths();

  return (
    <div style={{ position: 'relative', width: '100%', height: '220px', borderRadius: '16px', background: config.bgColor, border: `2px solid ${config.borderColor}`, overflow: 'hidden' }}>
      <div style={{ position: 'absolute', top: '8px', left: '10px', fontSize: '10px', fontFamily: 'var(--font-mono)', color: config.textColor, letterSpacing: '1px', fontWeight: 'bold' }}>
        🎥 D-CAM MULTISPECTRAL [LIVE]
      </div>
      <div style={{ position: 'absolute', top: '8px', right: '10px', fontSize: '10px', fontFamily: 'var(--font-mono)', color: '#9ca3af' }}>
        ZONE: {zone}
      </div>
      
      <svg width="100%" height="100%" viewBox="0 0 200 200" style={{ display: 'block' }}>
        <circle cx="100" cy="100" r="85" stroke="rgba(255,255,255,0.03)" strokeWidth="1" fill="none" />
        <circle cx="100" cy="100" r="50" stroke="rgba(255,255,255,0.05)" strokeWidth="1" strokeDasharray="4 4" fill="none" />
        <line x1="100" y1="10" x2="100" y2="190" stroke="rgba(255,255,255,0.03)" strokeWidth="1" />
        <line x1="10" y1="100" x2="190" y2="100" stroke="rgba(255,255,255,0.03)" strokeWidth="1" />
        {config.elements}
      </svg>

      <div style={{ position: 'absolute', bottom: '8px', left: '10px', right: '10px', textAlign: 'center', background: 'rgba(0,0,0,0.6)', padding: '4px', borderRadius: '4px', fontSize: '11px', color: '#fff', fontWeight: '500', letterSpacing: '0.5px', border: `1px solid ${config.borderColor}80` }}>
        STATUS: {config.label}
      </div>
    </div>
  );
}

export default function App() {
  // Navigation State
  const [activeTab, setActiveTab] = useState('dashboard'); // dashboard, analyzer, reports, notifications, logs

  // Global States
  const [sensors, setSensors] = useState({});
  const [weather, setWeather] = useState({ current: {}, forecast: [] });
  const [missions, setMissions] = useState([]);
  const [recommendations, setRecommendations] = useState([]);
  const [logs, setLogs] = useState([]);
  const [telemetryHistory, setTelemetryHistory] = useState([]);
  const [notifications, setNotifications] = useState([]);
  const [thresholdSettings, setThresholdSettings] = useState({
    moistureThresholdMin: 35,
    moistureThresholdMax: 85,
    tempThresholdMax: 38,
    tempThresholdMin: 5,
    npkThresholdN: 50
  });

  // Control UI state
  const [selectedZone, setSelectedZone] = useState('Zone A');
  const [selectedMapZone, setSelectedMapZone] = useState('Zone A');
  const [selectedMetric, setSelectedMetric] = useState('soilMoisture');
  const [chatMessage, setChatMessage] = useState('');
  const [chatHistory, setChatHistory] = useState([]);
  const [isChatLoading, setIsChatLoading] = useState(false);
  const [isManualLaunching, setIsManualLaunching] = useState(false);
  const [isConnected, setIsConnected] = useState(true);

  // Visual Analyzer States
  const [selectedSpecimen, setSelectedSpecimen] = useState(SAMPLE_CROP_IMAGES[0]);
  const [isAnalyzingImage, setIsAnalyzingImage] = useState(false);
  const [workbenchDiagnosis, setWorkbenchDiagnosis] = useState(null);
  const fileInputRef = useRef(null);

  // Reports States
  const [isGeneratingReport, setIsGeneratingReport] = useState(false);
  const [activeReportText, setActiveReportText] = useState('');

  // Active mission flight state machine (controlled by frontend simulation)
  const [activeFlight, setActiveFlight] = useState(null); // { id, zone, status, progress, battery }
  const flightTimer = useRef(null);

  // Poll server data
  const fetchData = async () => {
    try {
      const wRes = await fetch('/api/weather');
      const wData = await wRes.json();
      setWeather(wData);

      const sRes = await fetch('/api/sensors');
      const sData = await sRes.json();
      setSensors(sData);

      const mRes = await fetch('/api/drone/missions');
      const mData = await mRes.json();
      setMissions(mData);

      const rRes = await fetch('/api/recommendations');
      const rData = await rRes.json();
      setRecommendations(rData);

      const lRes = await fetch('/api/logs');
      const lData = await lRes.json();
      setLogs(lData);

      const hRes = await fetch('/api/sensors/history?limit=30');
      const hData = await hRes.json();
      setTelemetryHistory(hData);

      const nRes = await fetch('/api/notifications');
      const nData = await nRes.json();
      setNotifications(nData);

      const tRes = await fetch('/api/notifications/settings');
      const tData = await tRes.json();
      setThresholdSettings(tData);

      setIsConnected(true);
    } catch (err) {
      console.error('Failed to connect to backend server:', err);
      setIsConnected(false);
    }
  };

  useEffect(() => {
    fetchData();
    const interval = setInterval(fetchData, 3000);
    return () => clearInterval(interval);
  }, []);

  // Watch DB missions for newly triggered launching missions (autonomous or manual)
  useEffect(() => {
    if (missions.length > 0) {
      const latestMission = missions[0]; // database lists latest first
      if (latestMission && latestMission.status === 'launching' && (!activeFlight || activeFlight.id !== latestMission.id)) {
        startDroneFlightSim(latestMission);
      }
    }
  }, [missions]);

  // Simulated Drone flight sequencer
  const startDroneFlightSim = (mission) => {
    if (flightTimer.current) clearInterval(flightTimer.current);

    let progress = 0;
    let currentStatus = 'launching';
    let battery = 100;

    setActiveFlight({
      id: mission.id,
      zone: mission.zone,
      status: currentStatus,
      progress,
      battery,
      reason: mission.reason
    });

    flightTimer.current = setInterval(async () => {
      progress += 10;
      battery -= 2;

      if (progress === 30) {
        currentStatus = 'active'; // Transit flight
        await fetch(`/api/drone/mission/${mission.id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ status: 'active', battery })
        });
      } else if (progress === 60) {
        currentStatus = 'scanning'; // Collecting multispectral imagery
        await fetch(`/api/drone/mission/${mission.id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ status: 'scanning', battery })
        });
      } else if (progress >= 100) {
        clearInterval(flightTimer.current);
        currentStatus = 'completed';
        
        // Find which anomaly is active in the zone to trigger the mock image diagnosis
        const zoneInfo = sensors[mission.zone] || {};
        const activeAnomaly = zoneInfo.anomalies?.[0] || 'none';

        // Trigger Gemini analysis of mock image
        await fetch(`/api/drone/mission/${mission.id}/complete`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            imageBase64: 'simulated_multispectral_matrix_stream',
            activeAnomaly
          })
        });

        setActiveFlight(null);
        fetchData();
        return;
      }

      setActiveFlight(prev => ({
        ...prev,
        status: currentStatus,
        progress,
        battery
      }));
    }, 1200);
  };

  // Trigger manual Drone Launch
  const handleLaunchDrone = async (zone) => {
    try {
      setIsManualLaunching(true);
      await fetch('/api/drone/launch', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ zone, reason: `Manual operator initiated checkup of ${zone}.` })
      });
      fetchData();
    } catch (err) {
      console.error(err);
    } finally {
      setIsManualLaunching(false);
    }
  };

  // Trigger Anomaly
  const handleTriggerAnomaly = async (zone, anomaly) => {
    try {
      await fetch('/api/sensors/anomaly', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ zone, anomaly })
      });
      fetchData();
    } catch (err) {
      console.error(err);
    }
  };

  // Trigger Weather event
  const handleWeatherChange = async (event) => {
    try {
      await fetch('/api/weather/event', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ event })
      });
      fetchData();
    } catch (err) {
      console.error(err);
    }
  };

  // Resolve recommendation
  const handleResolveRecommendation = async (id) => {
    try {
      await fetch(`/api/recommendations/${id}/resolve`, {
        method: 'POST'
      });
      fetchData();
    } catch (err) {
      console.error(err);
    }
  };

  // Chat Consult API
  const handleSendChat = async (e) => {
    e.preventDefault();
    if (!chatMessage.trim() || isChatLoading) return;

    const userMsg = { role: 'user', message: chatMessage };
    setChatHistory(prev => [...prev, userMsg]);
    setChatMessage('');
    setIsChatLoading(true);

    try {
      const response = await fetch('/api/consult', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          message: userMsg.message,
          history: chatHistory
        })
      });
      const data = await response.json();
      setChatHistory(prev => [...prev, { role: 'bot', message: data.response }]);
    } catch (err) {
      console.error(err);
      setChatHistory(prev => [...prev, { role: 'bot', message: 'Offline connection error. Unable to query Gemini.' }]);
    } finally {
      setIsChatLoading(false);
    }
  };

  // Reset System
  const handleResetSystem = async () => {
    try {
      if (confirm('Are you sure you want to reset all Farm Memory database records?')) {
        await fetch('/api/reset', { method: 'POST' });
        setChatHistory([]);
        setActiveFlight(null);
        setWorkbenchDiagnosis(null);
        setActiveReportText('');
        if (flightTimer.current) clearInterval(flightTimer.current);
        fetchData();
      }
    } catch (err) {
      console.error(err);
    }
  };

  // Notifications API handlers
  const handleMarkNotifRead = async (id) => {
    try {
      await fetch('/api/notifications/read', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id })
      });
      fetchData();
    } catch (err) {
      console.error(err);
    }
  };

  const handleMarkAllNotifsRead = async () => {
    try {
      await fetch('/api/notifications/read', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ all: true })
      });
      fetchData();
    } catch (err) {
      console.error(err);
    }
  };

  const handleUpdateThresholdSettings = async (e) => {
    e.preventDefault();
    try {
      await fetch('/api/notifications/settings', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(thresholdSettings)
      });
      alert('Threshold configurations saved successfully!');
      fetchData();
    } catch (err) {
      console.error(err);
    }
  };

  // Visual Diagnostic workbench Scan
  const handleDiagnoseSpecimen = async () => {
    if (!selectedSpecimen) return;
    setIsAnalyzingImage(true);
    setWorkbenchDiagnosis(null);

    try {
      // Step 1: Create a manual inspection sweep for the selected zone
      const launchRes = await fetch('/api/drone/launch', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
          zone: selectedZone, 
          reason: `Specimen analysis Workbench: ${selectedSpecimen.name}` 
        })
      });
      const launchData = await launchRes.json();
      const missionId = launchData.mission.id;

      // Step 2: Call the completion logic with the selected image base64
      const completeRes = await fetch(`/api/drone/mission/${missionId}/complete`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          imageBase64: selectedSpecimen.dataUri.split(',')[1] || selectedSpecimen.dataUri,
          activeAnomaly: selectedSpecimen.anomalyType
        })
      });
      const completeData = await completeRes.json();
      setWorkbenchDiagnosis(completeData.mission.diagnostics);
      
      // Seed recommendation list updates
      fetchData();
    } catch (error) {
      console.error('Diagnosis failed:', error);
      alert('Diagnosis request failed. Check backend console.');
    } finally {
      setIsAnalyzingImage(false);
    }
  };

  // Handle Custom Specimen Upload
  const handleCustomUploadSpecimen = (e) => {
    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onloadend = () => {
      const customSpecimen = {
        id: `custom_${Date.now()}`,
        name: file.name,
        crop: 'Custom Upload',
        anomalyType: 'pests', // default to analyze for pests
        description: `Uploaded specimen specimen file: ${file.name}. Size: ${(file.size/1024).toFixed(1)} KB.`,
        dataUri: reader.result
      };
      setSelectedSpecimen(customSpecimen);
    };
    reader.readAsDataURL(file);
  };

  // Generate AI Farm report
  const handleGenerateAIReport = async () => {
    setIsGeneratingReport(true);
    setActiveReportText('');
    try {
      const response = await fetch('/api/reports/generate', { method: 'POST' });
      const data = await response.json();
      setActiveReportText(data.report);
    } catch (err) {
      console.error(err);
      alert('Failed to connect to backend for AI reports generation.');
    } finally {
      setIsGeneratingReport(false);
    }
  };

  // Helper for Zone Health Color coding on the Map
  const getZoneHealth = (zoneName) => {
    const data = sensors[zoneName];
    if (!data) return { color: 'var(--md-sys-color-primary)', label: 'Optimal', name: 'Green', class: 'badge-success' };
    const hasAnomalies = data.anomalies && data.anomalies.length > 0;
    if (hasAnomalies) {
      if (data.anomalies.includes('drought') || data.anomalies.includes('nutrient_def')) {
        return { color: 'var(--md-sys-color-error)', label: 'Critical', name: 'Red', class: 'badge-danger' };
      }
      return { color: 'var(--md-sys-color-warning)', label: 'Warning', name: 'Yellow', class: 'badge-warning' };
    }
    if (data.status === 'Warning') {
      return { color: 'var(--md-sys-color-warning)', label: 'Warning', name: 'Yellow', class: 'badge-warning' };
    }
    return { color: 'var(--md-sys-color-primary)', label: 'Optimal', name: 'Green', class: 'badge-success' };
  };

  // Helper to retrieve last inspection relative time
  const getZoneLastInspection = (zoneName) => {
    const completedMissions = missions.filter(m => m.zone === zoneName && m.status === 'completed');
    if (completedMissions.length === 0) return 'No inspection logs';
    const sorted = [...completedMissions].sort((a, b) => new Date(b.updatedAt || b.timestamp) - new Date(a.updatedAt || a.timestamp));
    const latest = sorted[0];
    const time = latest.updatedAt || latest.timestamp;
    
    const date = new Date(time);
    const now = new Date();
    const diffMs = now - date;
    const diffMins = Math.floor(diffMs / 60000);
    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins} mins ago`;
    const diffHours = Math.floor(diffMins / 60);
    if (diffHours < 24) return `${diffHours} hours ago`;
    return date.toLocaleDateString();
  };

  // Process telemetry data for chart
  const getChartData = () => {
    return [...telemetryHistory].reverse().map(tick => {
      const time = new Date(tick.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });
      const zoneData = tick[selectedZone] || {};
      return {
        time,
        value: zoneData[selectedMetric] || 0
      };
    });
  };

  // Helper labels
  const metricLabels = {
    soilMoisture: 'Soil Moisture (%)',
    temperature: 'Temperature (°C)',
    ph: 'Soil pH',
    nitrogen: 'Nitrogen (N) mg/kg',
    phosphorus: 'Phosphorus (P) mg/kg',
    potassium: 'Potassium (K) mg/kg'
  };

  // Basic on-the-fly markdown parsing helper to style the generated farm report
  const renderMarkdown = (text) => {
    if (!text) return <p style={{ color: 'var(--text-secondary)', fontStyle: 'italic' }}>Click the button below to generate a real-time status summary report using Gemini AI.</p>;
    
    return text.split('\n').map((line, idx) => {
      if (line.startsWith('# ')) {
        return <h1 key={idx} style={{ fontSize: '24px', fontWeight: 'bold', margin: '20px 0 10px 0', borderBottom: '1px solid var(--md-sys-color-outline)', paddingBottom: '6px' }}>{line.slice(2)}</h1>;
      }
      if (line.startsWith('## ')) {
        return <h2 key={idx} style={{ fontSize: '18px', fontWeight: 'bold', margin: '16px 0 8px 0', color: 'var(--md-sys-color-primary)' }}>{line.slice(3)}</h2>;
      }
      if (line.startsWith('### ')) {
        return <h3 key={idx} style={{ fontSize: '15px', fontWeight: 'semibold', margin: '14px 0 6px 0', color: 'var(--md-sys-color-secondary)' }}>{line.slice(4)}</h3>;
      }
      if (line.startsWith('---')) {
        return <hr key={idx} style={{ border: 'none', height: '1px', background: 'var(--md-sys-color-outline)', margin: '16px 0' }} />;
      }
      if (line.startsWith('- ') || line.startsWith('* ')) {
        return <li key={idx} style={{ marginLeft: '20px', marginBottom: '4px', fontSize: '13px' }}>{line.slice(2)}</li>;
      }
      if (line.startsWith('|')) {
        if (line.includes(':---') || line.includes('---:')) return null;
        const cells = line.split('|').map(c => c.trim()).filter((c, i) => i > 0 && i < line.split('|').length - 1);
        const isHeader = idx === 0 || text.split('\n')[idx - 2]?.startsWith('###');
        return (
          <div key={idx} style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', padding: '8px', borderBottom: '1px solid var(--md-sys-color-outline)', background: isHeader ? 'rgba(255,255,255,0.05)' : 'transparent', fontWeight: isHeader ? 'bold' : 'normal', fontSize: '12px' }}>
            {cells.map((cell, cIdx) => <span key={cIdx}>{cell}</span>)}
          </div>
        );
      }
      return <p key={idx} style={{ margin: '6px 0', fontSize: '13px', lineHeight: '1.5', color: 'var(--text-secondary)' }}>{line}</p>;
    });
  };

  const unreadNotifCount = notifications.filter(n => !n.read).length;

  return (
    <div className="app-container">
      
      {/* 1. Left MD3 Navigation Drawer */}
      <aside className="nav-drawer">
        <div className="nav-logo">
          <div style={{ background: 'var(--md-sys-color-primary-container)', padding: '8px', borderRadius: '12px', display: 'flex', alignItems: 'center' }}>
            <Sprout size={24} color="var(--md-sys-color-primary)" />
          </div>
          <div>
            <h2 style={{ fontSize: '16px', fontWeight: '800', color: '#fff', letterSpacing: '0.5px' }}>FarmGuardian</h2>
            <p style={{ fontSize: '9px', color: 'var(--text-secondary)', fontFamily: 'var(--font-mono)' }}>PRECISION ENGINE</p>
          </div>
        </div>

        <nav className="nav-items">
          <div 
            className={`nav-item ${activeTab === 'dashboard' ? 'nav-item-active' : ''}`}
            onClick={() => setActiveTab('dashboard')}
          >
            <Activity size={20} />
            <span>Dashboard</span>
          </div>

          <div 
            className={`nav-item ${activeTab === 'map' ? 'nav-item-active' : ''}`}
            onClick={() => setActiveTab('map')}
          >
            <Map size={20} />
            <span>Farm Map</span>
          </div>

          <div 
            className={`nav-item ${activeTab === 'analyzer' ? 'nav-item-active' : ''}`}
            onClick={() => setActiveTab('analyzer')}
          >
            <Camera size={20} />
            <span>Visual Analyzer</span>
          </div>

          <div 
            className={`nav-item ${activeTab === 'reports' ? 'nav-item-active' : ''}`}
            onClick={() => setActiveTab('reports')}
          >
            <FileText size={20} />
            <span>Reports Center</span>
          </div>

          <div 
            className={`nav-item ${activeTab === 'notifications' ? 'nav-item-active' : ''}`}
            onClick={() => setActiveTab('notifications')}
          >
            <Bell size={20} />
            <span>Alerts Box</span>
            {unreadNotifCount > 0 && <span className="nav-item-badge">{unreadNotifCount}</span>}
          </div>

          <div 
            className={`nav-item ${activeTab === 'logs' ? 'nav-item-active' : ''}`}
            onClick={() => setActiveTab('logs')}
          >
            <Cpu size={20} />
            <span>AI Memory Chat</span>
          </div>
        </nav>

        {/* Connection & Footer info */}
        <div style={{ borderTop: '1px solid var(--md-sys-color-outline)', paddingTop: '16px', marginTop: 'auto' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '11px', color: 'var(--text-secondary)', marginBottom: '8px' }}>
            <span className={`status-indicator ${isConnected ? 'status-online' : 'status-danger'}`}></span>
            <span>{isConnected ? 'LIVE INTERFACE' : 'OFFLINE MODE'}</span>
          </div>
          <button className="md3-btn" onClick={handleResetSystem} style={{ width: '100%', padding: '8px 12px', fontSize: '12px' }}>
            <RotateCcw size={12} /> Reset Database
          </button>
        </div>
      </aside>

      {/* 2. Main Work Content Area */}
      <main className="main-content">
        
        {/* Connection status banner */}
        {!isConnected && (
          <div style={{ background: 'var(--md-sys-color-error)', color: '#fff', padding: '8px', borderRadius: '12px', textAlign: 'center', fontSize: '12px', fontWeight: 'bold', letterSpacing: '1px', marginBottom: '20px' }}>
            ⚠️ DISCONNECTED FROM BACKEND API. TELEMETRY STANDBY.
          </div>
        )}

        {/* Global Active Flight Drone Sweep Banner */}
        {activeFlight && (
          <div className="md3-card hud-panel hud-panel-secondary" style={{ padding: '14px 20px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', background: 'rgba(0, 229, 255, 0.05)', marginBottom: '20px', border: '1px solid rgba(0, 229, 255, 0.2)' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
              <Navigation size={20} className="glow-text-cyan animate-spin" color="var(--md-sys-color-secondary)" style={{ animationDuration: '3s' }} />
              <div>
                <h4 style={{ color: 'var(--md-sys-color-secondary)', fontWeight: '700', fontSize: '14px' }}>
                  {activeFlight.status === 'launching' ? 'LAUNCHING AUTONOMOUS INSPECTION SWEEP...' : 
                   activeFlight.status === 'active' ? 'DRONE TRANSITING FLIGHT PATH...' : 
                   activeFlight.status === 'scanning' ? 'CONDUCTING CROP SCAN ANALYSIS...' : 'FLIGHT COMPLETE'}
                </h4>
                <p style={{ fontSize: '12px', color: 'var(--text-secondary)', marginTop: '2px' }}>
                  Drone ID: <span className="text-mono" style={{ color: '#fff' }}>DG-880</span> | Target: <span style={{ color: '#fff' }}>{activeFlight.zone}</span> | Cause: {activeFlight.reason}
                </p>
              </div>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
              <div style={{ width: '120px', background: 'rgba(255,255,255,0.05)', borderRadius: '4px', height: '8px', overflow: 'hidden' }}>
                <div style={{ width: `${activeFlight.progress}%`, background: 'var(--md-sys-color-secondary)', height: '100%', transition: 'width 0.5s ease-out' }}></div>
              </div>
              <span className="text-mono" style={{ fontSize: '12px', color: 'var(--md-sys-color-secondary)' }}>{activeFlight.progress}%</span>
            </div>
          </div>
        )}

        {/* Active Tab rendering */}
        
        {/* ==================== TAB 1: DASHBOARD ==================== */}
        {activeTab === 'dashboard' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            
            {/* Header Title */}
            <div className="flex-between">
              <div>
                <h1 style={{ fontSize: '28px', fontWeight: '800' }}>Farm HUD Command</h1>
                <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>Real-time simulated precision IoT monitoring cockpit</p>
              </div>
              <div style={{ display: 'flex', gap: '10px' }}>
                <div className="md3-card text-mono" style={{ background: '#0d1120', padding: '8px 16px', borderRadius: '12px', fontSize: '11px', display: 'flex', alignItems: 'center', gap: '12px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                    <span className="status-indicator status-online"></span>
                    <span>MD3 ENGINE</span>
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                    <span className="status-indicator status-online"></span>
                    <span>GEMINI AUDIT</span>
                  </div>
                </div>
              </div>
            </div>

            {/* IoT Telemetry grid */}
            <section className="md3-card">
              <h3 style={{ fontSize: '16px', fontWeight: '600', marginBottom: '14px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                <Activity size={18} color="var(--md-sys-color-primary)" /> IoT Zone Telemetry Grid
              </h3>
              <div className="grid-4">
                {Object.entries(sensors).map(([zone, data]) => {
                  const isWarning = data.status === 'Warning';
                  const hasAnomalies = data.anomalies && data.anomalies.length > 0;
                  
                  return (
                    <div key={zone} className={`md3-card ${isWarning ? 'hud-panel-error' : 'hud-panel-primary'}`} style={{ padding: '16px', background: isWarning ? 'rgba(255, 82, 82, 0.02)' : 'rgba(0, 230, 118, 0.01)' }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
                        <div>
                          <h4 style={{ fontWeight: '700', fontSize: '14px' }}>{zone}</h4>
                          <p style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>{data.cropName}</p>
                        </div>
                        <span className={`status-indicator ${isWarning ? 'status-danger' : 'status-online'}`}></span>
                      </div>

                      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px', fontSize: '12px', marginBottom: '12px' }}>
                        <div>
                          <span style={{ color: 'var(--text-secondary)' }}>Moisture:</span>
                          <div style={{ fontWeight: '600', color: data.soilMoisture < thresholdSettings.moistureThresholdMin ? 'var(--md-sys-color-error)' : '#fff' }}>{data.soilMoisture}%</div>
                        </div>
                        <div>
                          <span style={{ color: 'var(--text-secondary)' }}>Temp:</span>
                          <div style={{ fontWeight: '600' }}>{data.temperature}°C</div>
                        </div>
                        <div>
                          <span style={{ color: 'var(--text-secondary)' }}>pH:</span>
                          <div style={{ fontWeight: '600' }}>{data.ph}</div>
                        </div>
                        <div>
                          <span style={{ color: 'var(--text-secondary)' }}>NPK:</span>
                          <div className="text-mono" style={{ fontSize: '10px', fontWeight: 'bold' }}>
                            {data.nitrogen}:{data.phosphorus}:{data.potassium}
                          </div>
                        </div>
                      </div>

                      {hasAnomalies && (
                        <div style={{ background: 'var(--md-sys-color-error-container)', border: '1px solid rgba(255,82,82,0.2)', padding: '4px 8px', borderRadius: '6px', fontSize: '9px', color: 'var(--md-sys-color-error)', fontWeight: 'bold', marginBottom: '12px', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                          ANOMALY: {data.anomalies.join(', ')}
                        </div>
                      )}

                      <div style={{ display: 'flex', gap: '6px', flexDirection: 'column' }}>
                        <select 
                          className="md3-input" 
                          value="" 
                          onChange={(e) => {
                            if (e.target.value) {
                              handleTriggerAnomaly(zone, e.target.value);
                              e.target.value = '';
                            }
                          }}
                          style={{ padding: '6px', fontSize: '11px' }}
                        >
                          <option value="" disabled>Trigger Stress Anomaly</option>
                          <option value="drought">Drought Stress</option>
                          <option value="pests">Pest Infestation</option>
                          <option value="disease">Fungal Disease</option>
                          <option value="nutrient_def">Nutrient Deficit</option>
                          <option value="clear">Resolve Parameters</option>
                        </select>

                        <button 
                          className="md3-btn" 
                          onClick={() => handleLaunchDrone(zone)}
                          disabled={activeFlight !== null || isManualLaunching}
                          style={{ padding: '6px 12px', fontSize: '11px', width: '100%' }}
                        >
                          Trigger Drone
                        </button>
                      </div>
                    </div>
                  );
                })}
              </div>
            </section>

            {/* Main Graphs and Weather row */}
            <div style={{ display: 'grid', gridTemplateColumns: '8fr 4fr', gap: '20px' }}>
              
              {/* Telemetry charts */}
              <section className="md3-card" style={{ display: 'flex', flexDirection: 'column' }}>
                <div className="flex-between" style={{ marginBottom: '16px' }}>
                  <h3 style={{ fontSize: '16px', fontWeight: '600', display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <Gauge size={18} color="var(--md-sys-color-primary)" /> Historical Telemetry Graph
                  </h3>
                  <div style={{ display: 'flex', gap: '10px' }}>
                    <select className="md3-input" value={selectedZone} onChange={(e) => setSelectedZone(e.target.value)} style={{ padding: '6px 12px', fontSize: '12px' }}>
                      <option value="Zone A">Zone A (Lettuce)</option>
                      <option value="Zone B">Zone B (Apple)</option>
                      <option value="Zone C">Zone C (Vineyard)</option>
                      <option value="Zone D">Zone D (Wheat)</option>
                    </select>

                    <select className="md3-input" value={selectedMetric} onChange={(e) => setSelectedMetric(e.target.value)} style={{ padding: '6px 12px', fontSize: '12px' }}>
                      <option value="soilMoisture">Soil Moisture</option>
                      <option value="temperature">Temperature</option>
                      <option value="ph">Soil pH</option>
                      <option value="nitrogen">Nitrogen</option>
                      <option value="phosphorus">Phosphorus</option>
                      <option value="potassium">Potassium</option>
                    </select>
                  </div>
                </div>

                <div style={{ flexGrow: 1, minHeight: '220px', width: '100%' }}>
                  {telemetryHistory.length === 0 ? (
                    <div style={{ display: 'flex', height: '100%', alignItems: 'center', justifyContent: 'center', color: 'var(--text-secondary)' }}>
                      Awaiting telemetry readings...
                    </div>
                  ) : (
                    <ResponsiveContainer width="100%" height="100%">
                      <AreaChart data={getChartData()} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                        <defs>
                          <linearGradient id="primaryGlow" x1="0" y1="0" x2="0" y2="1">
                            <stop offset="5%" stopColor="var(--md-sys-color-primary)" stopOpacity={0.3}/>
                            <stop offset="95%" stopColor="var(--md-sys-color-primary)" stopOpacity={0}/>
                          </linearGradient>
                        </defs>
                        <CartesianGrid strokeDasharray="3 3" stroke="rgba(255, 255, 255, 0.03)" />
                        <XAxis dataKey="time" stroke="var(--text-secondary)" fontSize={10} tickLine={false} />
                        <YAxis stroke="var(--text-secondary)" fontSize={10} tickLine={false} />
                        <Tooltip 
                          contentStyle={{ background: '#0e1222', border: '1px solid var(--md-sys-color-outline)', borderRadius: '12px' }}
                          labelStyle={{ color: 'var(--text-secondary)', fontSize: '11px', fontFamily: 'var(--font-mono)' }}
                          itemStyle={{ color: 'var(--md-sys-color-primary)', fontSize: '13px', fontWeight: 'bold' }}
                        />
                        <Area 
                          type="monotone" 
                          dataKey="value" 
                          name={metricLabels[selectedMetric]}
                          stroke="var(--md-sys-color-primary)" 
                          strokeWidth={2.5}
                          fillOpacity={1} 
                          fill="url(#primaryGlow)" 
                        />
                      </AreaChart>
                    </ResponsiveContainer>
                  )}
                </div>
              </section>

              {/* Weather command panel */}
              <section className="md3-card" style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
                <h3 style={{ fontSize: '16px', fontWeight: '600', display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <Wind size={18} color="var(--md-sys-color-secondary)" /> Weather Station
                </h3>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px' }}>
                  <div style={{ background: '#0d1120', padding: '10px', borderRadius: '12px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <Thermometer size={16} color="var(--md-sys-color-tertiary)" />
                    <div>
                      <div style={{ fontSize: '9px', color: 'var(--text-secondary)' }}>Temp</div>
                      <div style={{ fontSize: '14px', fontWeight: 'bold' }}>{weather.current?.temperature}°C</div>
                    </div>
                  </div>
                  <div style={{ background: '#0d1120', padding: '10px', borderRadius: '12px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <Droplets size={16} color="var(--md-sys-color-secondary)" />
                    <div>
                      <div style={{ fontSize: '9px', color: 'var(--text-secondary)' }}>Humidity</div>
                      <div style={{ fontSize: '14px', fontWeight: 'bold' }}>{weather.current?.humidity}%</div>
                    </div>
                  </div>
                  <div style={{ background: '#0d1120', padding: '10px', borderRadius: '12px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <Wind size={16} color="var(--text-secondary)" />
                    <div>
                      <div style={{ fontSize: '9px', color: 'var(--text-secondary)' }}>Wind</div>
                      <div style={{ fontSize: '14px', fontWeight: 'bold' }}>{weather.current?.windSpeed}km/h</div>
                    </div>
                  </div>
                  <div style={{ background: '#0d1120', padding: '10px', borderRadius: '12px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <CloudLightning size={16} color="var(--md-sys-color-tertiary)" />
                    <div>
                      <div style={{ fontSize: '9px', color: 'var(--text-secondary)' }}>Status</div>
                      <div style={{ fontSize: '12px', fontWeight: 'bold', color: 'var(--md-sys-color-secondary)' }}>{weather.current?.condition}</div>
                    </div>
                  </div>
                </div>

                {/* Weather Warning */}
                {(weather.current?.stormWarning || weather.current?.frostWarning) && (
                  <div style={{ padding: '8px 12px', borderRadius: '8px', background: 'rgba(255, 82, 82, 0.12)', border: '1px solid rgba(255,82,82,0.2)', color: 'var(--md-sys-color-error)', fontSize: '11px', fontWeight: 'bold', display: 'flex', alignItems: 'center', gap: '6px' }}>
                    <AlertTriangle size={12} />
                    WEATHER EXTREME ACTIVE
                  </div>
                )}

                <div style={{ borderTop: '1px solid var(--md-sys-color-outline)', paddingTop: '12px' }}>
                  <div style={{ fontSize: '11px', color: 'var(--text-secondary)', marginBottom: '6px' }}>Simulate Meteorological Event:</div>
                  <select 
                    className="md3-input" 
                    value={weather.current?.condition === 'Sunny' ? 'normal' : 
                           weather.current?.condition === 'Stormy' ? 'severe_storm' :
                           weather.current?.condition === 'Frosty' ? 'frost_alert' :
                           weather.current?.condition === 'HeatWave' ? 'heat_wave' : 'normal'}
                    onChange={(e) => handleWeatherChange(e.target.value)}
                    style={{ width: '100%', padding: '6px 12px', fontSize: '12px' }}
                  >
                    <option value="normal">Sunny (Baseline)</option>
                    <option value="severe_storm">Severe Thunderstorm</option>
                    <option value="frost_alert">Frost Alert</option>
                    <option value="heat_wave">Heatwave Warning</option>
                  </select>
                </div>
              </section>

            </div>

            {/* Recommendations Row */}
            <section className="md3-card">
              <h3 style={{ fontSize: '16px', fontWeight: '600', marginBottom: '14px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                <Sparkles size={18} color="var(--md-sys-color-tertiary)" /> Active AI Recommendations
              </h3>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                {recommendations.filter(r => !r.resolved).length === 0 ? (
                  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '24px', color: 'var(--text-secondary)', gap: '8px' }}>
                    <CheckCircle2 size={18} color="var(--md-sys-color-primary)" />
                    <span>All fields optimized. No recommendations.</span>
                  </div>
                ) : (
                  recommendations.filter(r => !r.resolved).map(rec => (
                    <div key={rec.id} className="md3-card text-between" style={{ padding: '12px 20px', background: 'rgba(255,255,255,0.01)', display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderLeft: `4px solid ${rec.severity === 'critical' ? 'var(--md-sys-color-error)' : 'var(--md-sys-color-warning)'}` }}>
                      <div>
                        <div style={{ display: 'flex', gap: '8px', alignItems: 'center', marginBottom: '4px' }}>
                          <span style={{ fontSize: '12px', fontWeight: 'bold' }}>{rec.title}</span>
                          <span className="badge badge-info">{rec.zone} ({rec.cropName})</span>
                        </div>
                        <p style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>{rec.description}</p>
                        <div style={{ fontSize: '10px', color: 'var(--md-sys-color-primary)', marginTop: '4px' }}>
                          Prescription: {rec.recommendations?.join(', ')}
                        </div>
                      </div>
                      <button className="md3-btn" onClick={() => handleResolveRecommendation(rec.id)} style={{ padding: '6px 12px', fontSize: '11px', background: 'var(--md-sys-color-primary-container)', color: 'var(--md-sys-color-primary)', border: 'none' }}>
                        Apply Cure
                      </button>
                    </div>
                  ))
                )}
              </div>
            </section>

          </div>
        )}

        {/* ==================== TAB 2: VISUAL ANALYZER ==================== */}
        {activeTab === 'analyzer' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            <div>
              <h1 style={{ fontSize: '28px', fontWeight: '800' }}>Multispectral Visual Analyzer</h1>
              <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>Diagnose crop leaf stress using standard specimens or uploaded photography analyzed by Gemini AI Vision</p>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '4fr 5fr 3fr', gap: '20px', alignItems: 'start' }}>
              
              {/* Left Column: Specimen Selection */}
              <section className="md3-card" style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
                <h3 style={{ fontSize: '15px', fontWeight: '600' }}>1. Choose Diagnostic Specimen</h3>
                
                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                  {SAMPLE_CROP_IMAGES.map((img) => (
                    <div 
                      key={img.id}
                      onClick={() => {
                        setSelectedSpecimen(img);
                        setWorkbenchDiagnosis(null);
                      }}
                      style={{ 
                        padding: '12px', 
                        borderRadius: '12px', 
                        background: selectedSpecimen.id === img.id ? 'var(--md-sys-color-primary-container)' : 'rgba(255,255,255,0.01)', 
                        border: `1px solid ${selectedSpecimen.id === img.id ? 'var(--md-sys-color-primary)' : 'var(--md-sys-color-outline)'}`,
                        cursor: 'pointer',
                        transition: 'all 0.2s'
                      }}
                    >
                      <div style={{ fontSize: '13px', fontWeight: 'bold', display: 'flex', justifyContent: 'space-between' }}>
                        <span>{img.name}</span>
                        <span style={{ fontSize: '9px', color: 'var(--md-sys-color-secondary)' }}>{img.crop}</span>
                      </div>
                      <p style={{ fontSize: '11px', color: 'var(--text-secondary)', marginTop: '4px', lineHeight: '1.3' }}>{img.description}</p>
                    </div>
                  ))}
                </div>

                <div style={{ borderTop: '1px solid var(--md-sys-color-outline)', paddingTop: '14px' }}>
                  <div style={{ fontSize: '12px', color: 'var(--text-secondary)', marginBottom: '8px' }}>Or upload your own leaf specimen:</div>
                  <input 
                    type="file" 
                    accept="image/*" 
                    onChange={handleCustomUploadSpecimen} 
                    style={{ display: 'none' }} 
                    ref={fileInputRef} 
                  />
                  <button 
                    className="md3-btn" 
                    onClick={() => fileInputRef.current.click()} 
                    style={{ width: '100%', fontSize: '12px', gap: '6px' }}
                  >
                    <Upload size={14} /> Upload Custom Photo
                  </button>
                </div>
              </section>

              {/* Middle Column: Workbench Scan View */}
              <section className="md3-card" style={{ display: 'flex', flexDirection: 'column', gap: '14px', alignItems: 'center' }}>
                <h3 style={{ fontSize: '15px', fontWeight: '600', alignSelf: 'flex-start' }}>2. Spectrometer Laboratory Workbench</h3>
                
                <div style={{ position: 'relative', width: '100%', height: '280px', borderRadius: '16px', background: '#090b11', border: '1px solid var(--md-sys-color-outline)', overflow: 'hidden', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  {isAnalyzingImage && <div className="scan-line"></div>}
                  {selectedSpecimen ? (
                    <img 
                      src={selectedSpecimen.dataUri} 
                      alt="Crop Specimen" 
                      style={{ 
                        maxHeight: '100%', 
                        maxWidth: '100%', 
                        objectFit: 'contain',
                        opacity: isAnalyzingImage ? 0.7 : 1,
                        transition: 'opacity 0.2s'
                      }} 
                    />
                  ) : (
                    <div style={{ color: 'var(--text-secondary)', textAlign: 'center', fontSize: '13px' }}>
                      <Camera size={40} style={{ margin: '0 auto 10px auto', display: 'block' }} />
                      No leaf specimen selected.
                    </div>
                  )}
                  {isAnalyzingImage && (
                    <div style={{ position: 'absolute', background: 'rgba(0,0,0,0.7)', color: '#fff', padding: '8px 16px', borderRadius: '100px', fontSize: '12px', fontWeight: 'bold' }}>
                      🔬 SCANNING LEAF CANOPY CELL STRUCTURE...
                    </div>
                  )}
                </div>

                <div style={{ display: 'flex', gap: '10px', width: '100%', marginTop: '8px' }}>
                  <select 
                    className="md3-input" 
                    value={selectedZone} 
                    onChange={(e) => setSelectedZone(e.target.value)}
                    style={{ flexGrow: 1, fontSize: '12px', padding: '10px' }}
                  >
                    <option value="Zone A">Simulate Zone A Context</option>
                    <option value="Zone B">Simulate Zone B Context</option>
                    <option value="Zone C">Simulate Zone C Context</option>
                    <option value="Zone D">Simulate Zone D Context</option>
                  </select>

                  <button 
                    className="md3-btn md3-btn-primary" 
                    onClick={handleDiagnoseSpecimen}
                    disabled={isAnalyzingImage || !selectedSpecimen}
                    style={{ fontSize: '12px', flexGrow: 1 }}
                  >
                    <Sparkles size={14} /> Diagnose with Gemini
                  </button>
                </div>
              </section>

              {/* Right Column: Diagnostics Card */}
              <section className="md3-card" style={{ minHeight: '350px', display: 'flex', flexDirection: 'column' }}>
                <h3 style={{ fontSize: '15px', fontWeight: '600', marginBottom: '14px' }}>3. Gemini AI Agronomic Analysis</h3>

                {workbenchDiagnosis ? (
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '14px', flexGrow: 1, justifyContent: 'space-between' }}>
                    <div>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '8px' }}>
                        <div>
                          <span style={{ fontSize: '10px', color: 'var(--md-sys-color-secondary)', fontWeight: 'bold' }}>SCAN COMPLETED</span>
                          <h4 style={{ fontSize: '16px', fontWeight: 'bold', color: '#fff', marginTop: '2px' }}>{workbenchDiagnosis.issueDetected}</h4>
                        </div>
                        <span className={`badge ${workbenchDiagnosis.severity === 'critical' ? 'badge-danger' : workbenchDiagnosis.severity === 'warning' ? 'badge-warning' : 'badge-success'}`}>
                          {workbenchDiagnosis.severity?.toUpperCase()}
                        </span>
                      </div>
                      <p style={{ fontSize: '12px', color: 'var(--text-secondary)', lineHeight: '1.4' }}>{workbenchDiagnosis.findings}</p>
                    </div>

                    <div>
                      <div style={{ fontSize: '11px', fontWeight: 'bold', color: 'var(--md-sys-color-primary)', borderTop: '1px solid var(--md-sys-color-outline)', paddingTop: '8px', marginBottom: '6px' }}>
                        AGRONOMIST PRESCRIPTIONS:
                      </div>
                      <ul style={{ paddingLeft: '14px', fontSize: '11px', color: 'var(--text-primary)' }}>
                        {workbenchDiagnosis.recommendations?.map((item, idx) => (
                          <li key={idx} style={{ marginBottom: '3px' }}>{item}</li>
                        ))}
                      </ul>
                      
                      <div className="text-mono" style={{ fontSize: '9px', color: 'var(--text-secondary)', textAlign: 'right', marginTop: '14px' }}>
                        CONFIDENCE: {workbenchDiagnosis.confidence}%
                      </div>
                    </div>
                  </div>
                ) : (
                  <div style={{ display: 'flex', height: '100%', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', color: 'var(--text-secondary)', fontSize: '12px', textAlign: 'center', flexGrow: 1 }}>
                    <Layers size={24} style={{ marginBottom: '8px' }} color="var(--md-sys-color-secondary)" />
                    <span>Select a leaf sample and click "Diagnose with Gemini" to launch visual scanning and agronomy prescription audits.</span>
                  </div>
                )}
              </section>

            </div>
          </div>
        )}

        {/* ==================== TAB 3: REPORTS CENTER ==================== */}
        {activeTab === 'reports' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            <div className="flex-between">
              <div>
                <h1 style={{ fontSize: '28px', fontWeight: '800' }}>Farm Reports Console</h1>
                <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>Generate weekly audits and long-term yield projections compiled by Gemini AI</p>
              </div>
              <button 
                className="md3-btn md3-btn-primary" 
                onClick={handleGenerateAIReport}
                disabled={isGeneratingReport}
              >
                {isGeneratingReport ? 'Compiling Farm Logs...' : 'Generate AI Status Report'}
              </button>
            </div>

            {/* Farm Performance Analytics cards */}
            <div className="grid-3">
              <div className="md3-card" style={{ background: 'rgba(255,255,255,0.01)' }}>
                <span style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>AVERAGE CROP HEALTH INDEX</span>
                <div style={{ fontSize: '28px', fontWeight: 'bold', color: 'var(--md-sys-color-primary)', marginTop: '4px' }}>91%</div>
                <div style={{ fontSize: '10px', color: 'var(--text-secondary)', marginTop: '4px' }}>+3% improvement from last audit cycle</div>
              </div>

              <div className="md3-card" style={{ background: 'rgba(255,255,255,0.01)' }}>
                <span style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>TOTAL CROP YIELD TARGET</span>
                <div style={{ fontSize: '28px', fontWeight: 'bold', color: 'var(--md-sys-color-secondary)', marginTop: '4px' }}>
                  {Object.values(sensors).reduce((acc, curr) => acc + (curr.predictions?.expectedYieldTons || 0), 0).toFixed(1)} / 58.0 Tons
                </div>
                <div style={{ fontSize: '10px', color: 'var(--text-secondary)', marginTop: '4px' }}>Expected yield values calculated across 4 zones</div>
              </div>

              <div className="md3-card" style={{ background: 'rgba(255,255,255,0.01)' }}>
                <span style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>NPK OPTIMIZATION COMPLIANCE</span>
                <div style={{ fontSize: '28px', fontWeight: 'bold', color: 'var(--md-sys-color-tertiary)', marginTop: '4px' }}>84%</div>
                <div style={{ fontSize: '10px', color: 'var(--text-secondary)', marginTop: '4px' }}>Nitrogen deficiencies active in 0 zones</div>
              </div>
            </div>

            {/* Report Render Box */}
            <section className="md3-card" style={{ minHeight: '400px', background: '#0e1222' }}>
              <div className="markdown-body">
                {isGeneratingReport ? (
                  <div style={{ display: 'flex', flexDirection: 'column', height: '300px', alignItems: 'center', justifyContent: 'center', color: 'var(--text-secondary)', gap: '12px' }}>
                    <Cpu size={32} className="animate-spin" color="var(--md-sys-color-primary)" />
                    <span>Gemini is auditing telemetry history records, active recommendations, and weather forecast profiles...</span>
                  </div>
                ) : (
                  renderMarkdown(activeReportText)
                )}
              </div>
            </section>
          </div>
        )}

        {/* ==================== TAB 4: ALERTS & NOTIFICATIONS ==================== */}
        {activeTab === 'notifications' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            <div>
              <h1 style={{ fontSize: '28px', fontWeight: '800' }}>System Alerts Inbox</h1>
              <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>Review active sensor warnings and configure customized alert thresholds</p>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '7fr 5fr', gap: '20px', alignItems: 'start' }}>
              
              {/* Notifications list */}
              <section className="md3-card" style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
                <div className="flex-between" style={{ borderBottom: '1px solid var(--md-sys-color-outline)', paddingBottom: '10px' }}>
                  <h3 style={{ fontSize: '16px', fontWeight: '600' }}>Active Notification Center ({unreadNotifCount} unread)</h3>
                  {unreadNotifCount > 0 && (
                    <button className="md3-btn" onClick={handleMarkAllNotifsRead} style={{ padding: '6px 12px', fontSize: '11px' }}>
                      Mark all as read
                    </button>
                  )}
                </div>

                <div style={{ display: 'flex', flexDirection: 'column', gap: '10px', maxHeight: '450px', overflowY: 'auto', paddingRight: '4px' }}>
                  {notifications.length === 0 ? (
                    <div style={{ display: 'flex', height: '200px', alignItems: 'center', justifyContent: 'center', color: 'var(--text-secondary)', gap: '8px' }}>
                      <CheckCircle2 size={18} color="var(--md-sys-color-primary)" />
                      No recent notifications.
                    </div>
                  ) : (
                    notifications.map(notif => (
                      <div 
                        key={notif.id} 
                        className="md3-card" 
                        style={{ 
                          padding: '12px 16px', 
                          background: notif.read ? 'rgba(255,255,255,0.01)' : 'rgba(0, 230, 118, 0.02)', 
                          borderLeft: `4px solid ${notif.read ? 'rgba(255,255,255,0.1)' : notif.level === 'critical' ? 'var(--md-sys-color-error)' : 'var(--md-sys-color-warning)'}`,
                          opacity: notif.read ? 0.75 : 1,
                          display: 'flex',
                          justifyContent: 'space-between',
                          alignItems: 'center'
                        }}
                      >
                        <div style={{ flexGrow: 1, paddingRight: '12px' }}>
                          <div style={{ display: 'flex', gap: '8px', alignItems: 'center', marginBottom: '4px' }}>
                            <span className={`badge ${notif.level === 'critical' ? 'badge-danger' : notif.level === 'warning' ? 'badge-warning' : 'badge-info'}`}>
                              {notif.zone}
                            </span>
                            <span style={{ fontSize: '9px', color: 'var(--text-secondary)' }}>
                              {new Date(notif.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' })}
                            </span>
                          </div>
                          <p style={{ fontSize: '12px', color: notif.read ? 'var(--text-secondary)' : '#fff', lineHeight: '1.4' }}>{notif.message}</p>
                        </div>
                        {!notif.read && (
                          <button 
                            className="md3-btn" 
                            onClick={() => handleMarkNotifRead(notif.id)} 
                            style={{ padding: '4px 8px', fontSize: '9px', height: 'fit-content' }}
                          >
                            Mark Read
                          </button>
                        )}
                      </div>
                    ))
                  )}
                </div>
              </section>

              {/* Threshold alert settings */}
              <section className="md3-card" style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                <h3 style={{ fontSize: '16px', fontWeight: '600', borderBottom: '1px solid var(--md-sys-color-outline)', paddingBottom: '10px' }}>
                  Alert Threshold Customizer
                </h3>

                <form onSubmit={handleUpdateThresholdSettings} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
                  
                  <div>
                    <div className="flex-between" style={{ fontSize: '12px', marginBottom: '6px' }}>
                      <span style={{ fontWeight: '500' }}>Moisture Limit (Min):</span>
                      <span className="text-mono" style={{ color: 'var(--md-sys-color-primary)' }}>{thresholdSettings.moistureThresholdMin}%</span>
                    </div>
                    <input 
                      type="range" 
                      min="15" 
                      max="50" 
                      value={thresholdSettings.moistureThresholdMin}
                      onChange={(e) => setThresholdSettings(prev => ({ ...prev, moistureThresholdMin: parseInt(e.target.value) }))}
                      style={{ width: '100%', accentColor: 'var(--md-sys-color-primary)' }}
                    />
                  </div>

                  <div>
                    <div className="flex-between" style={{ fontSize: '12px', marginBottom: '6px' }}>
                      <span style={{ fontWeight: '500' }}>Moisture Limit (Max):</span>
                      <span className="text-mono" style={{ color: 'var(--md-sys-color-primary)' }}>{thresholdSettings.moistureThresholdMax}%</span>
                    </div>
                    <input 
                      type="range" 
                      min="70" 
                      max="95" 
                      value={thresholdSettings.moistureThresholdMax}
                      onChange={(e) => setThresholdSettings(prev => ({ ...prev, moistureThresholdMax: parseInt(e.target.value) }))}
                      style={{ width: '100%', accentColor: 'var(--md-sys-color-primary)' }}
                    />
                  </div>

                  <div>
                    <div className="flex-between" style={{ fontSize: '12px', marginBottom: '6px' }}>
                      <span style={{ fontWeight: '500' }}>Temperature limit (Max):</span>
                      <span className="text-mono" style={{ color: 'var(--md-sys-color-tertiary)' }}>{thresholdSettings.tempThresholdMax}°C</span>
                    </div>
                    <input 
                      type="range" 
                      min="30" 
                      max="48" 
                      value={thresholdSettings.tempThresholdMax}
                      onChange={(e) => setThresholdSettings(prev => ({ ...prev, tempThresholdMax: parseInt(e.target.value) }))}
                      style={{ width: '100%', accentColor: 'var(--md-sys-color-tertiary)' }}
                    />
                  </div>

                  <div>
                    <div className="flex-between" style={{ fontSize: '12px', marginBottom: '6px' }}>
                      <span style={{ fontWeight: '500' }}>Temperature limit (Min):</span>
                      <span className="text-mono" style={{ color: 'var(--md-sys-color-secondary)' }}>{thresholdSettings.tempThresholdMin}°C</span>
                    </div>
                    <input 
                      type="range" 
                      min="0" 
                      max="15" 
                      value={thresholdSettings.tempThresholdMin}
                      onChange={(e) => setThresholdSettings(prev => ({ ...prev, tempThresholdMin: parseInt(e.target.value) }))}
                      style={{ width: '100%', accentColor: 'var(--md-sys-color-secondary)' }}
                    />
                  </div>

                  <div>
                    <div className="flex-between" style={{ fontSize: '12px', marginBottom: '6px' }}>
                      <span style={{ fontWeight: '500' }}>Nitrogen (NPK N) Warning Limit:</span>
                      <span className="text-mono" style={{ color: 'var(--md-sys-color-primary)' }}>{thresholdSettings.npkThresholdN} mg/kg</span>
                    </div>
                    <input 
                      type="range" 
                      min="30" 
                      max="90" 
                      value={thresholdSettings.npkThresholdN}
                      onChange={(e) => setThresholdSettings(prev => ({ ...prev, npkThresholdN: parseInt(e.target.value) }))}
                      style={{ width: '100%', accentColor: 'var(--md-sys-color-primary)' }}
                    />
                  </div>

                  <button type="submit" className="md3-btn md3-btn-primary" style={{ width: '100%', marginTop: '10px' }}>
                    <Sliders size={14} /> Update Configurations
                  </button>

                </form>
              </section>

            </div>
          </div>
        )}

        {/* ==================== TAB 5: MEMORY LOGS & CHAT ==================== */}
        {activeTab === 'logs' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px', height: 'calc(100vh - 80px)' }}>
            <div>
              <h1 style={{ fontSize: '28px', fontWeight: '800' }}>AI Consultant & Farm Memory</h1>
              <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>Consult the lead agronomist chatbot or review full historical telemetry logs</p>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '6fr 6fr', gap: '20px', flexGrow: 1, minHeight: 0 }}>
              
              {/* Chat Panel */}
              <section className="md3-card" style={{ display: 'flex', flexDirection: 'column', height: '100%', minHeight: 0 }}>
                <h3 style={{ fontSize: '15px', fontWeight: '600', marginBottom: '10px', display: 'flex', alignItems: 'center', gap: '6px' }}>
                  <Cpu size={16} color="var(--md-sys-color-primary)" /> Gemini Agronomy Consultant
                </h3>

                {/* Chat History Panel */}
                <div style={{ flexGrow: 1, overflowY: 'auto', display: 'flex', flexDirection: 'column', gap: '10px', marginBottom: '12px', padding: '10px', background: 'rgba(0,0,0,0.15)', borderRadius: '12px', minHeight: 0 }}>
                  {chatHistory.length === 0 && (
                    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: '100%', color: 'var(--text-secondary)', fontSize: '12px', textAlign: 'center', padding: '16px' }}>
                      <HelpCircle size={24} style={{ marginBottom: '8px' }} color="var(--md-sys-color-primary)" />
                      <span>Ask me agronomic questions about current farm statuses:</span>
                      <em style={{ marginTop: '8px', color: 'var(--md-sys-color-secondary)' }}>"What is the status of Lettuce in Zone A?"</em>
                      <em style={{ marginTop: '4px', color: 'var(--md-sys-color-secondary)' }}>"Give me treatment plans for spider mites."</em>
                    </div>
                  )}
                  
                  {chatHistory.map((chat, idx) => (
                    <div key={idx} className={`chat-bubble ${chat.role === 'user' ? 'chat-user' : 'chat-bot'}`}>
                      <div style={{ whiteSpace: 'pre-wrap' }}>{chat.message}</div>
                    </div>
                  ))}
                  
                  {isChatLoading && (
                    <div className="chat-bubble chat-bot" style={{ opacity: 0.6 }}>
                      Analyzing database records...
                    </div>
                  )}
                </div>

                {/* Chat Input */}
                <form onSubmit={handleSendChat} style={{ display: 'flex', gap: '8px' }}>
                  <input
                    type="text"
                    className="md3-input"
                    value={chatMessage}
                    onChange={(e) => setChatMessage(e.target.value)}
                    placeholder="Ask Gemini to consult Farm Memory..."
                    disabled={isChatLoading}
                    style={{ flexGrow: 1 }}
                  />
                  <button type="submit" className="md3-btn md3-btn-primary" disabled={isChatLoading || !chatMessage.trim()}>
                    <Send size={16} />
                  </button>
                </form>
              </section>

              {/* Event Stream Logs Panel */}
              <section className="md3-card" style={{ display: 'flex', flexDirection: 'column', height: '100%', minHeight: 0 }}>
                <h3 style={{ fontSize: '15px', fontWeight: '600', marginBottom: '10px', display: 'flex', alignItems: 'center', gap: '6px' }}>
                  <Database size={16} color="var(--md-sys-color-secondary)" /> Farm Memory Event Stream
                </h3>

                <div style={{ overflowY: 'auto', flexGrow: 1, display: 'flex', flexDirection: 'column', gap: '6px', paddingRight: '4px', minHeight: 0 }}>
                  {logs.length === 0 ? (
                    <div style={{ display: 'flex', height: '100%', alignItems: 'center', justifyContent: 'center', color: 'var(--text-secondary)', fontSize: '12px' }}>
                      Awaiting log stream records...
                    </div>
                  ) : (
                    logs.map(log => {
                      const isCritical = log.level === 'critical';
                      const isWarning = log.level === 'warning';
                      
                      let color = 'var(--text-secondary)';
                      if (isCritical) color = 'var(--md-sys-color-error)';
                      else if (isWarning) color = 'var(--md-sys-color-warning)';
                      
                      return (
                        <div key={log.id} style={{ fontSize: '11px', borderBottom: '1px solid rgba(255,255,255,0.03)', paddingBottom: '6px', lineHeight: '1.4' }}>
                          <span className="text-mono" style={{ color: 'rgba(255,255,255,0.25)', marginRight: '6px' }}>
                            {new Date(log.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' })}
                          </span>
                          <span style={{ fontWeight: 'bold', color: 'var(--md-sys-color-secondary)', marginRight: '6px' }}>
                            [{log.source}]
                          </span>
                          <span style={{ color }}>{log.message}</span>
                        </div>
                      );
                    })
                  )}
                </div>
              </section>

            </div>
          </div>
        )}

        {/* Footer */}
        <footer style={{ textAlign: 'center', padding: '24px 0 12px 0', fontSize: '11px', color: 'var(--text-secondary)', borderTop: '1px solid var(--md-sys-color-outline)', marginTop: '20px' }}>
          FarmGuardian AI - Google AI Hackathon Submission 2026. Powered by Google Gemini 3.5 Flash & Material Design 3.
        </footer>
      </main>

    </div>
  );
}
