import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothOffWidget extends StatelessWidget {
  const BluetoothOffWidget({super.key, this.state});

  final BleStatus? state;

  @override
  Widget build(BuildContext context) {
    if (state == BleStatus.unauthorized) {
      requestBluetoothPermission(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Battalarm'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _content(context),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context) =>
      state == null ? _contentForNullState(context) : _contentForState(context);

  List<Widget> _contentForNullState(BuildContext context) => [
        const Text('...'),
      ];

  List<Widget> _contentForState(BuildContext context) => [
        const Icon(
          Icons.bluetooth_disabled,
          size: 200,
        ),
        Text('Bluetooth ist ${_bleStatusLabel(context, state)}')
      ];
}

Future<void> requestBluetoothPermission(BuildContext context) async {
  await Permission.bluetooth.request().isGranted;
  await Permission.bluetoothScan.request().isGranted;
  await Permission.bluetoothConnect.request().isGranted;
  await Permission.location.request().isGranted;
}

String _bleStatusLabel(BuildContext context, BleStatus? status) {
  switch (status) {
    case BleStatus.ready:
      return 'bereit';

    case BleStatus.poweredOff:
      return 'ausgeschaltet';

    case BleStatus.unsupported:
      return 'nicht vorhanden';

    case BleStatus.unauthorized:
      return 'nicht erlaubt';

    case BleStatus.locationServicesDisabled:
      return 'auf Location Services angewiesen';

    default:
      return 'nicht verfügbar';
  }
}
