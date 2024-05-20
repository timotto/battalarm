import 'package:battery_alarm_app/util/beacon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class ScanResultListTile extends StatelessWidget {
  const ScanResultListTile({
    super.key,
    required this.device,
    this.onTap,
    this.isCurrent,
    this.showRssi,
  });

  final DiscoveredDevice device;
  final void Function(DiscoveredDevice)? onTap;
  final bool? isCurrent;
  final bool? showRssi;

  String _title() =>
      device.name.isNotEmpty ? device.name : formatBeaconAddress(device.id);

  Widget? _subtitle() =>
      device.name.isNotEmpty ? Text(formatBeaconAddress(device.id)) : null;

  Widget? _trailing() =>
      (showRssi ?? false) ? Text(device.rssi.toString()) : null;

  void Function()? _onTap() {
    if (onTap == null) return null;
    return () => onTap!(device);
  }

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(_title()),
        subtitle: _subtitle(),
        leading: Icon(_rssiToIconData(device.rssi)),
        trailing: _trailing(),
        onTap: _onTap(),
        selected: isCurrent ?? false,
      );
}

IconData _rssiToIconData(int rssi) {
  if (rssi >= -60) {
    return Icons.wifi;
  }
  if (rssi >= -80) {
    return Icons.wifi_2_bar;
  }
  return Icons.wifi_1_bar;
}
