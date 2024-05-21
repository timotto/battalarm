import 'package:battery_alarm_app/device_client/device_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BluetoothStateChooserWidget extends StatelessWidget {
  BluetoothStateChooserWidget({
    super.key,
    required this.onDisconnected,
    required this.onConnecting,
    required this.onConnected,
  });

  final deviceClient = DeviceClient();
  final Widget Function(BuildContext, {GenericFailure<ConnectionError>? error}) onDisconnected;
  final Widget Function(BuildContext) onConnecting;
  final Widget Function(BuildContext) onConnected;

  Widget _builder(BuildContext context, AsyncSnapshot<ConnectionStateUpdate> snapshot) {
    if (!snapshot.hasData) return onDisconnected(context);
    final update = snapshot.requireData;
    if (update.failure != null) {
      return onDisconnected(context, error: update.failure);
    }

    switch (update.connectionState) {
      case DeviceConnectionState.disconnected:
        return onDisconnected(context);
      case DeviceConnectionState.connecting:
        return onConnecting(context);
      case DeviceConnectionState.disconnecting:
        return onDisconnected(context);
      case DeviceConnectionState.connected:
        return onConnected(context);
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: deviceClient.connectionStatusUpdate,
        builder: _builder,
      );
}
