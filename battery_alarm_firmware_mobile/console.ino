#include "config.h"

String _console_buffer = "";

void console_hello() {
  Serial.printf("Battery Alarm Version %s\n\n", VERSION);
  _console_printConfig();
  _console_prompt();
}

void setup_console() {
  Serial.begin(115200);
}

void loop_console(const uint32_t now) {
  while (Serial.available()) {
    char c = Serial.read();
    switch (c) {
      case '\r':
      case '\n':
        _console_processBuffer();
        _console_prompt();
        break;
    }
    if ((c >= 0x20) && c <= 0x7e) {
      _console_buffer += c;
    }
  }
}

void _console_processBuffer() {
  bool echo = true;
  String buffer = _console_buffer;
  _console_buffer = "";

  if (buffer.equals("bt scan")) {
    bt_scan();
  } else if (buffer.equals("config")) {
    Serial.println();
    _console_printConfig();
    echo = false;
  } else if (buffer.equals("status")) {
    Serial.println();
    app_status();
    bt_status();
    vbat_status();
    echo = false;
  } else if (buffer.startsWith("config set ")) {
    echo = _console_processConfig(buffer.substring(11));
  } else if (buffer.startsWith("debug ")) {
    echo = _console_processDebug(buffer.substring(6));
  } else if (buffer.startsWith("fake ")) {
    echo = _console_processFake(buffer);
  } else if (buffer.equals("off")) {
    buzzer_setOff();
    led_off();
  } else if (buffer.equals("hello")) {
    buzzer_setHello();
    led_hello();
  } else if (buffer.equals("charging")) {
    buzzer_setCharging();
    led_charging();
  } else if (buffer.equals("garage")) {
    buzzer_setGarage();
  } else if (buffer.equals("button")) {
    buzzer_setButton();
  } else if (buffer.equals("warn")) {
    buzzer_setWarn();
    led_warn();
  } else if (buffer.equals("alarm")) {
    buzzer_setAlarm();
    led_alarm();
  } else if (buffer.equals("vbat")) {
    Serial.printf("vbat: %.2fV\n", vbat_volt());
    echo = false;
  } else {
    Serial.printf("unknown command: %s\n", buffer.c_str());
    return;
  }

  if (echo) Serial.println(buffer.c_str());
}

void _console_prompt() {
  Serial.print("READY> ");
}

void _console_printConfig() {
  Serial.printf(
    "Config:\n"
    "  Delay:\n"
    "    Warn: %lu\n"
    "    Alarm: %lu\n"
    "    Snooze: %lu\n"
    "  BT Beacon:\n"
    "    Address: %s\n"
    "    RSSI in: %.1f\n"
    "    RSSI Auto-tune: %s\n"
    "  Battery:\n"
    "    Charge voltage: %.1f\n"
    "    Tune factor: %.1f\n"
    "    LP factor: %.1f\n"
    "\n",
    configDelayWarn, configDelayAlarm, configSnoozeTime,
    configBtBeaconAddr.c_str(), configBtBeaconRssiInGarage, configBtBeaconRssiAutoTune ? "true" : "false",
    configVbatChargeVoltage, configVbatTuneF, configVbatLpF);
}

bool _console_processConfig(String pair) {
  int index = pair.indexOf("=");
  if (index == -1) {
    Serial.println("SYNTAX ERROR");
    return false;
  }
  String key = pair.substring(0, index);
  String value = pair.substring(index + 1);

  if (key.equals("beacon")) {
    bt_setBeacon(value);
  } else if (key.equals("vbat_charge_v")) {
    float val = value.toFloat();
    if (!_console_ensureValue(val, 12, 30)) return false;
    configVbatChargeVoltage = val;
  } else if (key.equals("vbat_charge_delta")) {
    float val = value.toFloat();
    if (!_console_ensureValue(val, 0.001, 1)) return false;
    configVbatChargeDeltaThreshold = val;
  } else if (key.equals("vbat_tune_f")) {
    float val = value.toFloat();
    if (!_console_ensureValue(val, 0.1, 1.9)) return false;
    configVbatTuneF = val;
  } else if (key.equals("vbat_lp_f")) {
    float val = value.toFloat();
    if (!_console_ensureValue(val, 0.5, 0.9999)) return false;
    configVbatLpF = val;
  } else if (key.equals("rssi_garage")) {
    int val = value.toInt();
    if (!_console_ensureValue(val, -80, 0)) return false;
    configBtBeaconRssiInGarage = val;
  } else if (key.equals("rssi_autotune")) {
    int val = -1;
    if (value.equals("on") || value.equals("true")) {
      val = 1;
    } else if (value.equals("off") || value.equals("false")) {
      val = 0;
    } else {
      val = value.toInt();
    }
    if (!_console_ensureValue(val, 0, 1)) return false;
    configBtBeaconRssiAutoTune = val == 1;
  } else if (key.equals("delay_warn")) {
    uint32_t val = value.toInt();
    if (!_console_ensureValue(val, 1000, 3600000)) return false;
    configDelayWarn = val;
  } else if (key.equals("delay_alarm")) {
    uint32_t val = value.toInt();
    if (!_console_ensureValue(val, 1000, 3600000)) return false;
    configDelayAlarm = val;
  } else if (key.equals("delay_snooze")) {
    uint32_t val = value.toInt();
    if (!_console_ensureValue(val, 1000, 300000)) return false;
    configSnoozeTime = val;
  } else {
    Serial.println("UNKNOWN CONFIG");
    return false;
  }

  pref_save();
  return true;
}

bool _console_processDebug(String value) {
  String key = "";
  String opt = "";
  int index = value.indexOf(" ");
  if (index != -1) {
    key = value.substring(0, index);
    opt = value.substring(index+1);
  } else {
    key = value;
  }

  if (key.equals("bt")) {
    if (opt.equals("on")) {
      bt_debugOn();
    } else if (opt.equals("off")) {
      bt_debugOff();
    } else {
      Serial.println("SYNTAX ERROR");
      return false;
    }
  } else if (key.equals("vbat")) {
    if (opt.equals("on")) {
      vbat_debug();
    } else if (opt.equals("off")) {
      vbat_debugOff();
    } else {
      Serial.println("SYNTAX ERROR");
      return false;
    }
  } else {
    Serial.printf("UNKNOWN KEY: %s\n", key.c_str());
    return false;
  }

  return true;
}

bool _console_processFake(String buffer) {
  if (buffer.equals("fake in garage true")) {
    bt_fake_isInGarage(true);
  } else if (buffer.equals("fake in garage false")) {
    bt_fake_isInGarage(false);
  } else if (buffer.equals("fake in garage off")) {
    bt_fake_isInGarageOff();
  } else if (buffer.equals("fake charging true")) {
    vbat_fake_charging(true);
  } else if (buffer.equals("fake charging false")) {
    vbat_fake_charging(false);
  } else if (buffer.equals("fake charging off")) {
    vbat_fake_chargingOff();
  } else {
    Serial.println("UNKNOWN COMMAND");
    return false;
  }

  return true;
}

bool _console_ensureValue(float val, float min, float max) {
  if (val < min) {
    Serial.println("VALUE TOO SMALL");
    return false;
  } else if (val > max) {
    Serial.println("VALUE TOO LARGE");
    return false;
  }

  return true;
}
