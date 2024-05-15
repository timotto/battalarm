#include "pins.h"

bool _button_pressed = false;
bool _button_pressedLong = false;
int _button_pressedCount = 0;
int _button_pressedLongCount = 0;

void button_read(int *pressed, int *longPressed) {
  *pressed = _button_pressedCount;
  *longPressed = _button_pressedLongCount;
  _button_pressedCount = 0;
  _button_pressedLongCount = 0;
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
    if (dt > 20 && !_button_pressed) {
      _button_pressed = true;
      _button_pressedCount++;
    }
    if (dt > 1000 && !_button_pressedLong) {
      _button_pressedLong = true;
      _button_pressedLongCount++;
    }
  } else {
    if (was_pressed) {
      was_pressed = false;
    }
    _button_pressed = false;
    _button_pressedLong = false;
  }
}

