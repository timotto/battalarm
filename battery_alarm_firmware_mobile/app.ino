#include "config.h"

bool _app_startupComplete = false;
bool _app_inGarage = false;
uint32_t _app_inGarageChangeTime = 0;
bool _app_charging = false;
uint32_t _app_chargingChangeTime = 0;
bool _app_engineRunning = false;
uint32_t _app_engineRunningChangeTime = 0;
bool _app_snoozed = false;
uint32_t _app_snoozedChangeTime = 0;
bool _app_buttonPressed = false;
bool _app_buttonReleased = false;
bool _app_buttonPressedLong = false;
bool _app_buttonPressedUltraLong = false;

bool _app_wasInGarage = false;
bool _app_wasCharging = false;
bool _app_wasEngineRunning = false;
bool _app_wasNotInGarage = true;

void app_status() {
  Serial.printf(
    "App status:\n"
    "  In garage: %s\n"
    "  In garage changed since: %lu\n"
    "  Charging: %s\n"
    "  Charging changed since: %lu\n"
    "  Engine running: %s\n"
    "  Engine running changed since: %lu\n"
    ,
    _app_inGarage ? "true" : "false",
    millis() - _app_inGarageChangeTime,
    _app_charging ? "true" : "false",
    millis() - _app_chargingChangeTime,
    _app_engineRunning ? "true" : "false",
    millis() - _app_engineRunningChangeTime
    );
}

void setup_app() {

}

void loop_app(const uint32_t now) {
  if (!_app_startupComplete) {
    _app_startupComplete = true;
    console_hello();
    led_hello();
    buzzer_setHello();
  }

  _app_readValues(now);
  if (_app_buttonPressed) {
    buzzer_setButton();
    led_button();
  }
  if (_app_buttonPressedLong) {
    buzzer_setButtonLong();
    led_buttonLong();
  }
  if (_app_buttonPressedUltraLong) {
    buzzer_setButtonUltraLong();
    led_buttonUltraLong();
  }

  if (_app_inGarage) {
    _app_loop_inGarage(now);
  } else {
    _app_loop_notInGarage(now);
  }

  _app_loop_bt(now);
}

void _app_loop_inGarage(const uint32_t now) {
  static bool was_warn = false;
  static bool was_alarm = false;
  if (!_app_wasInGarage) {
    Serial.println("app: state change: in garage");
    _app_wasInGarage = true;
    was_warn = false;
    was_alarm = false;
    buzzer_setGarage();
  }

  _app_wasNotInGarage = false;

  if (_app_charging) {
    if (!_app_wasCharging) {
      Serial.println("app: state change: charging");
      _app_wasCharging = true;
      was_warn = false;
      was_alarm = false;
      buzzer_setCharging();
      led_charging();
    }
    return;
  }

  if (_app_wasCharging) {
    Serial.println("app: state change: not charging");
    _app_wasCharging = false;
    led_off();
  }

  if (_app_engineRunning) {
    if (!_app_wasEngineRunning) {
      Serial.println("app: state change: engine running");
      _app_wasEngineRunning = true;
      was_warn = false;
      was_alarm = false;
      buzzer_setOff();
      led_off();
    }
    return;
  }

  if (_app_wasEngineRunning) {
    Serial.println("app: state change: engine not running");
    _app_wasEngineRunning = false;
  }

  if (_app_isSnooze(now)) {
    if (was_warn || was_alarm) {
      was_warn = false;
      was_alarm = false;
    }
    return;
  }

  uint32_t eventDt = 0xffffffff;
  _app_bestDt(now, _app_inGarageChangeTime, &eventDt);
  _app_bestDt(now, _app_chargingChangeTime, &eventDt);
  _app_bestDt(now, _app_engineRunningChangeTime, &eventDt);

  if (eventDt >= configDelayWarn && !was_warn) {
    Serial.println("app: state change: warn");
    was_warn = true;
    buzzer_setWarn();
    led_warn();
  }

  if (eventDt >= (configDelayWarn + configDelayAlarm) && !was_alarm) {
    Serial.println("app: state change: alarm");
    was_alarm = true;
    buzzer_setAlarm();
    led_alarm();
  }

  if ((was_warn || was_alarm) && _app_buttonPressedLong) {
    Serial.println("app: state change: snooze");
    _app_setSnooze(now);
    buzzer_setSnooze();
    led_snooze();

    // "consume" button press, to hide from other logic
    _app_buttonPressedLong = false;
  }
}

void _app_loop_notInGarage(const uint32_t now) {
  if (!_app_wasNotInGarage) {
    Serial.println("app: state change: not in garage");
    _app_wasNotInGarage = true;
    buzzer_setGarageLeft();
    led_off();
  }

  _app_wasInGarage = false;
  _app_wasCharging = false;

  if (_app_charging) {
    _app_chargingButNotInGarage(now);
  }
}

void _app_loop_bt(const uint32_t now) {
  static bool longPress = false;
  static bool ultraLongPress = false;
  static bool btVisible = false;
  static bool btAuth = false;

  if (_app_buttonPressedLong) longPress = true;
  if (_app_buttonPressedUltraLong) ultraLongPress = true;

  if (_app_buttonReleased) {
    if (ultraLongPress) {
      btVisible = bt_toggleVisibility();
      buzzer_setBtVisible(btVisible);
      led_setBtVisible(btVisible);
    }

    longPress = false;
    ultraLongPress = false;
  }

  if (btVisible && !bt_isVisible()) {
    btVisible = false;
    buzzer_setBtVisible(btAuth);
    led_setBtVisible(btAuth);
  }
}

void _app_readValues(const uint32_t now) {
  bool value;

  value = bt_isInGarage();
  if (value != _app_inGarage) {
    _app_inGarage = value;
    _app_inGarageChangeTime = now;
  }

  value = vbat_isCharging();
  if (value != _app_charging) {
    _app_charging = value;
    _app_chargingChangeTime = now;
  }

  value = vbat_isEngineRunning();
  if (value != _app_engineRunning) {
    _app_engineRunning = value;
    _app_engineRunningChangeTime = now;
  }

  int pressed, released, pressedLong, pressedUltraLong;
  button_read(&pressed, &released, &pressedLong, &pressedUltraLong);
  _app_buttonPressed = pressed > 0;
  _app_buttonReleased = released > 0;
  _app_buttonPressedLong = pressedLong > 0;
  _app_buttonPressedUltraLong = pressedUltraLong > 0;
}

void _app_setSnooze(const uint32_t now) {
  _app_snoozed = true;
  _app_snoozedChangeTime = now;
}

bool _app_isSnooze(const uint32_t now) {
  if (!_app_snoozed) return false;
  if ((now - _app_snoozedChangeTime) < configSnoozeTime) return true;

  // snooze expired
  _app_snoozed = false;
  _app_snoozedChangeTime = now;
  return false;
}

void _app_bestDt(const uint32_t now, const uint32_t event, uint32_t *result) {
  const uint32_t dt = now - event;
  if (dt < *result) *result = dt;
}

void _app_chargingButNotInGarage(const uint32_t now) {
  bt_maybeReduceRssi(now);
}
