import 'package:battery_alarm_app/bt/bt_guard_widget.dart';
import 'package:battery_alarm_app/device_client/device_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

class ConnectWidget extends StatelessWidget {
  const ConnectWidget({super.key});

  @override
  Widget build(BuildContext context) => BluetoothGuardWidget(
      builder: (_) => Consumer<DeviceClient>(builder: _builder));

  Widget _builder(BuildContext context, DeviceClient deviceClient, Widget? _) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Battalarm'),
      ),
      body: Center(
        child: StreamBuilder(
          stream: deviceClient.connectionStatusUpdate,
          builder: (_, update) => _ConnectionStatusWidget(update: update),
        ),
      ),
    );
  }
}

class _ConnectionStatusWidget extends StatelessWidget {
  const _ConnectionStatusWidget({super.key, required this.update});

  final AsyncSnapshot<ConnectionStateUpdate> update;

  @override
  Widget build(BuildContext context) {
    if (update.hasData) {
      if (update.requireData.failure != null) {
        return Text(
            update.requireData.failure?.message ?? 'Verbindung Fehlgeschlagen');
      }

      return Text(_connectionStateAsText(update.requireData.connectionState));
    }

    return Text(_connectionStateAsText(null));
  }
}

String _connectionStateAsText(DeviceConnectionState? state) {
  switch (state) {
    case null:
    case DeviceConnectionState.connecting:
      return 'Verbinde...';

    case DeviceConnectionState.connected:
      return 'Verbunden';

    case DeviceConnectionState.disconnecting:
      return 'Trennen...';

    case DeviceConnectionState.disconnected:
      return 'Getrennt';
  }
}
