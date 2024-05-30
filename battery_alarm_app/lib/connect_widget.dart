import 'package:battery_alarm_app/device_client/device_client.dart';
import 'package:battery_alarm_app/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ConnectWidget extends StatelessWidget {
  ConnectWidget({super.key});

  final _deviceClient = DeviceClient();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(Texts.appTitle()),
        ),
        body: Center(
          child: StreamBuilder(
            stream: _deviceClient.connectionStatusUpdate,
            builder: (_, update) => _ConnectionStatusWidget(update: update),
          ),
        ),
      );
}

class _ConnectionStatusWidget extends StatelessWidget {
  const _ConnectionStatusWidget({required this.update});

  final AsyncSnapshot<ConnectionStateUpdate> update;

  @override
  Widget build(BuildContext context) {
    DeviceConnectionState? state;

    if (update.hasData) {
      if (update.requireData.failure != null) {
        return Text(
            update.requireData.failure?.message ?? Texts.connectionFailed());
      }

      state = update.requireData.connectionState;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LoadingAnimationWidget.staggeredDotsWave(color: Colors.red, size: 192),
        Text(_connectionStateAsText(state)),
      ],
    );
  }
}

String _connectionStateAsText(DeviceConnectionState? state) {
  switch (state) {
    case null:
    case DeviceConnectionState.connecting:
      return Texts.connecting();

    case DeviceConnectionState.connected:
      return Texts.connected();

    case DeviceConnectionState.disconnecting:
      return Texts.disconnecting();

    case DeviceConnectionState.disconnected:
      return Texts.disconnected();
  }
}
