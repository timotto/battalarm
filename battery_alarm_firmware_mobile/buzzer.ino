#include "pins.h"
#include "config.h"

// _buzzer_sequence_* 
// must terminate with the value "0"
// even index is the "on" duration, odd index the "off" duration
// when it terminates at an "on" index, it is a repeating sound
// when it terminates at an "off" index, it is a one-time sonud and the mode turns into "BUZZER_MODE_OFF" at completion.
const uint32_t _buzzer_sequence_hello[] = {10,40,10,40,10,0};
const uint32_t _buzzer_sequence_garage[] = {10,90,10,90,50,0};
const uint32_t _buzzer_sequence_garage_left[] = {150,150,10,90,10,0};
const uint32_t _buzzer_sequence_charging[] = {10,90,10,90,10,90,50,200,50,0};
const uint32_t _buzzer_sequence_button[] = {2,0};
const uint32_t _buzzer_sequence_button_long[] = {2,10,2,10,2,10,2,10,2,0};
const uint32_t _buzzer_sequence_button_ultra_long[] = {2,20,2,20,2,20,2,20,2,0};
const uint32_t _buzzer_sequence_warn[] = {20,4980,0};
const uint32_t _buzzer_sequence_alarm[] = {800,200,0};
const uint32_t _buzzer_sequence_snooze[] = {2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,0};
const uint32_t _buzzer_sequence_bt_visible_on[] = {10,90,10,90,200,0};
const uint32_t _buzzer_sequence_bt_visible_off[] = {200,200,10,90,10,0};
const uint32_t _buzzer_sequence_bt_pairing_on[] = {10,90,10,90,10,90,200,200,200,0};
const uint32_t _buzzer_sequence_bt_pairing_off[] = {200,200,200,200,10,90,10,90,10,0};
const uint32_t *_buzzer_sequence = NULL;

#define __buzzer_setMode(x) _buzzer_setMode((const uint32_t*)x)

void buzzer_setOff() {
  __buzzer_setMode(NULL);
}

void buzzer_setAlarm() {
  __buzzer_setMode(_buzzer_sequence_alarm);
}

void buzzer_setWarn() {
  __buzzer_setMode(_buzzer_sequence_warn);
}

void buzzer_setHello() {
  __buzzer_setMode(_buzzer_sequence_hello);
}

void buzzer_setGarage() {
  __buzzer_setMode(_buzzer_sequence_garage);
}

void buzzer_setGarageLeft() {
  __buzzer_setMode(_buzzer_sequence_garage_left);
}

void buzzer_setCharging() {
  __buzzer_setMode(_buzzer_sequence_charging);
}

void buzzer_setSnooze() {
  __buzzer_setMode(_buzzer_sequence_snooze);
}

void buzzer_setButton() {
  if (!_buzzer_canLowPrio()) return;
  __buzzer_setMode(_buzzer_sequence_button);
}

void buzzer_setButtonLong() {
  if (!_buzzer_canLowPrio()) return;
  __buzzer_setMode(_buzzer_sequence_button_long);
}

void buzzer_setButtonUltraLong() {
  if (!_buzzer_canLowPrio()) return;
  __buzzer_setMode(_buzzer_sequence_button_ultra_long);
}

void buzzer_setBtVisible(bool visible) {
  if (!_buzzer_canLowPrio()) return;
  __buzzer_setMode(visible ? _buzzer_sequence_bt_visible_on : _buzzer_sequence_bt_visible_off);
}

void buzzer_setBtPairing(bool allowd) {
  if (!_buzzer_canLowPrio()) return;
  __buzzer_setMode(allowd ? _buzzer_sequence_bt_pairing_on : _buzzer_sequence_bt_pairing_off);
}

int _buzzer_step = 0;

void setup_buzzer() {
  pinMode(PIN_BUZZER, OUTPUT);
  digitalWrite(PIN_BUZZER, LOW);
}

void loop_buzzer(const uint32_t now) {
  static uint32_t last_time = 0;
  const uint32_t dt = now - last_time;

  if (_buzzer_sequence == NULL) return;

  if (_buzzer_step > 0) {
    uint32_t period = _buzzer_sequence[_buzzer_step - 1];
    const uint32_t dt = now - last_time;
    if (dt < period) return;
  }

  bool on = _buzzer_step % 2 == 0;
  last_time = now;
  _buzzer_set(on);

  if (_buzzer_sequence[_buzzer_step] == 0) {
    // sequence end, defaults to repeat
    _buzzer_step = 0;
    if (!on) {
      // if sequence ends at an "off" value, it is not repeating
      _buzzer_setMode(NULL);
    }
  }

  // continue in sequence
  _buzzer_step++;
}

void _buzzer_set(bool on) {
  digitalWrite(PIN_BUZZER, on ? HIGH : LOW);
}

void _buzzer_setMode(const uint32_t *sequence) {
  _buzzer_set(false);
  _buzzer_step = 0;
  _buzzer_sequence = sequence;
}

bool _buzzer_canLowPrio() {
  if (_buzzer_sequence == NULL) return true;
  if (_buzzer_sequence == _buzzer_sequence_button) return true;
  if (_buzzer_sequence == _buzzer_sequence_button_long) return true;
  if (_buzzer_sequence == _buzzer_sequence_button_ultra_long) return true;
  
  return false;
}