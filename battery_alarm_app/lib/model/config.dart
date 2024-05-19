class DeviceConfig {
  DeviceConfig({
    this.delayWarn,
    this.delayAlarm,
    this.snoozeTime,
    this.vbatLpF,
    this.vbatChargeThreshold,
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
  double? vbatDeltaThreshold;
  double? vbatTuneFactor;

  String? btBeaconAddress;
  double? btRssiThreshold;
  bool? btRssiAutoTune;

  Map<BuzzerAlerts, bool>? buzzerAlerts;
}

enum BuzzerAlerts {
  garage,
  charging,
  hello,
  button,
  bluetooth,
}
