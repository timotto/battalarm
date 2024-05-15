#pragma once

#define VERSION "1.0.0"

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
float configBtBeaconRssiNearGarage = 0;
float configVbatChargeVoltage = 26;
float configVbatChargeDeltaThreshold = 0.1;

#define BT_SCAN_INTERVAL  10000
#define BT_SCAN_DURATION  5000
