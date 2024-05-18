import 'package:battery_alarm_app/device_client/device_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class ConnectWidget extends StatelessWidget {
  const ConnectWidget({
    super.key,
    required this.deviceClient,
  });

  final DeviceClient deviceClient;

  @override
  Widget build(BuildContext context) => Scaffold(
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

class _ConnectionStatusWidget extends StatelessWidget {
  const _ConnectionStatusWidget({super.key, required this.update});

  final AsyncSnapshot<ConnectionStateUpdate> update;

  @override
  Widget build(BuildContext context) {
    DeviceConnectionState? state;

    if (update.hasData) {
      if (update.requireData.failure != null) {
        return Text(
            update.requireData.failure?.message ?? 'Verbindung Fehlgeschlagen');
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
      return 'Verbinde...';

    case DeviceConnectionState.connected:
      return 'Verbunden';

    case DeviceConnectionState.disconnecting:
      return 'Trennen...';

    case DeviceConnectionState.disconnected:
      return 'Getrennt';
  }
}

class _ProgressSpinnerWidget extends StatefulWidget {
  const _ProgressSpinnerWidget({super.key});

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
  Widget build(BuildContext context) => CircularProgressIndicator(
        value: controller.value,
        semanticsLabel: 'Animation indicating activity',
      );
}
