#pragma once

#ifdef ARDUINO_XIAO_ESP32C3
// #define PIN_VBAT    10
#define PIN_VBAT    A0
#define PIN_BUZZER  9
#define PIN_BUTTON  8
#define PIN_LED     7
#elif ARDUINO_ESP32_DEV
#define PIN_VBAT    25
#define PIN_BUZZER  13
#define PIN_BUTTON  12
#define PIN_LED     27
#else
#error "Unknown Arduino board, please configure pins.h"
#endif

#define LED_COUNT   1
