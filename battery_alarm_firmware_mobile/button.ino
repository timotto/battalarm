#include "pins.h"
#include "config.h"

bool _button_pressed = false;
int _button_pressedCount = 0;
bool _button_released = false;
int _button_releasedCount = 0;
bool _button_pressedLong = false;
int _button_pressedLongCount = 0;
bool _button_pressedUltraLong = false;
int _button_pressedUltraLongCount = 0;

void button_read(int *pressed, int *released, int *longPressed, int *ultraLongPressed) {
  *pressed = _button_pressedCount;
  *released = _button_releasedCount;
  *longPressed = _button_pressedLongCount;
  *ultraLongPressed = _button_pressedUltraLongCount;
  _button_pressedCount = 0;
  _button_releasedCount = 0;
  _button_pressedLongCount = 0;
  _button_pressedUltraLongCount = 0;
}

void setup_button() {
  pinMode(PIN_BUTTON, INPUT_PULLUP);
}

void loop_button(const uint32_t now) {
  static bool was_pressed = false;
  static uint32_t pressed_since = 0;
  const bool pressed = digitalRead(PIN_BUTTON) == LOW;

  if (pressed) {
    if (!was_pressed) {
      was_pressed = true;
      pressed_since = now;
    }

    const uint32_t dt = now - pressed_since;
    if (dt > BUTTON_DEBOUNCE && !_button_pressed) {
      _button_pressed = true;
      _button_pressedCount++;
    }
    if (dt > BUTTON_LONG && !_button_pressedLong) {
      _button_pressedLong = true;
      _button_pressedLongCount++;
    }
    if (dt > BUTTON_ULTRA_LONG && !_button_pressedUltraLong) {
      _button_pressedUltraLong = true;
      _button_pressedUltraLongCount++;
    }
  } else {
    if (was_pressed) {
      was_pressed = false;
      _button_released = true;
      _button_releasedCount++;
    }
    _button_pressed = false;
    _button_pressedLong = false;
    _button_pressedUltraLong = false;
  }
}

