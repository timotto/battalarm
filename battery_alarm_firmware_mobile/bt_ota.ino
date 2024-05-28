#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <flashz.hpp>
#include "mbedtls/md.h"
#include "version.h"

/* OTA Protocol:
d2u: device to updater
u2d: updater to device

u2d is used to send commands to the device
d2u is used to send status to the updater

u2d packet types:
  BEGIN:
    length: 1 + 4 + 32
    [0]: COMMAND_BEGIN
    [1..4]: size
    [5..36]: sha256

  ABORT:
    length: 1
    [0]: COMMAND_ABORT

  SEND:
    length: 1 + n
    [0]: COMMAND_SEND
    [1..n]: data

d2u packet types:
  IDLE:
    length: 1
    [0]: STATUS_IDLE

  ERROR:
    length: 1 + 1
    [0]: STATUS_ERROR
    [1]: reason

  EXPECT:
    length: 1 + 4
    [0]: STATUS_EXPECT
    [1..4]: expected offset

  COMPLETE:
    length: 1
    [0]: STATUS_COMPLETE

*/

#define BT_SERVICE_OTA_UUID "106145DE-E2DA-435D-A093-C8C5CA870300"
#define BT_CHARACTERISTIC_OTA_UUID_VERSION "106145DE-E2DA-435D-A093-C8C5CA870301"
#define BT_CHARACTERISTIC_OTA_UUID_D2U "106145DE-E2DA-435D-A093-C8C5CA870311"
#define BT_CHARACTERISTIC_OTA_UUID_U2D "106145DE-E2DA-435D-A093-C8C5CA870312"

BLECharacteristic *_bt_chr_ota_version;
BLECharacteristic *_bt_chr_ota_d2u;
BLECharacteristic *_bt_chr_ota_u2d;

class BtOtaCharacteristic : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pChr) {
    _bt_ota_on_u2d(pChr->getData(), pChr->getLength());
  }
};

void _bt_setup_ota(BLEServer *pServer) {
  BtOtaCharacteristic *pCb = new BtOtaCharacteristic();

  BLEService *pService = pServer->createService(BLEUUID(BT_SERVICE_OTA_UUID));

  _bt_chr_ota_version = pService->createCharacteristic(BT_CHARACTERISTIC_OTA_UUID_VERSION, BLECharacteristic::PROPERTY_READ);
  _bt_chr_ota_version->addDescriptor(new BLE2902());

  _bt_chr_ota_d2u = pService->createCharacteristic(BT_CHARACTERISTIC_OTA_UUID_D2U, BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY);
  _bt_chr_ota_d2u->addDescriptor(new BLE2902());

  _bt_chr_ota_u2d = pService->createCharacteristic(BT_CHARACTERISTIC_OTA_UUID_U2D, BLECharacteristic::PROPERTY_WRITE);
  _bt_chr_ota_u2d->addDescriptor(new BLE2902());
  _bt_chr_ota_u2d->setCallbacks(pCb);

  pService->start();
  _bt_chr_ota_version->setValue((uint8_t *)VERSION, strlen(VERSION));
}

#define BT_OTA_ERROR_NONE 0x00
#define BT_OTA_ERROR_BAD_STATE 0x01
#define BT_OTA_ERROR_BAD_ARGUMENTS 0x02
#define BT_OTA_ERROR_BAD_COMMAND 0x03
#define BT_OTA_ERROR_BEGIN_UPDATE 0x04
#define BT_OTA_ERROR_SIZE 0x05
#define BT_OTA_ERROR_CHECKSUM 0x06
#define BT_OTA_ERROR_UPDATE_END 0x07
#define BT_OTA_ERROR_SEND_TIMEOUT 0x08

#define BT_OTA_COMMAND_BEGIN   0x01
#define BT_OTA_COMMAND_ABORT   0x02
#define BT_OTA_COMMAND_SEND    0x03

#define BT_OTA_STATUS_IDLE     0x11
#define BT_OTA_STATUS_ERROR    0x12
#define BT_OTA_STATUS_EXPECT   0x13
#define BT_OTA_STATUS_COMPLETE 0x14

