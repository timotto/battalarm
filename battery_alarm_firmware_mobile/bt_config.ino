#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include "config.h"

#define BT_SERVICE_CONFIG_UUID "106145DE-E2DA-435D-A093-C8C5CA870200"
#define BT_CHARACTERISTIC_CONFIG_UUID_DELAY_WARN "106145DE-E2DA-435D-A093-C8C5CA870201"
#define BT_CHARACTERISTIC_CONFIG_UUID_DELAY_ALARM "106145DE-E2DA-435D-A093-C8C5CA870202"
#define BT_CHARACTERISTIC_CONFIG_UUID_DELAY_SNOOZE "106145DE-E2DA-435D-A093-C8C5CA870203"
#define BT_CHARACTERISTIC_CONFIG_UUID_VBAT_LP_F "106145DE-E2DA-435D-A093-C8C5CA870211"
#define BT_CHARACTERISTIC_CONFIG_UUID_VBAT_CHARGE_T "106145DE-E2DA-435D-A093-C8C5CA870212"
#define BT_CHARACTERISTIC_CONFIG_UUID_VBAT_DELTA_T "106145DE-E2DA-435D-A093-C8C5CA870213"
#define BT_CHARACTERISTIC_CONFIG_UUID_VBAT_TUNE_F "106145DE-E2DA-435D-A093-C8C5CA870214"
#define BT_CHARACTERISTIC_CONFIG_UUID_BT_BEACON "106145DE-E2DA-435D-A093-C8C5CA870221"
#define BT_CHARACTERISTIC_CONFIG_UUID_BT_RSSI_T "106145DE-E2DA-435D-A093-C8C5CA870222"
#define BT_CHARACTERISTIC_CONFIG_UUID_BT_RSSI_AUTO_TUNE "106145DE-E2DA-435D-A093-C8C5CA870223"
#define BT_CHARACTERISTIC_CONFIG_UUID_BUZZER_ALERTS "106145DE-E2DA-435D-A093-C8C5CA870231"

BLECharacteristic *_bt_chr_config_delayWarn;
BLECharacteristic *_bt_chr_config_delayAlarm;
BLECharacteristic *_bt_chr_config_delaySnooze;
BLECharacteristic *_bt_chr_config_vbatLpF;
BLECharacteristic *_bt_chr_config_vbatChargeT;
BLECharacteristic *_bt_chr_config_vbatDeltaT;
BLECharacteristic *_bt_chr_config_vbatTuneF;
BLECharacteristic *_bt_chr_config_btBeacon;
BLECharacteristic *_bt_chr_config_btRssiT;
BLECharacteristic *_bt_chr_config_btRssiAutoTune;
BLECharacteristic *_bt_chr_config_buzzerAlerts;
#define BT_CONFIG_COUNT 11

#define BT_CREATE_CFG_CHR_RDWR(p, cb, c, u) \
  { \
    c = p->createCharacteristic(u, BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE); \
    c->setCallbacks(cb); \
    c->addDescriptor(new BLE2902()); \
  }

#define BT_CREATE_CFG_CHR_RDWRNTFY(p, cb, c, u) \
  { \
    c = p->createCharacteristic(u, BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_NOTIFY); \
    c->setCallbacks(cb); \
    c->addDescriptor(new BLE2902()); \
  }

bool _bt_parse_chr_string(BLECharacteristic *chr, String *dst);
bool _bt_parse_chr_float(BLECharacteristic *chr, float *dst, float min, float max);
bool _bt_parse_chr_uint(BLECharacteristic *chr, uint32_t *dst, uint32_t min, uint32_t max);
bool _bt_parse_chr_bool(BLECharacteristic *chr, bool *dst);

class BtConfigCharacteristic : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pChr) {
    String strVal;
    float floatVal;
    uint32_t uintVal;
    bool boolVal;

