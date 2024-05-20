import 'package:battery_alarm_app/bt/scanner.dart';
import 'package:battery_alarm_app/widgets/scan_result_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class ScanResultWidget extends StatelessWidget {
  const ScanResultWidget({
    super.key,
    required this.state,
    required this.onSelect,
    this.onEmpty,
    this.showRssi,
    this.currentDeviceId,
    this.filter,
  });

  final BleScannerState? state;
  final void Function(DiscoveredDevice) onSelect;
  final Widget? onEmpty;
  final bool? showRssi;
  final String? currentDeviceId;
  final bool Function(DiscoveredDevice)? filter;

  bool _isCurrent(DiscoveredDevice device) {
    if (currentDeviceId == null) return false;
    return currentDeviceId == device.id;
  }

  Iterable<DiscoveredDevice> _filtered(Iterable<DiscoveredDevice> devices) {
    if (filter == null) return devices;

    return devices.where(filter!);
  }

  @override
  Widget build(BuildContext context) {
    final result =
        _filtered(state?.discoveredDevices ?? []).toList(growable: false);

    if (result.isEmpty && onEmpty != null) return onEmpty!;

    result.sort(_scanResultSorter);

    return ListView(
        children: result
            .map((device) => ScanResultListTile(
                  device: device,
                  isCurrent: _isCurrent(device),
                  showRssi: showRssi ?? false,
                  onTap: (device) => onSelect(device),
                ))
            .toList(growable: false));
  }
}

int _scanResultSorter(DiscoveredDevice a, DiscoveredDevice b) {
  if (a.name.isNotEmpty && b.name.isEmpty) return -1;
  if (b.name.isNotEmpty && a.name.isEmpty) return 1;

  final result = a.name.compareTo(b.name);
  if (result != 0) return result;

  return a.id.compareTo(b.id);
}
