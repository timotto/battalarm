class DeviceStatus {
  DeviceStatus({
    this.inGarage,
    this.charging,
    this.vbat,
    this.vbatDelta,
    this.rssi,
  });

  DeviceStatus clone() => DeviceStatus(
    inGarage: inGarage,
    charging: charging,
    vbat: vbat,
    vbatDelta: vbatDelta,
    rssi: rssi,
  );

  bool? inGarage;
  bool? charging;
  double? vbat;
  double? vbatDelta;
  double? rssi;
}
