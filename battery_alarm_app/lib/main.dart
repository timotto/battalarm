import 'package:battery_alarm_app/bt/adapter.dart';
import 'package:battery_alarm_app/bt/bt_guard_widget.dart';
import 'package:battery_alarm_app/bt/bt_state_chooser.dart';
import 'package:battery_alarm_app/bt/device_scanner_widget.dart';
import 'package:battery_alarm_app/connect_widget.dart';
import 'package:battery_alarm_app/device_client/device_client.dart';
import 'package:battery_alarm_app/device_client/status_service.dart';
import 'package:battery_alarm_app/device_control.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _bleRuntime = BluetoothRuntimeAdapter();
  final _deviceClient = DeviceClient();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DeviceClient>(create: (_) => _deviceClient),
        Provider<StatusService>(create: (_) => _deviceClient.statusService),
        ..._bleRuntime.providers(),
      ],
      child: MaterialApp(
        title: 'Battalarm',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          useMaterial3: true,
        ),
        home: BluetoothGuardWidget(
          builder: (_) => BluetoothStateChooserWidget(
            deviceClient: _deviceClient,
            onConnected: (_) => const DeviceControlWidget(),
            onConnecting: (_) => const ConnectWidget(),
            onDisconnected: (_) => const DeviceScannerWidget(),
          ),
        ),
      ),
    );
  }
}
