import { dbService } from './db.service.js';

let currentWeatherState = {
  condition: 'Sunny', // Sunny, Cloudy, Rainy, Stormy, Frosty, HeatWave
  temperature: 24, // in Celsius
  humidity: 62, // percentage
  windSpeed: 8, // km/h
  precipitationProbability: 10, // percentage
  pressure: 1012, // hPa
  solarRadiation: 650, // W/m^2
  stormWarning: false,
  frostWarning: false
};

// Weather forecast generator
function generateForecast(current) {
  const forecast = [];
  const conditions = ['Sunny', 'Cloudy', 'Rainy', 'Stormy', 'Frosty', 'HeatWave'];
  
  let currentTemp = current.temperature;
  let currentCondition = current.condition;
  
  for (let i = 1; i <= 5; i++) {
    // Generate slight variations
    const dayTemp = currentTemp + (Math.random() * 4 - 2);
    forecast.push({
      day: i,
      dayName: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][(new Date().getDay() + i - 1) % 7],
      condition: currentCondition === 'Normal' || Math.random() > 0.5 ? currentCondition : conditions[Math.floor(Math.random() * 3)], // Keep current pattern or mild weather
      temperature: parseFloat(dayTemp.toFixed(1)),
      humidity: Math.min(100, Math.max(0, current.humidity + Math.floor(Math.random() * 20 - 10)))
    });
  }
  return forecast;
}

export const weatherService = {
  getCurrentWeather() {
    return currentWeatherState;
  },

  getWeatherForecast() {
    return generateForecast(currentWeatherState);
  },

  triggerWeatherEvent(eventType) {
    let message = '';
    switch (eventType) {
      case 'severe_storm':
        currentWeatherState = {
          condition: 'Stormy',
          temperature: 16,
          humidity: 92,
          windSpeed: 75,
          precipitationProbability: 95,
          pressure: 995,
          solarRadiation: 50,
          stormWarning: true,
          frostWarning: false
        };
        message = 'Severe Storm Warning triggered! Wind speeds exceeding 70km/h expected.';
        break;
      case 'frost_alert':
        currentWeatherState = {
          condition: 'Frosty',
          temperature: -2,
          humidity: 85,
          windSpeed: 12,
          precipitationProbability: 10,
          pressure: 1025,
          solarRadiation: 300,
          stormWarning: false,
          frostWarning: true
        };
        message = 'Frost Warning triggered! Ground temperatures dropping below 0°C.';
        break;
      case 'heat_wave':
        currentWeatherState = {
          condition: 'HeatWave',
          temperature: 42,
          humidity: 15,
          windSpeed: 25,
          precipitationProbability: 0,
          pressure: 1008,
          solarRadiation: 980,
          stormWarning: false,
          frostWarning: false
        };
        message = 'Heat Wave alert! Temperature scaling up to 42°C with low humidity.';
        break;
      case 'normal':
      default:
        currentWeatherState = {
          condition: 'Sunny',
          temperature: 24,
          humidity: 60,
          windSpeed: 10,
          precipitationProbability: 10,
          pressure: 1013,
          solarRadiation: 700,
          stormWarning: false,
          frostWarning: false
        };
        message = 'Weather conditions stabilized to standard seasonal parameters.';
        break;
    }

    dbService.saveLog({
      level: eventType === 'normal' ? 'info' : 'warning',
      source: 'WeatherMonitor',
      message
    });

    return currentWeatherState;
  },

  // Gradually mutate weather values over time
  updateWeatherSimulation() {
    const w = currentWeatherState;
    if (w.stormWarning || w.frostWarning || w.condition === 'HeatWave') {
      // Keep extreme weather mostly stable during the active event, just add minor jitter
      w.temperature += (Math.random() * 1 - 0.5);
      w.humidity = Math.max(0, Math.min(100, w.humidity + (Math.random() * 4 - 2)));
      w.windSpeed = Math.max(5, w.windSpeed + (Math.random() * 6 - 3));
      return w;
    }

    // Normal weather random walk
    w.temperature += (Math.random() * 0.8 - 0.4);
    w.humidity = Math.max(20, Math.min(95, w.humidity + (Math.random() * 4 - 2)));
    w.windSpeed = Math.max(2, Math.min(30, w.windSpeed + (Math.random() * 2 - 1)));
    
    // Day/Night adjustments can be simulated, but let's keep it simple
    w.temperature = parseFloat(w.temperature.toFixed(1));
    w.humidity = Math.round(w.humidity);
    w.windSpeed = Math.round(w.windSpeed);
    return w;
  }
};