uint32_t _bt_ota_loop_millis = 0;
int _bt_ota_state = BT_OTA_STATUS_IDLE;
uint32_t _bt_ota_state_since = 0;
bool _bt_ota_state_dirty = true;
int _bt_ota_error = BT_OTA_ERROR_NONE;
uint32_t _bt_ota_expected_size = 0;
uint8_t _bt_ota_expected_sha256[32] = {0};
uint32_t _bt_ota_receive_size = 0;
bool _bt_ota_begin = false;
bool _bt_ota_abort = false;
mbedtls_md_context_t _bt_ota_abort_sha_ctx;
 bool _bt_ota_sha_started = false;
bool _bt_ota_update_started = false;

FlashZ& flashz = FlashZ::getInstance();

bool bt_ota_active() {
  return _bt_ota_state == BT_OTA_STATUS_EXPECT;
}

void _bt_loop_ota(const uint32_t now) {
  _bt_ota_loop_millis = now;

  if (_bt_ota_begin) {
    _bt_ota_begin = false;
    _bt_ota_begin_update();
  }

  if (_bt_ota_abort) {
    _bt_ota_abort = false;
    _bt_ota_abort_update();
  }

  if (_bt_ota_state_dirty) {
    _bt_ota_state_dirty = false;
    _bt_ota_set_d2u();
  }

  static bool was_error = false;
  if (_bt_ota_state == BT_OTA_STATUS_ERROR) {
    was_error = true;
    _bt_ota_cleanup();
  } else if (was_error) {
    was_error = false;
  }

  if (_bt_ota_state == BT_OTA_STATUS_EXPECT && (now - _bt_ota_state_since > 10000)) {
    _bt_ota_set_error(BT_OTA_ERROR_SEND_TIMEOUT);
  }

  if (_bt_ota_state == BT_OTA_STATUS_COMPLETE && (now - _bt_ota_state_since > 2000)) {
    ESP.restart();
    while(true);
  }
}

void _bt_ota_on_u2d(uint8_t *data, const size_t len) {
  if (len < 1) return;
  switch(data[0]) {
    case BT_OTA_COMMAND_BEGIN:
      if ((_bt_ota_state != BT_OTA_STATUS_IDLE) && (_bt_ota_state != BT_OTA_STATUS_ERROR)) {
        if (_bt_ota_state == BT_OTA_STATUS_EXPECT && _bt_ota_receive_size == 0) {
          _bt_ota_set_state(BT_OTA_STATUS_EXPECT);
          return;
        }

        Serial.printf("bt-ota::u2d::error::command=begin::bad-state\n");
        _bt_ota_set_error(BT_OTA_ERROR_BAD_STATE);
        return;
      }

      if (len != 37) {
        Serial.printf("bt-ota::u2d::error::command=begin::bad-arguments=%d\n", len);
        _bt_ota_set_error(BT_OTA_ERROR_BAD_ARGUMENTS);
        return;
      }

      _bt_ota_expected_size = data[1] | (data[2] << 8) | (data[3] << 16) | (data[4] << 24);
      memcpy(_bt_ota_expected_sha256, &data[5], 32);
      _bt_ota_receive_size = 0;
      _bt_ota_begin = true;
      _bt_ota_set_state(BT_OTA_STATUS_EXPECT);
      return;

    case BT_OTA_COMMAND_ABORT:
      _bt_ota_abort = true;
      return;

    case BT_OTA_COMMAND_SEND:
      if (len < 2) {
        Serial.printf("bt-ota::u2d::error::command=send::bad-arguments=%d\n", len);
        _bt_ota_set_error(BT_OTA_ERROR_BAD_ARGUMENTS);
        return;
      }

      _bt_ota_on_data(&data[1], len - 1);
      return;
    
    default:
      Serial.printf("bt-ota::u2d::error::bad-command\n");
      _bt_ota_set_error(BT_OTA_ERROR_BAD_COMMAND);
      return;
  }
}

void _bt_ota_set_state(int value) {
  _bt_ota_state_since = _bt_ota_loop_millis;
  _bt_ota_state_dirty = true;
  _bt_ota_state = value;
}

