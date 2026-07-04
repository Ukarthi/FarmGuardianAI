import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const DB_DIR = path.join(__dirname, '../../data');
const DB_FILE = path.join(DB_DIR, 'db.json');

// Ensure DB directory and file exist
function initializeDb() {
  if (!fs.existsSync(DB_DIR)) {
    fs.mkdirSync(DB_DIR, { recursive: true });
  }
  
  if (!fs.existsSync(DB_FILE)) {
    const defaultData = {
      telemetry: [],
      droneMissions: [],
      recommendations: [],
      logs: [],
      notifications: [],
      notificationSettings: {
        moistureThresholdMin: 35,
        moistureThresholdMax: 85,
        tempThresholdMax: 38,
        tempThresholdMin: 5,
        npkThresholdN: 50
      }
    };
    fs.writeFileSync(DB_FILE, JSON.stringify(defaultData, null, 2));
  }
}

initializeDb();

// Helper to read database
function readDb() {
  try {
    initializeDb();
    const data = fs.readFileSync(DB_FILE, 'utf-8');
    return JSON.parse(data);
  } catch (error) {
    console.error('Error reading database file, resetting to empty schema:', error);
    return { telemetry: [], droneMissions: [], recommendations: [], logs: [] };
  }
}

// Helper to write database
function writeDb(data) {
  try {
    fs.writeFileSync(DB_FILE, JSON.stringify(data, null, 2));
  } catch (error) {
    console.error('Error writing to database file:', error);
  }
}

