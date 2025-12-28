import time
import json
import random
import requests
import os
import paho.mqtt.client as mqtt
from collections import deque

from datetime import datetime, timezone


API_URL = os.getenv("API_URL", "http://localhost:3000/api/v1")
MQTT_BROKER = os.getenv("MQTT_BROKER", "test.mosquitto.org")
MQTT_PORT = int(os.getenv("MQTT_PORT", 1883))


USER_EMAIL = os.getenv("IOT_USER", "user@example.com")
USER_PASS = os.getenv("IOT_PASS", "string")


STATION_ID = os.getenv("STATION_ID", "98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b")
HISTORY_FILE = "sensor_history.json"
WINDOW_SIZE = 5

class TelemetryStorage:
    """Клас для роботи з файловою системою"""
    
    @staticmethod
    def load_all():
        if not os.path.exists(HISTORY_FILE):
            return {}
        try:
            with open(HISTORY_FILE, 'r') as f:
                return json.load(f)
        except (json.JSONDecodeError, IOError):
            return {}

    @staticmethod
    def save_reading(sensor_id, value):
        data = TelemetryStorage.load_all()
        
        history = data.get(sensor_id, [])

        history.append(value)
   
        if len(history) > WINDOW_SIZE:
            history = history[-WINDOW_SIZE:]
            
        data[sensor_id] = history
 
        with open(HISTORY_FILE, 'w') as f:
            json.dump(data, f, indent=2)
            
        return history
    
class SensorEmulator:
    def __init__(self, sensor_data):
        self.id = sensor_data['sensorId'] 
        self.type = sensor_data['type']
        self.value = float(sensor_data['value'] or 0.0) 
        history = TelemetryStorage.load_all().get(self.id, [])
        if history:
            self.value = history[-1] 
        else:
            self.value = float(sensor_data['value'] or 0.0) 
   
        if self.value == 0.0:
            defaults = {
                'ph_meter': 7.2, 
                'do_meter': 8.5, 
                'thermometer': 20.0,
                'level_sensor': 60.0, 
                'pressure_sensor': 3.5,
                'orp_meter': 720.0, 
                'turbidity_meter': 0.5
            }
            self.value = defaults.get(self.type, 0.0)

    def update_physics(self, actuators):
        """
        Математична модель: Розрахунок впливу актуаторів на показники
        """
        noise = random.uniform(-0.02, 0.02)
        
        influence = 0.0

        if self.type == 'ph_meter':
 
            acid_pwr = actuators.get('dispenser_acid', 0)
            alkali_pwr = actuators.get('dispenser_alkali', 0)
            
      
            influence = (alkali_pwr * 0.002) - (acid_pwr * 0.002)

            natural_drift = 0.0005 
            self.value += influence + natural_drift + noise

        elif self.type == 'do_meter':
            aerator_pwr = actuators.get('aerator', 0)
   
            consumption = 0.03 
     
            recovery = (aerator_pwr / 100.0) * 0.15 
            
            self.value += recovery - consumption + noise
            self.value = max(0, min(14, self.value))

  
        elif self.type == 'level_sensor':
            pump_pwr = actuators.get('pump', 0)
            valve_pwr = actuators.get('valve', 0) 
    
            inflow = (valve_pwr / 100.0) * 1.0  
            outflow = (pump_pwr / 100.0) * 1.2 
            
            self.value += inflow - outflow + noise
            self.value = max(0, min(100, self.value))

        elif self.type == 'orp_meter':
            chlorine_pwr = actuators.get('dispenser_chlorine', 0)
         
            decay = 1.5 
            boost = (chlorine_pwr / 100.0) * 5.0
            
            self.value += boost - decay + noise

     
        elif self.type == 'pressure_sensor':

            pump_pwr = actuators.get('pump', 0)
            filter_pwr = actuators.get('filter', 0) 
            
            base_pressure = 2.0 
            pump_effect = (pump_pwr / 100.0) * 2.5

            filter_drop = (filter_pwr / 100.0) * 3.0
       
            clogging = 0.005 
            
            target = base_pressure + pump_effect - filter_drop
  
            self.value = (self.value * 0.9) + (target * 0.1) + clogging + noise

     
        elif self.type == 'thermometer':
  
            ambient_temp = 19.5 
 
            pump_heat = actuators.get('pump', 0) * 0.0001
            
            diff = ambient_temp - self.value
            self.value += (diff * 0.01) + pump_heat + noise

        elif self.type == 'turbidity_meter':
            filter_pwr = actuators.get('filter', 0)
  
            cleaning = (filter_pwr / 100.0) * 0.1
            dirt_accumulation = 0.01
            
            self.value += dirt_accumulation - cleaning + noise
            self.value = max(0, self.value)

        else:
            self.value += noise

    def get_reading(self):
        """
        РОЗУМНА ОБРОБКА ДАНИХ
        1. Перевіряє на аномалії (Z-Score).
        2. Якщо аномалія -> повертає середнє (фільтрує).
        3. Якщо норма -> повертає сире значення (без згладжування).
        """
        data = TelemetryStorage.load_all()
        history = data.get(self.id, [])

        if len(history) < 3:
            TelemetryStorage.save_reading(self.id, self.value)
            return round(self.value, 2)

    
        mean = sum(history) / len(history)
        variance = sum([((x - mean) ** 2) for x in history]) / len(history)
        std_dev = variance ** 0.5

        z_score_threshold = 4
        is_anomaly = False
        
        effective_std_dev = max(std_dev, 0.05) 
        z_score = abs(self.value - mean) / effective_std_dev
        if z_score > z_score_threshold:
            is_anomaly = True
            print(f"⚠️ [Sensor {self.type}] Anomaly detected! Val: {self.value:.2f}, Mean: {mean:.2f} (Z-Score: {z_score:.2f})")

        final_value = mean if is_anomaly else self.value

        TelemetryStorage.save_reading(self.id, final_value)

        return round(final_value, 2)