void _bt_ota_set_error(int value) {
  _bt_ota_error = value;
  _bt_ota_set_state(BT_OTA_STATUS_ERROR);
}

void _bt_ota_set_d2u() {
  uint8_t buffer[5];
  size_t len;

  switch (_bt_ota_state) {
    case BT_OTA_STATUS_IDLE:
      buffer[0] = BT_OTA_STATUS_IDLE;
      len = 1;
      break;

    case BT_OTA_STATUS_ERROR:
      buffer[0] = BT_OTA_STATUS_ERROR;
      buffer[1] = _bt_ota_error;
      len = 2;
      break;

    case BT_OTA_STATUS_EXPECT:
      buffer[0] = BT_OTA_STATUS_EXPECT;
      buffer[1] = (_bt_ota_receive_size & 0xff);
      buffer[2] = ((_bt_ota_receive_size >> 8) & 0xff);
      buffer[3] = ((_bt_ota_receive_size >> 16) & 0xff);
      buffer[4] = ((_bt_ota_receive_size >> 24) & 0xff);
      len = 5;
      break;

    case BT_OTA_STATUS_COMPLETE:
      buffer[0] = BT_OTA_STATUS_COMPLETE;
      len = 1;
      break;

    default:
      return;
  }

  _bt_chr_ota_d2u->setValue(buffer, len);
  _bt_chr_ota_d2u->notify();
}

void _bt_ota_on_data(uint8_t *data, size_t len) {
  const bool finalWrite = _bt_ota_receive_size + len >= _bt_ota_receive_size;

  size_t written = flashz.writez(data, len, finalWrite);
  _bt_ota_receive_size += written;

  mbedtls_md_update(&_bt_ota_abort_sha_ctx, (const unsigned char *) data, len);

  if (!finalWrite) {
    _bt_ota_set_state(BT_OTA_STATUS_EXPECT);
    return;
  }

  if (_bt_ota_receive_size > _bt_ota_expected_size) {
    _bt_ota_set_error(BT_OTA_ERROR_SIZE);
    return;
  }

  byte shaResult[32];
  mbedtls_md_finish(&_bt_ota_abort_sha_ctx, shaResult);
  mbedtls_md_free(&_bt_ota_abort_sha_ctx);

  _bt_ota_sha_started = false;

  if (memcmp(_bt_ota_expected_sha256, shaResult, 32) != 0) {
    _bt_ota_set_error(BT_OTA_ERROR_CHECKSUM);
    return;
  }

  if (!flashz.endz()) {
    _bt_ota_set_error(BT_OTA_ERROR_UPDATE_END);
    return;
  }

  _bt_ota_update_started = false;

  _bt_ota_set_state(BT_OTA_STATUS_COMPLETE);
}

void _bt_ota_begin_update() {
  if (!flashz.beginz()) {
    _bt_ota_set_error(BT_OTA_ERROR_BEGIN_UPDATE);
    return;
  }
  _bt_ota_update_started = true;

  mbedtls_md_type_t md_type = MBEDTLS_MD_SHA256;
  mbedtls_md_init(&_bt_ota_abort_sha_ctx);
  mbedtls_md_setup(&_bt_ota_abort_sha_ctx, mbedtls_md_info_from_type(md_type), 0);
  mbedtls_md_starts(&_bt_ota_abort_sha_ctx);

  _bt_ota_sha_started = true;
}

void _bt_ota_abort_update() {
  if (_bt_ota_state != BT_OTA_STATUS_EXPECT) {
    _bt_ota_set_state(BT_OTA_STATUS_IDLE);
    return;
  }

  _bt_ota_cleanup();

  _bt_ota_set_state(BT_OTA_STATUS_IDLE);
}

void _bt_ota_cleanup() {
  if (_bt_ota_update_started) {
    _bt_ota_update_started = false;
    flashz.abortz();
  }

  if (_bt_ota_sha_started) {
    _bt_ota_sha_started = false;
    mbedtls_md_free(&_bt_ota_abort_sha_ctx);
  }
}