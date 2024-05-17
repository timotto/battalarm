class DeviceStatus {
  final bool? inGarage;
  final bool? charging;
  final double? vbat;
  final double? vbatDelta;
  final double? rssi;

  DeviceStatus({this.inGarage, this.charging, this.vbat, this.vbatDelta, this.rssi});
}
