import 'package:battery_alarm_app/bt/scanner.dart';
import 'package:battery_alarm_app/model/bt_uuid.dart';
import 'package:battery_alarm_app/text.dart';
import 'package:battery_alarm_app/widgets/scan_result_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BeaconScanWidget extends StatefulWidget {
  const BeaconScanWidget({
    super.key,
    required this.currentBeaconId,
  });

  final String? currentBeaconId;

  @override
  State<StatefulWidget> createState() => _BeaconScanWidgetState();
}

class _BeaconScanWidgetState extends State<BeaconScanWidget> {
  final _scanner = BleScanner();

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    super.dispose();
    _stopScan();
  }

  void _startScan() {
    _scanner.startScan([]);
  }

  void _stopScan() {
    _scanner.stopScan();
  }

  void _onCancel(context) {
    Navigator.pop(context);
  }

  void _onSelect(BuildContext context, DiscoveredDevice device) async {
    final String name =
        device.name.isNotEmpty ? '${device.name} ${device.id}' : device.id;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Basisstation wechseln'),
        content: Text('Möchtest du $name als Basisstation verwenden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ja'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Nein'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (!(confirm ?? false)) return;

    Navigator.pop(context, device.id.toLowerCase());
  }

  Widget _scanResultList(BuildContext context,
      AsyncSnapshot<BleScannerState> scannerStateSnapshot) {
    final result = scannerStateSnapshot.data?.discoveredDevices ?? [];

    result.sort(_scanResultSorter);

    return ListView(
        children: result
            .where((device) => _notABattalarmDevice(device))
            .map((device) => ScanResultListTile(
                  device: device,
                  isCurrent: _isCurrent(device),
                  showRssi: true,
                  onTap: (device) => _onSelect(context, device),
                ))
            .toList(growable: false));
  }

  bool _isCurrent(DiscoveredDevice device) {
    return device.id.toLowerCase() == widget.currentBeaconId;
  }

  Widget _fab(BuildContext context,
      AsyncSnapshot<BleScannerState> scannerStateSnapshot) {
    final scanning = scannerStateSnapshot.data?.scanIsInProgress ?? false;
    if (scanning) {
      return FloatingActionButton(
        onPressed: _stopScan,
        backgroundColor: Colors.red,
        child: const Icon(Icons.stop),
      );
    } else {
      return FloatingActionButton(
        onPressed: _startScan,
        child: const Icon(Icons.search),
      );
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<BleScannerState>(
        stream: _scanner.state,
        initialData: _scanner.stateSnapshot,
        builder: (context, scannerStateSnapshot) => Scaffold(
          appBar: AppBar(
            title: const Text(Texts.beaconScanTitle),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _onCancel(context),
            ),
          ),
          floatingActionButton: _fab(context, scannerStateSnapshot),
          body: _scanResultList(context, scannerStateSnapshot),
        ),
      );
}

bool _notABattalarmDevice(DiscoveredDevice device) {
  final isAdapter = [uuidConfigService, uuidStatusService]
      .map((e) => device.serviceUuids.contains(e))
      .where((e) => e)
      .isNotEmpty;

  return !isAdapter;
}

int _scanResultSorter(DiscoveredDevice a, DiscoveredDevice b) {
  if (a.name.isNotEmpty && b.name.isEmpty) return -1;
  if (b.name.isNotEmpty && a.name.isEmpty) return 1;

  final result = a.name.compareTo(b.name);
  if (result != 0) return result;

  return a.id.compareTo(b.id);
}