export const dbService = {
  // Telemetry
  getTelemetryHistory(limit = 100) {
    const db = readDb();
    return db.telemetry.slice(-limit).reverse(); // latest first
  },
  
  saveTelemetry(reading) {
    const db = readDb();
    const newReading = {
      id: `tel_${Date.now()}_${Math.random().toString(36).substr(2, 5)}`,
      timestamp: new Date().toISOString(),
      ...reading
    };
    db.telemetry.push(newReading);
    
    // Limit telemetry size in DB to avoid bloat
    if (db.telemetry.length > 500) {
      db.telemetry.shift();
    }
    
    writeDb(db);
    return newReading;
  },

  // Drone Missions
  getDroneMissions(limit = 50) {
    const db = readDb();
    return db.droneMissions.slice(-limit).reverse();
  },

  saveDroneMission(mission) {
    const db = readDb();
    const newMission = {
      id: `mission_${Date.now()}`,
      timestamp: new Date().toISOString(),
      status: 'pending', // pending, launching, active, completed, failed
      flightPath: [],
      capturedImages: [],
      diagnostics: null,
      notes: '',
      ...mission
    };
    db.droneMissions.push(newMission);
    writeDb(db);
    
    this.saveLog({
      level: 'info',
      source: 'DroneController',
      message: `New drone inspection mission registered for ${mission.reason || 'manual scan'} in Zone ${mission.zone || 'All'}.`
    });
    
    return newMission;
  },

  updateDroneMission(id, updates) {
    const db = readDb();
    const idx = db.droneMissions.findIndex(m => m.id === id);
    if (idx !== -1) {
      db.droneMissions[idx] = { ...db.droneMissions[idx], ...updates, updatedAt: new Date().toISOString() };
      writeDb(db);
      
      if (updates.status) {
        this.saveLog({
          level: 'info',
          source: 'DroneController',
          message: `Drone mission ${id} status updated to: ${updates.status}.`
        });
      }
      return db.droneMissions[idx];
    }
    return null;
  },

  // Recommendations
  getRecommendations(limit = 50) {
    const db = readDb();
    return db.recommendations.slice(-limit).reverse();
  },

  saveRecommendation(rec) {
    const db = readDb();
    const newRec = {
      id: `rec_${Date.now()}`,
      timestamp: new Date().toISOString(),
      resolved: false,
      ...rec
    };
    db.recommendations.push(newRec);
    writeDb(db);
    
    this.saveLog({
      level: 'warning',
      source: 'GeminiDecisionEngine',
      message: `Gemini issued a recommendation: ${rec.title}`
    });
    
    return newRec;
  },

  resolveRecommendation(id) {
    const db = readDb();
    const idx = db.recommendations.findIndex(r => r.id === id);
    if (idx !== -1) {
      db.recommendations[idx].resolved = true;
      db.recommendations[idx].resolvedAt = new Date().toISOString();
      writeDb(db);
      
      this.saveLog({
        level: 'info',
        source: 'Operations',
        message: `Recommendation resolving ID ${id} was marked as resolved.`
      });
      return db.recommendations[idx];
    }
    return null;
  },

  // Logs
  getLogs(limit = 100) {
    const db = readDb();
    return db.logs.slice(-limit).reverse();
  },

  saveLog(logEntry) {
    const db = readDb();
    const newLog = {
      id: `log_${Date.now()}_${Math.random().toString(36).substr(2, 5)}`,
      timestamp: new Date().toISOString(),
      level: logEntry.level || 'info', // info, warning, error, critical
      source: logEntry.source || 'System',
      message: logEntry.message
    };
    db.logs.push(newLog);
    
    // Limit log size in DB
    if (db.logs.length > 1000) {
      db.logs.shift();
    }
    
    writeDb(db);
    return newLog;
  },

  // Notifications
  getNotifications(limit = 50) {
    const db = readDb();
    if (!db.notifications) db.notifications = [];
    return db.notifications.slice(-limit).reverse();
  },

  saveNotification(notification) {
    const db = readDb();
    if (!db.notifications) db.notifications = [];
    const newNotif = {
      id: `notif_${Date.now()}_${Math.random().toString(36).substr(2, 5)}`,
      timestamp: new Date().toISOString(),
      read: false,
      ...notification
    };
    db.notifications.push(newNotif);
    
    // Limit notifications
    if (db.notifications.length > 200) {
      db.notifications.shift();
    }
    
    writeDb(db);
    return newNotif;
  },

  markNotificationRead(id) {
    const db = readDb();
    if (!db.notifications) db.notifications = [];
    const idx = db.notifications.findIndex(n => n.id === id);
    if (idx !== -1) {
      db.notifications[idx].read = true;
      writeDb(db);
      return db.notifications[idx];
    }
    return null;
  },

  markAllNotificationsRead() {
    const db = readDb();
    if (!db.notifications) db.notifications = [];
    db.notifications.forEach(n => { n.read = true; });
    writeDb(db);
    return true;
  },

  // Notification / Alert thresholds
  getNotificationSettings() {
    const db = readDb();
    // Fallback if missing
    if (!db.notificationSettings) {
      db.notificationSettings = {
        moistureThresholdMin: 35,
        moistureThresholdMax: 85,
        tempThresholdMax: 38,
        tempThresholdMin: 5,
        npkThresholdN: 50
      };
      writeDb(db);
    }
    return db.notificationSettings;
  },

  updateNotificationSettings(settings) {
    const db = readDb();
    db.notificationSettings = {
      ...this.getNotificationSettings(),
      ...settings
    };
    writeDb(db);
    
    this.saveLog({
      level: 'info',
      source: 'System',
      message: 'Sensor alert threshold configurations were updated.'
    });
    
    return db.notificationSettings;
  },

  // Clear data
  clearAll() {
    const defaultData = {
      telemetry: [],
      droneMissions: [],
      recommendations: [],
      logs: [],
      notifications: [],
      notificationSettings: {
        moistureThresholdMin: 35,
        moistureThresholdMax: 85,
        tempThresholdMax: 38,
        tempThresholdMin: 5,
        npkThresholdN: 50
      }
    };
    writeDb(defaultData);
    this.saveLog({
      level: 'info',
      source: 'System',
      message: 'Database was cleared and re-initialized.'
    });
  }
};
