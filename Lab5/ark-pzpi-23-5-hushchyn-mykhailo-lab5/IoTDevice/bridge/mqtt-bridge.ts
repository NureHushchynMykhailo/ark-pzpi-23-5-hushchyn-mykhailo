import mqtt from 'mqtt';
import axios from 'axios';
import dotenv from 'dotenv';

dotenv.config();


const MQTT_BROKER = process.env.MQTT_BROKER || 'mqtt://test.mosquitto.org';
const API_URL = process.env.API_URL || 'http://localhost:3000';


const BRIDGE_USER = {
  email: process.env.BRIDGE_EMAIL || "user@example.com",
  password: process.env.BRIDGE_PASSWORD || "string",
  fullName: "System MQTT Bridge",
  role: "admin" 
};

let authToken: string | null = null;


async function authenticate() {
  console.log(' Bridge Authenticating...');
  
  try {
    const loginRes = await axios.post(`${API_URL}/auth/login`, {
      email: BRIDGE_USER.email,
      password: BRIDGE_USER.password
    });
    
    authToken = loginRes.data.token;
    console.log(' Login successful. Token acquired.');

  } catch (error: any) {
    if (error.response && (error.response.status === 401 || error.response.status === 400)) {
      console.log(' User not found or invalid credentials. Attempting registration...');
      
      try {
        await axios.post(`${API_URL}/auth/register`, BRIDGE_USER);
        console.log(' Registration successful. Retrying login...');
       
        const retryLogin = await axios.post(`${API_URL}/auth/login`, {
          email: BRIDGE_USER.email,
          password: BRIDGE_USER.password
        });
        authToken = retryLogin.data.token;
        console.log(' Login successful after registration.');
        
      } catch (regError: any) {
        console.error(' FATAL: Could not register Bridge user:', regError.response?.data || regError.message);
        process.exit(1);
      }
    } else {
      console.error(' FATAL: API is unreachable:', error.message);
      setTimeout(authenticate, 5000);
    }
  }
}


(async () => {

  await authenticate();

  if (!authToken) return;

  console.log(`🔌 Connecting to MQTT Broker: ${MQTT_BROKER}`);
  const client = mqtt.connect(MQTT_BROKER);

  client.on('connect', () => {
    console.log(' MQTT Connected');
    client.subscribe('station/+/telemetry', (err) => {
      if (!err) console.log('📡 Subscribed to station/+/telemetry');
    });
  });

  client.on('message', async (topic, message) => {
    if (!authToken) {
      console.warn(' No token available. Skipping message.');
      return;
    }

    try {
      const payload = JSON.parse(message.toString());
      if (payload.measuredAt && typeof payload.measuredAt === 'string') {
        if (!payload.measuredAt.endsWith('Z') && !payload.measuredAt.includes('+')) {
          payload.measuredAt = payload.measuredAt + 'Z';
        }
      }
      await axios.post(`${API_URL}/telemetry`, payload, {
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        }
      });

      process.stdout.write('S'); 

    } catch (error: any) {
      process.stdout.write('E');
     
      if (error.response && (error.response.status === 401 || error.response.status === 403)) {
        console.log('\n Token expired. Re-authenticating...');
        await authenticate();
      } else {
        console.error('\n API Error:', error.response?.data || error.message);
      }
    }
  });

  client.on('error', (err) => {
    console.error('\n MQTT Error:', err);
  });
})();