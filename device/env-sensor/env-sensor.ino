#include <M5Unified.h>
#include <M5UnitUnified.h>
#include <M5UnitUnifiedENV.h>
#include <TaskScheduler.h>

typedef struct 
{
  float temperature;
  float humidity;
  float pressure;
} Sensor;

void initSensor();
bool readSensor();
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
  Task task(5000, TASK_FOREVER, &doTask);
  Scheduler runner;
}

void setup()
{
  M5.begin();
  initSensor();

  runner.init();
  runner.addTask(task);
  task.enable();
}

void loop()
{
  runner.execute();
}

void initSensor()
{
  auto pin_num_sda = M5.getPin(m5::pin_name_t::port_a_sda);
  auto pin_num_scl = M5.getPin(m5::pin_name_t::port_a_scl);

  Wire.end();
  Wire.begin(pin_num_sda, pin_num_scl, 400000U);

  if (!Units.add(unitENV3, Wire) || !Units.begin())
  {
    M5_LOGE("Failed to begin");
    exit();
  }
}

bool readSensor()
{
  if (!sht30.updated() || !qmp6988.updated())
  {
    return false;
  }

  sensor.temperature = sht30.temperature();
  sensor.humidity = sht30.humidity();
  sensor.pressure = qmp6988.pressure() * 0.01f;
  return true;
}

void doTask()
{
  M5.update();
  Units.update();

  if(readSensor()) {
    M5.Log.printf(
      "Temperature: %2.2f, Humidity:%2.2f, Pressure: %.2f\n",
      sensor.temperature,
      sensor.humidity,
      sensor.pressure
    );
  }
}

void exit() {
  while(true) {
    delay(1000);
  }
}
