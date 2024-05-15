void setup() {
  setup_console();
  setup_pref();
  setup_vbat();
  setup_buzzer();
  setup_button();
  setup_led();
  setup_bt();
  setup_app();
}

void loop() {
  const uint32_t now = millis();
  loop_console(now);
  loop_pref(now);
  loop_vbat(now);
  loop_buzzer(now);
  loop_button(now);
  loop_led(now);
  loop_bt(now);
  loop_app(now);
}
