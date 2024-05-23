#pragma once

#ifdef ARDUINO_XIAO_ESP32C3
// #define PIN_VBAT    10
#define PIN_VBAT    A1
#define PIN_BUTTON  6 // D4 / GPIO06
#define PIN_LED     7 // D5 / GPIO07
#define PIN_BUZZER  21 // D6 / GPIO21
#elif ARDUINO_ESP32_DEV
#define PIN_VBAT    25
#define PIN_BUZZER  13
#define PIN_BUTTON  12
#define PIN_LED     27
#else
#error "Unknown Arduino board, please configure pins.h"
#endif

#define LED_COUNT   1

#define BUTTON_INPUT INPUT_PULLDOWN
#define BUTTON_ACTIVE HIGH
