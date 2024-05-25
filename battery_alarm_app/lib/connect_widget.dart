import 'package:battery_alarm_app/device_client/device_client.dart';
import 'package:battery_alarm_app/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

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
        const _ProgressSpinnerWidget(),
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

class _ProgressSpinnerWidget extends StatefulWidget {
  const _ProgressSpinnerWidget();

  @override
  State<StatefulWidget> createState() => _ProgressSpinnerState();
}

class _ProgressSpinnerState extends State<_ProgressSpinnerWidget>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )
      ..addListener(() => setState(() {}))
      ..repeat();

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 192,
    height: 192,
    child: CircularProgressIndicator(
      value: controller.value,
      semanticsLabel: 'Animation indicating activity',
    ),
  );
}
