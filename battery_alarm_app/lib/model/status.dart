class DeviceStatus {
  DeviceStatus({
    this.inGarage,
    this.charging,
    this.engineRunning,
    this.vbat,
    this.vbatDelta,
    this.rssi,
  });

  DeviceStatus clone() => DeviceStatus(
    inGarage: inGarage,
    charging: charging,
    engineRunning: engineRunning,
    vbat: vbat,
    vbatDelta: vbatDelta,
    rssi: rssi,
  );

  bool? inGarage;
  bool? charging;
  bool? engineRunning;
  double? vbat;
  double? vbatDelta;
  double? rssi;
}
