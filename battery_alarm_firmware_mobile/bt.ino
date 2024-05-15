#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEScan.h>
#include <BLEAdvertisedDevice.h>
#include "config.h"

BLEScan *pBLEScan;
bool _bt_scanPrint = false;
bool _bt_scanActive = false;
uint32_t _bt_beaconLastSeen = 0;
int _bt_beaconRssi = -100;
float _bt_beaconRssiLp = -100;
bool _bt_isInGarage = false;

bool _bt_debug = false;

bool _bt_fakeInGarageValue = false;
bool _bt_fakeInGarageEnabled = false;

void bt_setBeacon(String addr) {
  configBtBeaconAddr = addr;
  pref_save();
}

bool bt_isInGarage() {
  if (_bt_fakeInGarageEnabled) {
    return _bt_fakeInGarageValue;
  }

  return _bt_isInGarage;
}

// called when the vehicle is charging but not reported as "in the garage"
// it checks if the configured rssi value is quite close to the actual
// and then reduces the configured rssi value to better match the actual.
void bt_maybeReduceRssi(const uint32_t now) {
  static uint32_t last_time = 0;
  const uint32_t dt = now - last_time;
  if (dt < 15000) return;
  last_time = now;

  const uint32_t dtSeen = now - _bt_beaconLastSeen;
  if (dtSeen > 2*BT_SCAN_INTERVAL) return;

  if (configBtBeaconRssiInGarage < -80) return;

  float delta = configBtBeaconRssiInGarage - _bt_beaconRssiLp;
  if (delta > 10) return;

  float betterRssi = configBtBeaconRssiInGarage - 1.0;
  Serial.printf("bt: maybe-reduce-rssi: better value: current=%.0f better=%.0f\n", configBtBeaconRssiInGarage, betterRssi);
 
  configBtBeaconRssiInGarage = betterRssi;
  
  pref_save();
}

void _bt_maybeIncreaseRssi(const uint32_t now) {
  static uint32_t last_time = 0;
  const uint32_t dt = now - last_time;
  if (dt < 15000) return;
  last_time = now;

  const uint32_t dtSeen = now - _bt_beaconLastSeen;
  if (dtSeen > 2*BT_SCAN_INTERVAL) return;

  if (configBtBeaconRssiInGarage > -55) return;

  float delta = _bt_beaconRssiLp - configBtBeaconRssiInGarage;
  if (delta < 5) return;

  float betterRssi = configBtBeaconRssiInGarage + 1.0;
  Serial.printf("bt: maybe-increase-rssi: better value: current=%.0f better=%.0f\n", configBtBeaconRssiInGarage, betterRssi);
 
  configBtBeaconRssiInGarage = betterRssi;
  
  pref_save();
}

void bt_fake_isInGarage(bool value) {
  _bt_fakeInGarageValue = value;
  _bt_fakeInGarageEnabled = true;
}

void bt_fake_isInGarageOff() {
  _bt_fakeInGarageEnabled = false;
}

void bt_scan() {
  _bt_scanPrint = true;
}

void bt_debugOn() {
  _bt_debug = true;
}

void bt_debugOff() {
  _bt_debug = false;
}

class BatteryAlarmDeviceCallbacks : public BLEAdvertisedDeviceCallbacks {
  void onResult(BLEAdvertisedDevice d) {
    String addr = d.getAddress().toString().c_str();
    if (addr.equals(configBtBeaconAddr)) {
      int rssi = d.getRSSI();
      _bt_onBeaconRssi(rssi);
      if (_bt_debug) {
        Serial.printf("bt: debug: beacon rssi=%d\n", rssi);
      }
    }

    if (!_bt_scanPrint) return;

    Serial.print("Device address: ");
    Serial.println(d.getAddress().toString().c_str());

    if (d.haveName()) {
      Serial.print("Device name: ");
      Serial.println(d.getName().c_str());
    }

    Serial.print("RSSI: ");
    Serial.println(d.getRSSI());
    Serial.println();
  }
};

void setup_bt() {
  BLEDevice::init("Battalarm");
  pBLEScan = BLEDevice::getScan();
  pBLEScan->setAdvertisedDeviceCallbacks(new BatteryAlarmDeviceCallbacks(), true);
  pBLEScan->setActiveScan(false);
  pBLEScan->setInterval(100);
  pBLEScan->setWindow(99);  // less or equal setInterval value
}

void _bt_onScanResults(BLEScanResults results);

void loop_bt(const uint32_t now) {
  _bt_loop_scan(now);
  _bt_loop_compute(now);
  _bt_loop_debug(now);
}

void _bt_loop_scan(const uint32_t now) {
  static uint32_t last_time = 0;
  const uint32_t dt = now - last_time;
  if (dt < BT_SCAN_INTERVAL && !_bt_scanPrint) return;
  if (_bt_scanActive) return;
  last_time = now;

  if (_bt_scanPrint) {
    Serial.println("bt: scanning");
  }

  _bt_scanActive = true;
  pBLEScan->start(BT_SCAN_DURATION / 1000, &_bt_onScanResults, false);
}

void _bt_loop_compute(const uint32_t now) {
  static bool last_state = false;
  static uint32_t last_state_change = 0;

  bool state;
  if ((millis() - _bt_beaconLastSeen) > 2 * BT_SCAN_INTERVAL) {
    state = false;
  } else {
    float delta = _bt_beaconRssiLp - configBtBeaconRssiInGarage;
    state = delta >= 0;
    if (delta > 10) _bt_maybeIncreaseRssi(now);
  }

  if (state != last_state) {
    last_state = state;
    last_state_change = now;
  }

  if (_bt_isInGarage != state) {
    const uint32_t dt = now - last_state_change;
    if (dt > 1000) {
      _bt_isInGarage = state;
    }
  }
}

void _bt_loop_debug(const uint32_t now) {
  if (!_bt_debug) return;

  static uint32_t last_time = 0;
  const uint32_t dt = now - last_time;
  if (dt < 2000) return;
  last_time = now;

  Serial.printf(
    "bt: beacon: in_garage=%s rssi=%d rssi_lp=%.0f last seen=%lu\n", 
    _bt_isInGarage ? "true" : "false", _bt_beaconRssi, _bt_beaconRssiLp, millis() - _bt_beaconLastSeen);
}

void _bt_onBeaconRssi(int value) {
  _bt_beaconLastSeen = millis();
  _bt_beaconRssi = value;

  _bt_beaconRssiLp = (_bt_beaconRssiLp + _bt_beaconRssi) / 2;
}

void _bt_onScanResults(BLEScanResults results) {
  if (_bt_scanPrint) {
    Serial.println("bt: scan complete");
  }
  _bt_scanActive = false;
  _bt_scanPrint = false;
  pBLEScan->clearResults();
}
