import 'package:battery_alarm_app/bt/scanner.dart';
import 'package:battery_alarm_app/model/bt_uuid.dart';
import 'package:battery_alarm_app/text.dart';
import 'package:battery_alarm_app/widgets/scan_fab_widget.dart';
import 'package:battery_alarm_app/widgets/scan_result_widget.dart';
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
          floatingActionButton: ScanFabWidget(
            state: scannerStateSnapshot.data,
            onStartScan: _startScan,
            onStopScan: _stopScan,
          ),
          body: ScanResultWidget(
            state: scannerStateSnapshot.data,
            showRssi: true,
            currentDeviceId: widget.currentBeaconId,
            filter: _notABattalarmDevice,
            onSelect: (device) => _onSelect(context, device),
          ),
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
