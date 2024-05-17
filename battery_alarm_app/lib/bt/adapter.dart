import 'package:battery_alarm_app/bt/scanner.dart';
import 'package:battery_alarm_app/bt/status_monitor.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class BluetoothRuntimeAdapter {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  late BleScanner _scanner;
  late BleStatusMonitor _monitor;

  BluetoothRuntimeAdapter() {
    _scanner = BleScanner(ble: _ble);
    _monitor = BleStatusMonitor(_ble);
  }

  List<SingleChildWidget> providers() => [
        Provider(create: (_) => _ble),
        Provider(create: (_) => _scanner),
        Provider(create: (_) => _monitor),
        StreamProvider<BleScannerState?>(
          create: (_) => _scanner.state,
          initialData: const BleScannerState(
            discoveredDevices: [],
            scanIsInProgress: false,
          ),
        ),
        StreamProvider<BleStatus?>(
            create: (_) => _monitor.state,
            initialData: BleStatus.unknown,
        ),
      ];
}
