#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include "config.h"

#define BT_SERVICE_STATUS_UUID "106145DE-E2DA-435D-A093-C8C5CA870100"
#define BT_CHARACTERISTIC_STATUS_UUID_IN_GARAGE "106145DE-E2DA-435D-A093-C8C5CA870101"
#define BT_CHARACTERISTIC_STATUS_UUID_CHARGING "106145DE-E2DA-435D-A093-C8C5CA870102"
#define BT_CHARACTERISTIC_STATUS_UUID_ENGINE "106145DE-E2DA-435D-A093-C8C5CA870103"
#define BT_CHARACTERISTIC_STATUS_UUID_VBAT "106145DE-E2DA-435D-A093-C8C5CA870111"
#define BT_CHARACTERISTIC_STATUS_UUID_VBAT_DELTA "106145DE-E2DA-435D-A093-C8C5CA870112"
#define BT_CHARACTERISTIC_STATUS_UUID_RSSI "106145DE-E2DA-435D-A093-C8C5CA870121"

BLECharacteristic *_bt_chr_status_inGarage;
BLECharacteristic *_bt_chr_status_charging;
BLECharacteristic *_bt_chr_status_engine;
BLECharacteristic *_bt_chr_status_vbat;
BLECharacteristic *_bt_chr_status_vbat_delta;
BLECharacteristic *_bt_chr_status_rssi;

#define BT_CREATE_CHR_RDNTFY(p, c, u) { \
  c = p->createCharacteristic(u, BLECharacteristic::PROPERTY_READ|BLECharacteristic::PROPERTY_NOTIFY); \
  c->addDescriptor(new BLE2902()); \
}

void _bt_setup_chr_status(BLEServer *pServer) {
  BLEService *pService = pServer->createService(BLEUUID(BT_SERVICE_STATUS_UUID), 20);

  BT_CREATE_CHR_RDNTFY(pService, _bt_chr_status_inGarage, BT_CHARACTERISTIC_STATUS_UUID_IN_GARAGE);
  BT_CREATE_CHR_RDNTFY(pService, _bt_chr_status_charging, BT_CHARACTERISTIC_STATUS_UUID_CHARGING);
  BT_CREATE_CHR_RDNTFY(pService, _bt_chr_status_engine, BT_CHARACTERISTIC_STATUS_UUID_ENGINE);
  BT_CREATE_CHR_RDNTFY(pService, _bt_chr_status_vbat, BT_CHARACTERISTIC_STATUS_UUID_VBAT);
  BT_CREATE_CHR_RDNTFY(pService, _bt_chr_status_vbat_delta, BT_CHARACTERISTIC_STATUS_UUID_VBAT_DELTA);
  BT_CREATE_CHR_RDNTFY(pService, _bt_chr_status_rssi, BT_CHARACTERISTIC_STATUS_UUID_RSSI);

  pServer->getAdvertising()->addServiceUUID(BLEUUID(BT_SERVICE_STATUS_UUID));
  pService->start();
}

void _bt_loop_chr_setBool(BLECharacteristic *chr, char* current, bool val);
void _bt_loop_chr_setFloat(BLECharacteristic *chr, float* current, float val, int digits);

void _bt_loop_chr_status(const uint32_t now, bool deviceConnected) {
  if (!deviceConnected) return;

  static char inGarage = -1;
  static char charging = -1;
  static char engine = -1;
  static float vbat = -1;
  static float vbatDelta = -1;
  static float rssi = -1;

  _bt_loop_chr_setBool(_bt_chr_status_inGarage, &inGarage, bt_isInGarage());
  _bt_loop_chr_setBool(_bt_chr_status_charging, &charging, vbat_isCharging());
  _bt_loop_chr_setBool(_bt_chr_status_engine, &engine, vbat_isEngineRunning());
  _bt_loop_chr_setFloat(_bt_chr_status_vbat, &vbat, vbat_voltLp(), 1);
  _bt_loop_chr_setFloat(_bt_chr_status_vbat_delta, &vbatDelta, vbat_voltDelta(), 2);
  _bt_loop_chr_setFloat(_bt_chr_status_rssi, &rssi, bt_rssiLp(), 0);
}

void _bt_loop_chr_setBool(BLECharacteristic *chr, char* current, bool val) {
  char c = val ? 1 : 0;
  if (c == *current) return;
  *current = c;
  chr->setValue((uint8_t*)current, 1);
  chr->notify();
}

void _bt_loop_chr_setFloat(BLECharacteristic *chr, float* current, float val, int digits) {
  if (val == *current) return;
  *current = val;

  char fmt[8];
  memset(fmt, 0, 8);
  snprintf(fmt, sizeof(fmt), "%%.0%df", digits);

  char buffer[16];
  memset(buffer, 0, 16);
  snprintf(buffer, sizeof(buffer), fmt, val);

  chr->setValue((uint8_t*)buffer, strlen(buffer));
  chr->notify();
}
