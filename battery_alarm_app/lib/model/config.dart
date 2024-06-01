class DeviceConfig {
  DeviceConfig({
    this.delayWarn,
    this.delayAlarm,
    this.snoozeTime,
    this.vbatLpF,
    this.vbatChargeThreshold,
    this.vbatAlternatorThreshold,
    this.vbatDeltaThreshold,
    this.vbatTuneFactor,
    this.btBeaconAddress,
    this.btRssiThreshold,
    this.btRssiAutoTune,
    this.buzzerAlerts,
  });

  DeviceConfig clone() => DeviceConfig(
        delayWarn: delayWarn,
        delayAlarm: delayWarn,
        snoozeTime: snoozeTime,
        vbatLpF: vbatLpF,
        vbatChargeThreshold: vbatChargeThreshold,
        vbatAlternatorThreshold: vbatAlternatorThreshold,
        vbatDeltaThreshold: vbatDeltaThreshold,
        vbatTuneFactor: vbatTuneFactor,
        btBeaconAddress: btBeaconAddress,
        btRssiThreshold: btRssiThreshold,
        btRssiAutoTune: btRssiAutoTune,
        buzzerAlerts: buzzerAlerts == null ? null : Map.from(buzzerAlerts!),
      );

  Duration? delayWarn;
  Duration? delayAlarm;
  Duration? snoozeTime;

  double? vbatLpF;
  double? vbatChargeThreshold;
  double? vbatAlternatorThreshold;
  double? vbatDeltaThreshold;
  double? vbatTuneFactor;

  String? btBeaconAddress;
  double? btRssiThreshold;
  bool? btRssiAutoTune;

  Map<BuzzerAlerts, bool>? buzzerAlerts;
}

enum BuzzerAlerts {
  garage(0),
  charging(1),
  hello(2),
  button(3),
  bluetooth(4);

  const BuzzerAlerts(this.value);

  final int value;

  static Map<BuzzerAlerts, bool>? parse(int? value) {
    if (value == null) return null;
    final result = <BuzzerAlerts, bool>{};
    for (var p in BuzzerAlerts.values) {
      result[p] = (value & (1 << p.value)) != 0;
    }
    return result;
  }

  static int? format(Map<BuzzerAlerts, bool>? values) {
    if (values == null) return null;
    int result = 0;
    values.forEach((k, v) => result |= (v ? (1 << k.value) : 0));
    return result;
  }
}