class IoTDevice:
    def __init__(self):
        self.token = None
        self.sensors = []
        self.actuators_state = {} 
        self.mqtt_client = mqtt.Client()

    def login(self):
        print(f"🔑 Logging in as {USER_EMAIL}...")
        try:
            res = requests.post(f"{API_URL}/auth/login", json={"email": USER_EMAIL, "password": USER_PASS})
            res.raise_for_status()
            self.token = res.json()['token']
            print(" Login successful.")
        except Exception as e:
            print(f" Login failed: {e}")
            exit(1)

    def init_sensors(self):
        print(" Fetching station config (Sensors)...")
        headers = {"Authorization": f"Bearer {self.token}"}
        try:
       
            res = requests.get(f"{API_URL}/telemetry/station/{STATION_ID}/latest", headers=headers)
            res.raise_for_status()
            data = res.json()
            
            self.sensors = []
            for s in data:
                self.sensors.append(SensorEmulator(s))
            print(f" Initialized {len(self.sensors)} sensors from API.")
        except Exception as e:
            print(f" Config failed: {e}")

    def sync_actuators(self):
        """
        Зчитує команди для актуаторів з API
        """
        headers = {"Authorization": f"Bearer {self.token}"}
        try:
            res = requests.get(f"{API_URL}/actuators/station/{STATION_ID}/latest", headers=headers)
            if res.status_code == 200:
                devices = res.json()
                print("\n🔌 Actuator Status (Server Control):")
                
                if not devices:
                    print(f"   Жодних актуаторів не знайдено для станції {STATION_ID}")
                    print("     Перевірте ID станції в .env або seed-дані в БД.")
                
                for dev in devices:
 
                    pct = float(dev.get('activationPercentage') or 0)
  
                    self.actuators_state[dev['type']] = pct
     
                    status_symbol = "[ON]" if pct > 0 else "[OFF]"
                    print(f"   {status_symbol} {dev['name']} ({dev['type']}): {pct}%")
        except Exception as e:
            print(f" Actuator sync failed: {e}")

    def run(self):
        print(f" Connecting to MQTT: {MQTT_BROKER}...")
        try:
            self.mqtt_client.connect(MQTT_BROKER, MQTT_PORT, 60)
            self.mqtt_client.loop_start()
        except Exception as e:
            print(f" MQTT Connection failed: {e}")
            return

        print(" Simulation started...")
        
        try:
            while True:
                self.sync_actuators()

                print("\n Sensor Data (Sending to MQTT):")
                for sensor in self.sensors:
  
                    sensor.update_physics(self.actuators_state)
 
                   
                    # if random.random() < 0.05:
                      
                    #     spike = random.uniform(15.0, 35.0) * random.choice([-1, 1])
                    #     print(f" [TEST] Injecting ANOMALY for {sensor.type}: {spike:+.2f}")
                    #     sensor.value += spike
                    

                    val = sensor.get_reading()

                    payload = {
                        "sensorId": sensor.id,
                        "value": val,
                        "measuredAt": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
                    }
                    
      
                    topic = f"station/{STATION_ID}/telemetry"
                    self.mqtt_client.publish(topic, json.dumps(payload), qos=0)
                    print(f"   -> {sensor.type}: {val}")

                time.sleep(5)

        except KeyboardInterrupt:
            self.mqtt_client.disconnect()
            print("\n Simulation stopped.")

if __name__ == "__main__":
    device = IoTDevice()
    device.login()
    device.init_sensors()
    device.run()