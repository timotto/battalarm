#include <FastLED.h>
#include "pins.h"

#define LED_SEQUENCE_END  0xffffffff

// _led_sequence_*
// even value is the RGB color, odd value is the duration in milliseconds to fade into that color
// must terminate with a RGB color value "0xffffffff" and a duration
// the sequence repeats unless the terminating duration value is 0.
const uint32_t _led_sequence_off[] = {0x0, 500, LED_SEQUENCE_END, 0};
const uint32_t _led_sequence_hello[] = {0x7f0000, 200, 0x007f00, 200, 0x00007f, 200, 0x0, 200, LED_SEQUENCE_END, 0};
const uint32_t _led_sequence_charge[] = {0x007f00, 3000, 0x007f00, 1000, 0x000f00, 500, LED_SEQUENCE_END, 1};
const uint32_t _led_sequence_warn[] = {0x7f3f00, 500, 0x0f0a00, 2000, LED_SEQUENCE_END, 1};
const uint32_t _led_sequence_alarm[] = {0xff0000, 200, 0x0f0000, 1800, LED_SEQUENCE_END, 1};
const uint32_t _led_sequence_snooze[] = {0x7f7f00, 2000, 0x000000, 3000, LED_SEQUENCE_END, 1};
const uint32_t _led_sequence_button[] = {0x3f3f3f, 25, 0x3f3f3f, 25, 0, 5, LED_SEQUENCE_END, 0};
const uint32_t _led_sequence_button_long[] = {0x3f3f3f, 100, 0x3f3f3f, 100, 0, 5, LED_SEQUENCE_END, 0};
const uint32_t *_led_sequence = NULL;

#define __led_setMode(x) _led_setMode((const uint32_t*)x)

void led_off() {
  __led_setMode(_led_sequence_off);
}

void led_hello() {
  __led_setMode(_led_sequence_hello);
}

void led_charging() {
  __led_setMode(_led_sequence_charge);
}

void led_warn() {
  __led_setMode(_led_sequence_warn);
}

void led_alarm() {
  __led_setMode(_led_sequence_alarm);
}

void led_snooze() {
  __led_setMode(_led_sequence_snooze);
}

void led_button() {
  if (_led_sequence == NULL || _led_sequence == _led_sequence_off) {
  __led_setMode(_led_sequence_button);
  }
}

void led_buttonLong() {
  if (_led_sequence == NULL || _led_sequence == _led_sequence_off) {
  __led_setMode(_led_sequence_button_long);
  }
}

CRGB leds[LED_COUNT];

int _led_step = 0;
uint32_t _led_stepStart = 0;
uint32_t _led_rgbCurrent = 0;
uint32_t _led_rgbFrom = 0;

void setup_led() {
  FastLED.addLeds<NEOPIXEL, PIN_LED>(leds, LED_COUNT);
}

void loop_led(const uint32_t now) {
  static uint32_t last_now = 0;
  if (now - last_now < 20) return;
  last_now = now;

  if (_led_sequence == NULL) return;

  const uint32_t rgb = _led_sequence[_led_step];
  const uint32_t period = _led_sequence[_led_step+1];
  const uint32_t stepDt = now - _led_stepStart;
  const bool stepDone = stepDt >= period;

  const float p = stepDone ? 1 : (float)stepDt / (float)period;

  _led_rgbCurrent = _led_fadeRgb(_led_rgbFrom, rgb, p);

  _led_set();

  if (!stepDone) return;

  _led_step += 2;
  _led_stepStart = millis();
  _led_rgbFrom = _led_rgbCurrent;

  if (_led_sequence[_led_step] != LED_SEQUENCE_END) return;

  if (_led_sequence[_led_step+1] == 0) {
    if (_led_sequence == _led_sequence_off) {
      _led_sequence = NULL;
    } else {
      led_off();
    }
  } else {
    _led_step = 0;
  }
}

void _led_set() {
  for(auto i = 0; i < LED_COUNT; i++) {
    leds[i] = _led_rgbCurrent;
  }
  FastLED.show();
}

void _led_setMode(const uint32_t *sequence) {
  if (_led_sequence == sequence) return;

  _led_step = 0;
  _led_stepStart = millis();
  _led_rgbFrom = _led_rgbCurrent;
  _led_sequence = sequence;
}

// fades the color "src" into "dst" by "p"
// when "p" is 0, then the result is completely "src"
// when "p" is 1, then the result is completely "dst"
// when "p" is > 0 < 1 the result is the mix
uint32_t _led_fadeRgb(uint32_t src, uint32_t dst, float p) {
  if (p <= 0) return src;
  if (p >= 1) return dst;

  uint8_t srcR, srcG, srcB;
  uint8_t dstR, dstG, dstB;

  _led_splitRgb(src, &srcR, &srcG, &srcB);
  _led_splitRgb(dst, &dstR, &dstG, &dstB);

  float np = 1 - p;
  float r = np * (float)srcR + p * (float)dstR;
  float g = np * (float)srcG + p * (float)dstG;
  float b = np * (float)srcB + p * (float)dstB;

  return _led_mixRgb((uint8_t)r, (uint8_t)g, (uint8_t)b);
}

void _led_splitRgb(uint32_t rgb, uint8_t* r, uint8_t *g, uint8_t *b) {
  *r = (rgb >> 16) & 0xff;
  *g = (rgb >> 8) & 0xff;
  *b = rgb & 0xff;
}

uint32_t _led_mixRgb(uint8_t r, uint8_t g, uint8_t b) {
  return (r << 16) | (g << 8) | b;
}
