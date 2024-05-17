import 'package:battery_alarm_app/bt/bt_off_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

class BluetoothGuardWidget extends StatelessWidget {
  const BluetoothGuardWidget({super.key, required this.builder});

  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) => Consumer<BleStatus?>(builder: _builder);

  Widget _builder(BuildContext context, BleStatus? status, Widget? _) {
    if (status != BleStatus.ready) {
      return BluetoothOffWidget(state: status);
    }

    return builder(context);
  }
}
