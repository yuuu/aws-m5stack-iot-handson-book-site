#include "M5UnitENV.h"

SHT3X sht3x;
QMP6988 qmp;

void setup() {
  Serial.begin(115200);
  Serial.println("Environment Sensor Starting...");

  // Initialize QMP6988 pressure sensor
  // I2C pins: SDA=2, SCL=1, Frequency=400kHz
  if (!qmp.begin(&Wire, QMP6988_SLAVE_ADDRESS_L, 2, 1, 400000U)) {
    Serial.println("Couldn't find QMP6988");
    while (1) {
      delay(1000);
    }
  }

  // Initialize SHT3X temperature and humidity sensor
  if (!sht3x.begin(&Wire, SHT3X_I2C_ADDR, 2, 1, 400000U)) {
    Serial.println("Couldn't find SHT3X");
    while (1) {
      delay(1000);
    }
  }

  Serial.println("Sensors initialized successfully");
}

void loop() {
  // Update sensor data
  if (sht3x.update()) {
    Serial.println("-----SHT3X-----");
    Serial.print("Temperature: ");
    Serial.print(sht3x.cTemp);
    Serial.println(" *C");
    Serial.print("Humidity: ");
    Serial.print(sht3x.humidity);
    Serial.println(" %rH");
    Serial.println("---------------");
  }

  if (qmp.update()) {
    Serial.println("-----QMP6988-----");
    Serial.print("Temperature: ");
    Serial.print(qmp.cTemp);
    Serial.println(" *C");
    Serial.print("Pressure: ");
    Serial.print(qmp.pressure);
    Serial.println(" Pa");
    Serial.print("Approx altitude: ");
    Serial.print(qmp.altitude);
    Serial.println(" m");
    Serial.println("-----------------");
  }

  Serial.println();

  // Wait for 1 minute (60000 milliseconds)
  delay(60000);
}