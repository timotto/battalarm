import 'package:battery_alarm_app/bt/bt_guard_widget.dart';
import 'package:battery_alarm_app/bt/bt_state_chooser.dart';
import 'package:battery_alarm_app/device_scanner.dart';
import 'package:battery_alarm_app/connect_widget.dart';
import 'package:battery_alarm_app/device_client/device_client.dart';
import 'package:battery_alarm_app/device_control.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _deviceClient = DeviceClient();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battalarm',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: BluetoothGuardWidget(
        builder: (_) => BluetoothStateChooserWidget(
          deviceClient: _deviceClient,
          onConnected: (_) => DeviceControlWidget(
            deviceClient: _deviceClient,
          ),
          onConnecting: (_) => ConnectWidget(
            deviceClient: _deviceClient,
          ),
          onDisconnected: (_, {error}) => DeviceScannerWidget(
            deviceClient: _deviceClient,
            error: error,
          ),
        ),
      ),
    );
  }
}
