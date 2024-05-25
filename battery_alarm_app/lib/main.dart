import 'dart:io';

import 'package:battery_alarm_app/bt/bt_guard_widget.dart';
import 'package:battery_alarm_app/bt/bt_state_chooser.dart';
import 'package:battery_alarm_app/connect_widget.dart';
import 'package:battery_alarm_app/device_control.dart';
import 'package:battery_alarm_app/device_scanner.dart';
import 'package:battery_alarm_app/i10n/appmessages_all.dart';
import 'package:battery_alarm_app/text.dart';
import 'package:flutter/material.dart';

void main() {
  initializeMessages(Platform.localeName).then((_) => runApp(const App()));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Texts.appTitle(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffff5540)),
        useMaterial3: true,
      ),
      home: BluetoothGuardWidget(
        builder: (_) => BluetoothStateChooserWidget(
          onConnected: (_) => DeviceControlWidget(),
          onConnecting: (_) => ConnectWidget(),
          onDisconnected: (_, {error}) => DeviceScannerWidget(error: error),
        ),
      ),
    );
  }
}
