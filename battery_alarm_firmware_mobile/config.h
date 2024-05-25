#pragma once

#define VERSION "1.0.0"

#define BUZZER_ALERT_GARAGE 1
#define BUZZER_ALERT_CHARGING 2
#define BUZZER_ALERT_HELLO 4
#define BUZZER_ALERT_BUTTON 8
#define BUZZER_ALERT_BT 16
#define BUZZER_ALERTS_MAX (BUZZER_ALERT_GARAGE | BUZZER_ALERT_CHARGING | BUZZER_ALERT_HELLO | BUZZER_ALERT_BUTTON | BUZZER_ALERT_BT)

// voltage divider: r1=100k r2=10k => 30V=>2.727V
// analog read of 3.3V => 4095
// analogRead => 1V = 1/1240.909090909090909
// 2.72V => 30V = 11.029411764705882
// 1/1240.909090909090909 * 11.029411764705882
#define VBAT_F 0.008888170652877

#define VBAT_DELTA_INTERVAL   100
#define VBAT_DELTA_RESET      60000

uint32_t configDelayWarn = 30000;
uint32_t configDelayAlarm = 60000;
uint32_t configSnoozeTime = 30000;
float configVbatTuneF = 1.0;
float configVbatLpF = 0.90;
String configBtBeaconAddr = "";
float configBtBeaconRssiInGarage = 0;
bool configBtBeaconRssiAutoTune = true;
float configVbatChargeVoltage = 26;
float configVbatAlternatorVoltage = 27;
float configVbatChargeDeltaThreshold = 0.1;
uint32_t configBuzzerAlerts = BUZZER_ALERTS_MAX;

#define BT_SCAN_INTERVAL  10000
#define BT_SCAN_DURATION  5000
#define BT_VISIBILITY_TIMEOUT 300000

#define BUTTON_DEBOUNCE 20
#define BUTTON_LONG 2000
#define BUTTON_ULTRA_LONG 5000

#define CONFIG_DELAY_WARN_MIN   1000
#define CONFIG_DELAY_WARN_MAX   3600000
#define CONFIG_DELAY_ALERT_MIN   1000
#define CONFIG_DELAY_ALERT_MAX   3600000
#define CONFIG_DELAY_SNOOZE_MIN   1000
#define CONFIG_DELAY_SNOOZE_MAX   3600000
#define CONFIG_RSSI_T_MIN -85
#define CONFIG_RSSI_T_MAX 0
#define CONFIG_VBAT_LPF_MIN 0.5
#define CONFIG_VBAT_LPF_MAX 0.9999
#define CONFIG_VBAT_TUNE_F_MIN 0.1
#define CONFIG_VBAT_TUNE_F_MAX 1.9
#define CONFIG_VBAT_DELTA_T_MIN 0.001
#define CONFIG_VBAT_DELTA_T_MAX 1
#define CONFIG_VBAT_CHARGE_T_MIN 12
#define CONFIG_VBAT_CHARGE_T_MAX 30
#define CONFIG_VBAT_ALTERNATOR_T_MIN 12
#define CONFIG_VBAT_ALTERNATOR_T_MAX 30
