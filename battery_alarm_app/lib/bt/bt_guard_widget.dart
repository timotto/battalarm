import 'package:battery_alarm_app/bt/bt_off_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BluetoothGuardWidget extends StatelessWidget {
  BluetoothGuardWidget({super.key, required this.builder});

  final _ble = FlutterReactiveBle();
  final Widget Function(BuildContext context) builder;

  Widget _builder(BuildContext context, AsyncSnapshot<BleStatus> snapshot) {
    final status = snapshot.data;

    if (status != BleStatus.ready) {
      return BluetoothOffWidget(state: status);
    }

    return builder(context);
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: _ble.statusStream,
        initialData: _ble.status,
        builder: _builder,
      );
}
