#include <Preferences.h>

bool _pref_save = false;
uint32_t _pref_saveSince = 0;

void pref_save() {
  _pref_save = true;
  _pref_saveSince = millis();
}

Preferences preferences;

const char* _pref_namespace = "batlrm";

const char* _pref_key_delay_warn = "delwrn";
const char* _pref_key_delay_alarm = "delalarm";
const char* _pref_key_snooze_time = "snztm";
const char* _pref_key_vbat_tune_f = "vbtnf";
const char* _pref_key_vbat_lp_f = "vblpf";
const char* _pref_key_bt_beacon_addr = "btbcadr";
const char* _pref_key_bt_beacon_rssi_in_garage = "btrsing";
const char* _pref_key_vbat_charge_voltage = "vbchv";
const char* _pref_key_vbat_charge_delta_threshold = "vbchdt";
const char* _pref_key_buzzer_alerts = "bzalrt";

void setup_pref() {
  if(!preferences.begin(_pref_namespace, true)) {
    if(!preferences.begin(_pref_namespace)) {
      Serial.println("prefs: error: begin failed");
      return;
    }
  }

  configDelayWarn = preferences.getUInt(_pref_key_delay_warn, configDelayWarn);
  configDelayAlarm = preferences.getUInt(_pref_key_delay_alarm, configDelayAlarm);
  configSnoozeTime = preferences.getUInt(_pref_key_snooze_time, configSnoozeTime);
  configVbatTuneF = preferences.getFloat(_pref_key_vbat_tune_f, 1.0);
  configVbatLpF = preferences.getFloat(_pref_key_vbat_lp_f, configVbatLpF);
  configBtBeaconAddr = preferences.getString(_pref_key_bt_beacon_addr, "");
  configBtBeaconRssiInGarage = preferences.getFloat(_pref_key_bt_beacon_rssi_in_garage, 0);
  configVbatChargeVoltage = preferences.getFloat(_pref_key_vbat_charge_voltage, configVbatChargeVoltage);
  configVbatChargeDeltaThreshold = preferences.getFloat(_pref_key_vbat_charge_delta_threshold, configVbatChargeDeltaThreshold);
  configBuzzerAlerts = preferences.getUInt(_pref_key_buzzer_alerts, configBuzzerAlerts);
  
  preferences.end();
}

void loop_pref(const uint32_t now) {
  if (!_pref_save) return;
  const uint32_t dt = now - _pref_saveSince;
  if (dt < 1000) return;
  _pref_save = false;

  preferences.begin(_pref_namespace, false);

  preferences.putUInt(_pref_key_delay_warn, configDelayWarn);
  preferences.putUInt(_pref_key_delay_alarm, configDelayAlarm);
  preferences.putUInt(_pref_key_snooze_time, configSnoozeTime);
  preferences.putFloat(_pref_key_vbat_tune_f, configVbatTuneF);
  preferences.putFloat(_pref_key_vbat_lp_f, configVbatLpF);
  preferences.putString(_pref_key_bt_beacon_addr, configBtBeaconAddr);
  preferences.putFloat(_pref_key_bt_beacon_rssi_in_garage, configBtBeaconRssiInGarage);
  preferences.putFloat(_pref_key_vbat_charge_voltage, configVbatChargeVoltage);
  preferences.putFloat(_pref_key_vbat_charge_delta_threshold, configVbatChargeDeltaThreshold);
  preferences.putUInt(_pref_key_buzzer_alerts, configBuzzerAlerts);

  preferences.end();
}