    if (pChr == _bt_chr_config_delayWarn && _bt_parse_chr_uint(pChr, &uintVal, CONFIG_DELAY_WARN_MIN, CONFIG_DELAY_WARN_MAX)) {
      configDelayWarn = uintVal;
    } else if (pChr == _bt_chr_config_delayAlarm && _bt_parse_chr_uint(pChr, &uintVal, CONFIG_DELAY_ALERT_MIN, CONFIG_DELAY_ALERT_MAX)) {
      configDelayAlarm = uintVal;
    } else if (pChr == _bt_chr_config_delaySnooze && _bt_parse_chr_uint(pChr, &uintVal, CONFIG_DELAY_SNOOZE_MIN, CONFIG_DELAY_SNOOZE_MAX)) {
      configSnoozeTime = uintVal;
    } else if (pChr == _bt_chr_config_vbatLpF && _bt_parse_chr_float(pChr, &floatVal, CONFIG_VBAT_LPF_MIN, CONFIG_VBAT_LPF_MAX)) {
      configVbatLpF = floatVal;
    } else if (pChr == _bt_chr_config_vbatChargeT && _bt_parse_chr_float(pChr, &floatVal, CONFIG_VBAT_CHARGE_T_MIN, CONFIG_VBAT_CHARGE_T_MAX)) {
      configVbatChargeVoltage = floatVal;
    } else if (pChr == _bt_chr_config_vbatDeltaT && _bt_parse_chr_float(pChr, &floatVal, CONFIG_VBAT_DELTA_T_MIN, CONFIG_VBAT_DELTA_T_MAX)) {
      configVbatChargeDeltaThreshold = floatVal;
    } else if (pChr == _bt_chr_config_vbatTuneF && _bt_parse_chr_float(pChr, &floatVal, CONFIG_VBAT_TUNE_F_MIN, CONFIG_VBAT_TUNE_F_MAX)) {
      configVbatTuneF = floatVal;
    } else if (pChr == _bt_chr_config_btBeacon && _bt_parse_chr_string(pChr, &strVal)) {
      configBtBeaconAddr = strVal;
    } else if (pChr == _bt_chr_config_btRssiT && _bt_parse_chr_float(pChr, &floatVal, CONFIG_RSSI_T_MIN, CONFIG_RSSI_T_MAX)) {
      configBtBeaconRssiInGarage = floatVal;
    } else if (pChr == _bt_chr_config_btRssiAutoTune && _bt_parse_chr_bool(pChr, &boolVal)) {
      configBtBeaconRssiAutoTune = boolVal;
    } else if (pChr == _bt_chr_config_buzzerAlerts && _bt_parse_chr_uint(pChr, &uintVal, 0, BUZZER_ALERTS_MAX)) {
      configBuzzerAlerts = uintVal;
    } else {
      Serial.println("bt: config: bad write");
      return;
    }
    pref_save();
  }
};

void _bt_setup_chr_config(BLEServer *pServer) {
  BLEService *pService = pServer->createService(BLEUUID(BT_SERVICE_CONFIG_UUID), BT_CONFIG_COUNT * 4);
  BtConfigCharacteristic *pCb = new BtConfigCharacteristic();

  BT_CREATE_CFG_CHR_RDWR(pService, pCb, _bt_chr_config_delayWarn, BT_CHARACTERISTIC_CONFIG_UUID_DELAY_WARN);
  BT_CREATE_CFG_CHR_RDWR(pService, pCb, _bt_chr_config_delayAlarm, BT_CHARACTERISTIC_CONFIG_UUID_DELAY_ALARM);
  BT_CREATE_CFG_CHR_RDWR(pService, pCb, _bt_chr_config_delaySnooze, BT_CHARACTERISTIC_CONFIG_UUID_DELAY_SNOOZE);

  BT_CREATE_CFG_CHR_RDWR(pService, pCb, _bt_chr_config_vbatLpF, BT_CHARACTERISTIC_CONFIG_UUID_VBAT_LP_F);
  BT_CREATE_CFG_CHR_RDWR(pService, pCb, _bt_chr_config_vbatChargeT, BT_CHARACTERISTIC_CONFIG_UUID_VBAT_CHARGE_T);
  BT_CREATE_CFG_CHR_RDWR(pService, pCb, _bt_chr_config_vbatDeltaT, BT_CHARACTERISTIC_CONFIG_UUID_VBAT_DELTA_T);
  BT_CREATE_CFG_CHR_RDWR(pService, pCb, _bt_chr_config_vbatTuneF, BT_CHARACTERISTIC_CONFIG_UUID_VBAT_TUNE_F);

  BT_CREATE_CFG_CHR_RDWR(pService, pCb, _bt_chr_config_btBeacon, BT_CHARACTERISTIC_CONFIG_UUID_BT_BEACON);
  BT_CREATE_CFG_CHR_RDWRNTFY(pService, pCb, _bt_chr_config_btRssiT, BT_CHARACTERISTIC_CONFIG_UUID_BT_RSSI_T);
  BT_CREATE_CFG_CHR_RDWR(pService, pCb, _bt_chr_config_btRssiAutoTune, BT_CHARACTERISTIC_CONFIG_UUID_BT_RSSI_AUTO_TUNE);

  BT_CREATE_CFG_CHR_RDWR(pService, pCb, _bt_chr_config_buzzerAlerts, BT_CHARACTERISTIC_CONFIG_UUID_BUZZER_ALERTS);

  pServer->getAdvertising()->addServiceUUID(BLEUUID(BT_SERVICE_CONFIG_UUID));
  pService->start();
}

void _bt_loop_chr_cfg_setUInt32(BLECharacteristic *chr, bool notify, uint32_t *current, uint32_t val);
void _bt_loop_chr_cfg_setFloat(BLECharacteristic *chr, bool notify, float *current, float val, int digits);
void _bt_loop_chr_cfg_setString(BLECharacteristic *chr, bool notify, String *current, String val);
void _bt_loop_chr_cfg_setBool(BLECharacteristic *chr, bool notify, bool *current, bool val);

