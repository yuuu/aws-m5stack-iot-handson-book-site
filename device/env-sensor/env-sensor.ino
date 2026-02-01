#include <M5Unified.h>
#include <M5UnitUnified.h>
#include <M5UnitUnifiedENV.h>
#include <TaskScheduler.h>
#include <MQTTClient.h>
#include <WiFiClientSecure.h>
#include <ArduinoJson.h>
#include <WiFi.h>

#include "arduino_secrets.h"

struct Sensor
{
  float temperature;
  float humidity;
  float pressure;
};

struct WiFiConfig
{
  const char* ssid;
  const char* password;
};

struct MQTTConfig
{
  const char* endpoint;
  const char* certificate;
  const char* privateKey;
  const char* rootCA;
  const char* clientID;
};

bool connectWiFi(const WiFiConfig &config);
void disconnectWiFi();
bool connectMQTT(const MQTTConfig &config);
void disconnectMQTT();
void sendMQTT(const char* topic, Sensor &sensor);

void initSensor();
bool readSensor(Sensor &sensor);

void doTask();
void exit();

namespace
{
  auto &lcd = M5.Display;
  m5::unit::UnitUnified Units;
  m5::unit::UnitENV3 unitENV3;
  auto &sht30 = unitENV3.sht30;
  auto &qmp6988 = unitENV3.qmp6988;

  Sensor sensor;
  Task task(60000, TASK_FOREVER, &doTask);
  Scheduler runner;

  WiFiClientSecure net = WiFiClientSecure();
  MQTTClient client = MQTTClient(256);
}

void setup()
{
  M5.begin();
  M5.Log.setLogLevel(m5::log_target_serial, ESP_LOG_INFO);
  M5.Log.setEnableColor(m5::log_target_serial, true);

  initSensor();

  runner.init();
  runner.addTask(task);
  task.enable();

  delay(1000);
}

void loop()
{
  runner.execute();
}

bool connectWiFi(const WiFiConfig &config)
{
  int retry_count = 0;
  WiFi.begin(config.ssid, config.password);

  while (WiFi.status() != WL_CONNECTED)
  {
    retry_count++;
    if (retry_count > 10) {
      M5_LOGE("Failed to connect to WiFi. Retrying...");
      return false;
    }
    delay(1000);
  }

  M5_LOGI("Connected to WiFi.");
  return true;
}

void disconnectWiFi()
{
  WiFi.disconnect();
  M5_LOGI("Disconnected from WiFi.");
}

bool connectMQTT(const MQTTConfig &config)
{
  net.setCACert(config.rootCA);
  net.setCertificate(config.certificate);
  net.setPrivateKey(config.privateKey);
  client.begin(config.endpoint, 8883, net);

  if (!client.connect(config.clientID))
  {
    M5_LOGE("Failed to connect to MQTT. Retrying...");
    return false;
  }

  M5_LOGI("Connected to MQTT.");
  return true;
}

void disconnectMQTT()
{
  client.disconnect();
  M5_LOGI("Disconnected from MQTT.");
}

void sendMQTT(const char* topic, Sensor &sensor)
{
  char payload[256];
  StaticJsonDocument<256> doc;
  doc["temperature"] = sensor.temperature;
  doc["humidity"] = sensor.humidity;
  doc["pressure"] = sensor.pressure;
  serializeJson(doc, payload);

  if (!client.publish(topic, payload))
  {
    M5_LOGE("MQTT publish failed.");
  }

  M5_LOGI("MQTT publish succeeded.");
}

void initSensor()
{
  auto pin_num_sda = M5.getPin(m5::pin_name_t::port_a_sda);
  auto pin_num_scl = M5.getPin(m5::pin_name_t::port_a_scl);

  Wire.end();
  Wire.begin(pin_num_sda, pin_num_scl, 400000U);

  if (!Units.add(unitENV3, Wire) || !Units.begin())
  {
    M5_LOGE("Failed to initialize ENV sensor unit.");
    exit();
  }

  M5_LOGI("ENV sensor unit initialized.");
}

bool readSensor(Sensor &sensor)
{
  if (!sht30.updated() || !qmp6988.updated())
  {
    M5_LOGW("Sensor data not updated yet.");
    return false;
  }

  sensor.temperature = sht30.temperature();
  sensor.humidity = sht30.humidity();
  sensor.pressure = qmp6988.pressure() * 0.01f;

  M5_LOGI("Sensor data read successfully.");
  return true;
}

void doTask()
{
  M5.update();
  Units.update();
  Sensor sensor;

  if(readSensor(sensor)) {
    M5_LOGI("Temperature: %2.2f, Humidity:%2.2f, Pressure: %.2f", sensor.temperature, sensor.humidity, sensor.pressure);
    WiFiConfig wifiConfig = { WIFI_SSID, WIFI_PASSWORD };
    MQTTConfig mqttConfig = { AWS_IOT_ENDPOINT, AWS_IOT_CERTIFICATE, AWS_IOT_PRIVATE_KEY, AWS_IOT_ROOT_CA, "env-sensor-device" };
    if (connectWiFi(wifiConfig) && connectMQTT(mqttConfig)) {
      sendMQTT("env-sensor/data", sensor);
      disconnectMQTT();
      disconnectWiFi();
    } else {
      M5_LOGE("Failed to connect to WiFi or MQTT.");
    }
  }
}

void exit() {
  M5_LOGE("Exiting...");
  delay(1000);
  ESP.restart();
}
