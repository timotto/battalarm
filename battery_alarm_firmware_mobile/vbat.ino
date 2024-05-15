#include "config.h"

float _vbat_volt = 0;
float _vbat_voltLp = 0;
float _vbat_voltDelta = 0;
bool _vbat_voltFirst = true;
bool _vbat_charging = false;

bool _vbat_debug = false;
bool _vbat_fakeChargingValue = false;
bool _vbat_fakeChargingEnabled = false;

void vbat_status() {
  Serial.printf(
    "VBat status:\n"
    "  Volt (last): %.1f\n"
    "  Volt (lp): %.1f\n"
    "  Delta: %.2f\n"
    ,
    _vbat_volt, _vbat_voltLp, _vbat_voltDelta
  );
}

bool vbat_isCharging() {
  if (_vbat_fakeChargingEnabled) {
    return _vbat_fakeChargingValue;
  }

  return _vbat_charging;
}

void vbat_fake_charging(bool value) {
  _vbat_fakeChargingValue = value;
  _vbat_fakeChargingEnabled = true;
}

void vbat_fake_chargingOff() {
  _vbat_fakeChargingEnabled = false;
}

float vbat_volt() {
  return _vbat_volt;
}

float vbat_voltLp() {
  return _vbat_voltLp;
}

float vbat_voltDelta() {
  return _vbat_voltDelta;
}

void vbat_debug() {
  _vbat_debug = true;
}

void vbat_debugOff() {
  _vbat_debug = false;
}

void setup_vbat() {

}

float _vbat_delta_ref = 0;

void loop_vbat(const uint32_t now) {
  _vbat_loop_read(now);
  _vbat_loop_delta(now);
  _vbat_loop_compute(now);
  _vbat_loop_debug(now);
}

void _vbat_loop_read(const uint32_t now) {
  static uint32_t last_time = 0;
  const uint32_t dt = now - last_time;
  if (dt < 20) return;
  last_time = now;

  const uint16_t val = analogRead(PIN_VBAT);
  _vbat_volt = (float)val * VBAT_F * configVbatTuneF;

  if (_vbat_voltFirst) {
    _vbat_voltFirst = false;
    _vbat_voltLp = _vbat_volt;
    _vbat_delta_ref = _vbat_volt;
  }

  _vbat_voltLp = configVbatLpF * _vbat_voltLp + (1.0 - configVbatLpF) * _vbat_volt;
}

void _vbat_loop_delta(const uint32_t now) {
  static uint32_t last_time = 0;
  const uint32_t dt = now - last_time;
  if (dt < VBAT_DELTA_INTERVAL) return;
  last_time = now;

  const float delta = _vbat_voltLp - _vbat_delta_ref;
  _vbat_delta_ref = _vbat_voltLp;

  _vbat_voltDelta += delta;
  // reduce delta to 0 over time
  _vbat_voltDelta *= 1.0 - ((float)VBAT_DELTA_INTERVAL / (float)VBAT_DELTA_RESET);
}

void _vbat_loop_compute(const uint32_t now) {
  static bool last_state = false;
  static uint32_t last_state_change = 0;
  const bool state = (_vbat_voltLp >= configVbatChargeVoltage) || (_vbat_voltDelta >= configVbatChargeDeltaThreshold);

  if (state != last_state) {
    last_state = state;
    last_state_change = now;
  }

  if (_vbat_charging == state) return;

  const uint32_t dt = now - last_state_change;
  if (dt > 1000) {
    _vbat_charging = state;
  }
}

void _vbat_loop_debug(const uint32_t now) {
  if (!_vbat_debug) return;

  static uint32_t last_time = 0;
  if (now - last_time < 1000) return;
  last_time = now;

  Serial.printf("vbat: volt=%.1f voltLp=%.1f delta=%.1f\n", _vbat_volt, _vbat_voltLp, _vbat_voltDelta);
}

