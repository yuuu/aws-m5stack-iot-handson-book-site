#include <M5StampC3LED.h>

M5StampC3LED led = M5StampC3LED();

void setup() {
  Serial.begin(115200);
}

void loop() {
  Serial.println("Environment Sensor Starting...");
  led.show(255, 0, 0);
  delay(1000);
  led.show(0, 255, 0);
  delay(1000);
  led.show(0, 0, 255);
  delay(1000);
  led.clear();
  delay(1000);
}