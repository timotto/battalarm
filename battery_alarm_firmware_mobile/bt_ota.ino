#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <Update.h>
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

#define BT_OTA_STATE_IDLE 0
#define BT_OTA_STATE_ERROR 1
#define BT_OTA_STATE_EXPECTING 2
#define BT_OTA_STATE_COMPLETE 3
#define BT_OTA_ERROR_NONE 0
#define BT_OTA_ERROR_BAD_STATE 1
#define BT_OTA_ERROR_BAD_COMMAND 2
#define BT_OTA_ERROR_BEGIN_UPDATE 3
#define BT_OTA_ERROR_SIZE 4
#define BT_OTA_ERROR_CHECKSUM 5
#define BT_OTA_ERROR_UPDATE_END 6

#define BT_OTA_COMMAND_BEGIN   0x01
#define BT_OTA_COMMAND_ABORT   0x02
#define BT_OTA_COMMAND_SEND    0x03

#define BT_OTA_STATUS_IDLE     0x11
#define BT_OTA_STATUS_ERROR    0x12
#define BT_OTA_STATUS_EXPECT   0x13
#define BT_OTA_STATUS_COMPLETE 0x14

int _bt_ota_state = BT_OTA_STATE_IDLE;
bool _bt_ota_state_dirty = true;
int _bt_ota_error = BT_OTA_ERROR_NONE;
uint32_t _bt_ota_expected_size = 0;
uint8_t _bt_ota_expected_sha256[32] = {0};
uint32_t _bt_ota_receive_size = 0;
bool _bt_ota_begin = false;
bool _bt_ota_abort = false;
mbedtls_md_context_t _bt_ota_abort_sha_ctx;

void _bt_loop_ota(const uint32_t now) {
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
}

void _bt_ota_on_u2d(uint8_t *data, const size_t len) {
  if (len < 1) return;
  switch(data[0]) {
    case BT_OTA_COMMAND_BEGIN:
      if (_bt_ota_state != BT_OTA_STATE_IDLE) {
        _bt_ota_error = BT_OTA_ERROR_BAD_STATE;
        _bt_ota_set_state(BT_OTA_STATUS_ERROR);
        return;
      }

      if (len != 37) {
        _bt_ota_error = BT_OTA_ERROR_BAD_COMMAND;
        _bt_ota_set_state(BT_OTA_STATUS_ERROR);
        return;
      }

      _bt_ota_expected_size = data[1] | (data[2] << 8) | (data[3] << 16) | (data[4] << 24);
      memcpy(_bt_ota_expected_sha256, &data[5], 32);
      _bt_ota_receive_size = 0;
      _bt_ota_begin = true;
      _bt_ota_set_state(BT_OTA_STATE_EXPECTING);
      return;

    case BT_OTA_COMMAND_ABORT:
      _bt_ota_abort = true;
      return;

    case BT_OTA_COMMAND_SEND:
      _bt_ota_on_data(&data[1], len - 1);
      return;
  }
}

void _bt_ota_set_state(int value) {
  _bt_ota_state_dirty = true;
  _bt_ota_state = value;
}

void _bt_ota_set_d2u() {
  uint8_t buffer[5];
  size_t len;

  switch (_bt_ota_state) {
    case BT_OTA_STATE_IDLE:
      buffer[0] = BT_OTA_STATUS_IDLE;
      len = 1;
      break;

    case BT_OTA_STATE_EXPECTING:
      buffer[1] = BT_OTA_STATUS_EXPECT;
      buffer[2] = (_bt_ota_receive_size & 0xff);
      buffer[3] = ((_bt_ota_receive_size >> 8) & 0xff);
      buffer[4] = ((_bt_ota_receive_size >> 16) & 0xff);
      buffer[5] = ((_bt_ota_receive_size >> 24) & 0xff);
      len = 5;
      break;

    default:
      return;
  }

  _bt_chr_ota_d2u->setValue(buffer, len);
  _bt_chr_ota_d2u->notify();
}

void _bt_ota_on_data(uint8_t *data, size_t len) {
  size_t written = Update.write(data, len);
  _bt_ota_receive_size += written;

  mbedtls_md_update(&_bt_ota_abort_sha_ctx, (const unsigned char *) data, len);

  if (_bt_ota_receive_size < _bt_ota_expected_size) {
    _bt_ota_set_state(BT_OTA_STATE_EXPECTING);
    return;
  }

  if (_bt_ota_receive_size > _bt_ota_expected_size) {
    Update.abort();
    _bt_ota_error = BT_OTA_ERROR_SIZE;
    _bt_ota_set_state(BT_OTA_STATUS_ERROR);
    return;
  }

  byte shaResult[32];
  mbedtls_md_finish(&_bt_ota_abort_sha_ctx, shaResult);
  mbedtls_md_free(&_bt_ota_abort_sha_ctx);

  if (memcmp(_bt_ota_expected_sha256, shaResult, 32) != 0) {
    Update.abort();
    _bt_ota_error = BT_OTA_ERROR_CHECKSUM;
    _bt_ota_set_state(BT_OTA_STATUS_ERROR);
    return;
  }

  if (!Update.end()) {
    _bt_ota_error = BT_OTA_ERROR_UPDATE_END;
    _bt_ota_set_state(BT_OTA_STATUS_ERROR);
    return;
  }

  _bt_ota_set_state(BT_OTA_STATE_COMPLETE);
}

void _bt_ota_begin_update() {
  if (!Update.begin(_bt_ota_expected_size)) {
    _bt_ota_error = BT_OTA_ERROR_BEGIN_UPDATE;
    _bt_ota_set_state(BT_OTA_STATUS_ERROR);
    return;
  }

  mbedtls_md_type_t md_type = MBEDTLS_MD_SHA256;
  mbedtls_md_init(&_bt_ota_abort_sha_ctx);
  mbedtls_md_setup(&_bt_ota_abort_sha_ctx, mbedtls_md_info_from_type(md_type), 0);
  mbedtls_md_starts(&_bt_ota_abort_sha_ctx);
}

void _bt_ota_abort_update() {
  if (_bt_ota_state != BT_OTA_STATE_EXPECTING) {
    return;
  }

  Update.abort();

  mbedtls_md_free(&_bt_ota_abort_sha_ctx);
}
