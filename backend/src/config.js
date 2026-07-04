import dotenv from 'dotenv';
import { GoogleGenAI } from '@google/genai';

dotenv.config();

const apiKey = process.env.GEMINI_API_KEY;

if (!apiKey) {
  console.warn('⚠️ WARNING: GEMINI_API_KEY environment variable is not set. FarmGuardian AI will run in simulation mode with mocked AI analysis.');
}

// Initialize the Google Gen AI client
const ai = apiKey ? new GoogleGenAI({ apiKey }) : null;

export const config = {
  port: process.env.PORT || 5000,
  geminiApiKey: apiKey,
  isMockMode: !apiKey
};

export { ai };