void _bt_loop_chr_config(const uint32_t now, bool deviceConnected) {
  if (!deviceConnected) return;

  static uint32_t delayWarn = 0xffffffff;
  static uint32_t delayAlarm = 0xffffffff;
  static uint32_t delaySnooze = 0xffffffff;
  static float vbatLpF = -1;
  static float vbatChargeT = -1;
  static float vbatDeltaT = -1;
  static float vbatTuneF = -1;
  static String btBeacon = "";
  static float btRssiT = -1;
  static bool btRssiAutoTune = false;
  static uint32_t buzzerAlerts = 0xffffffff;

  _bt_loop_chr_cfg_setUInt32(_bt_chr_config_delayWarn, false, &delayWarn, configDelayWarn);
  _bt_loop_chr_cfg_setUInt32(_bt_chr_config_delayAlarm, false, &delayAlarm, configDelayAlarm);
  _bt_loop_chr_cfg_setUInt32(_bt_chr_config_delaySnooze, false, &delaySnooze, configSnoozeTime);

  _bt_loop_chr_cfg_setFloat(_bt_chr_config_vbatLpF, false, &vbatLpF, configVbatLpF, 3);
  _bt_loop_chr_cfg_setFloat(_bt_chr_config_vbatChargeT, false, &vbatChargeT, configVbatChargeVoltage, 1);
  _bt_loop_chr_cfg_setFloat(_bt_chr_config_vbatDeltaT, false, &vbatDeltaT, configVbatChargeDeltaThreshold, 2);
  _bt_loop_chr_cfg_setFloat(_bt_chr_config_vbatTuneF, false, &vbatTuneF, configVbatTuneF, 2);

  _bt_loop_chr_cfg_setString(_bt_chr_config_btBeacon, false, &btBeacon, configBtBeaconAddr);
  _bt_loop_chr_cfg_setFloat(_bt_chr_config_btRssiT, true, &btRssiT, configBtBeaconRssiInGarage, 0);
  _bt_loop_chr_cfg_setBool(_bt_chr_config_btRssiAutoTune, false, &btRssiAutoTune, configBtBeaconRssiAutoTune);

  _bt_loop_chr_cfg_setUInt32(_bt_chr_config_buzzerAlerts, false, &buzzerAlerts, configBuzzerAlerts);
}

void _bt_loop_chr_cfg_setUInt32(BLECharacteristic *chr, bool notify, uint32_t *current, uint32_t val) {
  if (val == *current) return;
  *current = val;

  chr->setValue(val);
  if (notify) {
    chr->notify();
  }
}

void _bt_loop_chr_cfg_setFloat(BLECharacteristic *chr, bool notify, float *current, float val, int digits) {
  if (val == *current) return;
  *current = val;

  char fmt[8];
  memset(fmt, 0, 8);
  snprintf(fmt, sizeof(fmt), "%%.0%df", digits);

  char buffer[16];
  memset(buffer, 0, 16);
  snprintf(buffer, sizeof(buffer), fmt, val);

  chr->setValue((uint8_t *)buffer, strlen(buffer));
  if (notify) {
    chr->notify();
  }
}

void _bt_loop_chr_cfg_setString(BLECharacteristic *chr, bool notify, String *current, String val) {
  if (val.equals(*current)) return;
  *current = val;

  chr->setValue((uint8_t *)val.c_str(), val.length());
  if (notify) {
    chr->notify();
  }
}

void _bt_loop_chr_cfg_setBool(BLECharacteristic *chr, bool notify, bool *current, bool val) {
  if (val == *current) return;
  *current = val;

  uint8_t tmp = val ? 1 : 0;

  chr->setValue(&tmp, 1);
  if (notify) {
    chr->notify();
  }
}

bool _bt_parse_chr_string(BLECharacteristic *chr, String *dst) {
  std::string val = chr->getValue();
  if (val.length() == 0) return false;
  *dst = val.c_str();
  return true;
}

bool _bt_parse_chr_float(BLECharacteristic *chr, float *dst, float min, float max) {
  std::string val = chr->getValue();
  if (val.length() == 0) return false;
  float fval = atof(val.c_str());
  if (std::isnan(fval)) return false;
  if (fval < min || fval > max) return false;
  *dst = fval;
  return true;
}

bool _bt_parse_chr_uint(BLECharacteristic *chr, uint32_t *dst, uint32_t min, uint32_t max) {
  if (chr->getLength() != 4) return false;
  uint8_t *data = chr->getData();
  uint32_t val = data[0] | (data[1] << 8) | (data[2] << 16) | (data[3] << 24);
  if (val < min || val > max) return false;

  *dst = val;

  return true;
}

bool _bt_parse_chr_bool(BLECharacteristic *chr, bool *dst) {
  if (chr->getLength() != 1) return false;
  uint8_t *data = chr->getData();
  if (data[0] == 0 || data[0] == 1) {
    *dst = data[0] == 1;
    return true;
  }

  return false;
}
