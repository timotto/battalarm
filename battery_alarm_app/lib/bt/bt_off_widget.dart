import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothOffWidget extends StatelessWidget {
  final BleStatus? state;

  const BluetoothOffWidget({super.key, this.state});

  @override
  Widget build(BuildContext context) {
    if (state == BleStatus.unauthorized) {
      requestBluetoothPermission(context);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Battalarm'),),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bluetooth_disabled, size: 200,),
            Text('Bluetooth ist ${_bleStatusLabel(context, state)}')
          ],
        ),
      ),
    );
  }
}

Future<void> requestBluetoothPermission(BuildContext context) async {
  await Permission.bluetooth
      .request()
      .isGranted;
  await Permission.bluetoothScan
      .request()
      .isGranted;
  await Permission.bluetoothConnect
      .request()
      .isGranted;
  await Permission.location
      .request()
      .isGranted;
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
