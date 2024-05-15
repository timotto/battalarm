#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEScan.h>
#include <BLEAdvertisedDevice.h>
#include <BLE2902.h>
#include "config.h"

BLEScan *pBLEScan;
BLEServer *pServer;
BLECharacteristic *pCharacteristicConfig;

bool _bt_advertisingEnabled = false;
uint32_t _bt_advertisingEnabledSince = 0;
bool _bt_allowPairing = false;
uint32_t _bt_allowPairingSince = 0;

bool _bt_scanPrint = false;
bool _bt_scanActive = false;
uint32_t _bt_beaconLastSeen = 0;
int _bt_beaconRssi = -100;
float _bt_beaconRssiLp = -100;
bool _bt_isInGarage = false;

bool _bt_debug = false;

bool _bt_fakeInGarageValue = false;
bool _bt_fakeInGarageEnabled = false;

void bt_status() {
  Serial.printf(
    "Bluetooth status:\n"
    "  RSSI (last): %d\n"
    "  RSSI (lp): %.0f\n"
    "  Last seen: %lu\n"
    ,
    _bt_beaconRssi, _bt_beaconRssiLp, (millis() - _bt_beaconLastSeen)
  );
}

bool bt_toggleAuthentication() {
  _bt_allowPairing = !_bt_allowPairing;
  Serial.printf("bt: allow auth: %s\n", _bt_allowPairing ? "true" : "false");
  if (_bt_allowPairing) _bt_allowPairingSince = millis();
  return _bt_allowPairing;
}

bool bt_toggleVisibility() {
  _bt_advertisingEnabled = !_bt_advertisingEnabled;
  Serial.printf("bt: visible: %s\n", _bt_advertisingEnabled ? "true" : "false");
  if (_bt_advertisingEnabled) _bt_advertisingEnabledSince = millis();
  return _bt_advertisingEnabled;
}

bool bt_isAuthentication() {
  return _bt_allowPairing;
}

bool bt_isVisible() {
  return _bt_advertisingEnabled;
}

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

float bt_rssiLp() {
  return _bt_beaconRssiLp;
}

// called when the vehicle is charging but not reported as "in the garage"
// it checks if the configured rssi value is quite close to the actual
// and then reduces the configured rssi value to better match the actual.
void bt_maybeReduceRssi(const uint32_t now) {
  if (!configBtBeaconRssiAutoTune) return;
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
  if (!configBtBeaconRssiAutoTune) return;
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

bool _bt_deviceConnected = false;
bool _bt_advertisingActive = false;

class BtSecurityCallbacks : public BLESecurityCallbacks {
  bool onSecurityRequest() {
    return _bt_allowPairing;
  }

  bool onConfirmPIN(uint32_t pin) {
    return _bt_allowPairing;
  }

	uint32_t onPassKeyRequest(){
		return 123456;
	}

	void onPassKeyNotify(uint32_t pass_key){
        // ESP_LOGI(LOG_TAG, "On passkey Notify number:%d", pass_key);
	}

	void onAuthenticationComplete(esp_ble_auth_cmpl_t cmpl){
		// ESP_LOGI(LOG_TAG, "Starting BLE work!");
		if(cmpl.success){
			uint16_t length;
			esp_ble_gap_get_whitelist_size(&length);
			// ESP_LOGD(LOG_TAG, "size: %d", length);
		}
	}
};

class BtServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    _bt_deviceConnected = true;
  }

  void onDisconnect(BLEServer* pServer) {
    _bt_deviceConnected = false;
    _bt_setAdvertising(true);
  }
};

class BtScanCallbacks : public BLEAdvertisedDeviceCallbacks {
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

  BLEDevice::setSecurityCallbacks(new BtSecurityCallbacks());
  BLEDevice::setEncryptionLevel(ESP_BLE_SEC_ENCRYPT);

  BLESecurity *btSec = new BLESecurity();
  btSec->setCapability(ESP_IO_CAP_IO);

  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new BtServerCallbacks());

  _bt_setup_service();
  _bt_setup_scan();
}

void _bt_setup_chr_status(BLEServer *pServer);
void _bt_setup_chr_config(BLEServer *pServer);

void _bt_setup_service() {
  BLEAdvertising* pAdvertising;
  pAdvertising = pServer->getAdvertising();
  pAdvertising->stop();
  pAdvertising->setMinInterval(500);
  pAdvertising->setMaxInterval(1000);

  _bt_setup_chr_status(pServer);
  _bt_setup_chr_config(pServer);

  _bt_setAdvertising(true);
}

void _bt_setup_scan() {
  pBLEScan = BLEDevice::getScan();
  pBLEScan->setAdvertisedDeviceCallbacks(new BtScanCallbacks(), true);
  pBLEScan->setActiveScan(false);
  pBLEScan->setInterval(100);
  pBLEScan->setWindow(99);  // less or equal setInterval value
}

void _bt_onScanResults(BLEScanResults results);

void loop_bt(const uint32_t now) {
  _bt_loop_scan(now);
  _bt_loop_compute(now);
  _bt_loop_chr(now);
  _bt_loop_toggle(now);
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
  _bt_setAdvertising(false);
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
    if (dt > 10000) {
      _bt_isInGarage = state;
    }
  }
}

void _bt_loop_chr_status(const uint32_t now, bool deviceConnected);
void _bt_loop_chr_config(const uint32_t now, bool deviceConnected);

void _bt_loop_chr(const uint32_t now) {
  static uint32_t last_time = 0;
  const uint32_t dt = now - last_time;
  if (dt < 1000) return;
  last_time = now;

  _bt_loop_chr_status(now, _bt_deviceConnected);
  _bt_loop_chr_config(now, _bt_deviceConnected);
}

void _bt_loop_toggle(const uint32_t now) {
  if (_bt_advertisingEnabled) {
    if ((now - _bt_advertisingEnabledSince) > 60000) {
      bt_toggleVisibility();
    }
  }

  if (_bt_allowPairing) {
    if ((now - _bt_allowPairingSince) > 60000) {
      bt_toggleAuthentication();
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
  static bool first = true;
  _bt_beaconLastSeen = millis();
  _bt_beaconRssi = value;

  float f = value;
  if (first) {
    first = false;
    _bt_beaconRssiLp = f;
  }

  _bt_beaconRssiLp = 0.9 * _bt_beaconRssiLp + 0.1 * f;
}

void _bt_onScanResults(BLEScanResults results) {
  if (_bt_scanPrint) {
    Serial.println("bt: scan complete");
  }
  _bt_scanActive = false;
  _bt_scanPrint = false;
  pBLEScan->clearResults();

  _bt_setAdvertising(true);
}

void _bt_setAdvertising(bool on) {
  if (on && _bt_advertisingEnabled) {
    pServer->getAdvertising()->start();
    _bt_advertisingActive = true;
  } else if (!on && _bt_advertisingActive) {
    pServer->getAdvertising()->stop();
    _bt_advertisingActive = false;
  }
}
