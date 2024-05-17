import 'package:battery_alarm_app/widgets/double_value_tile.dart';
import 'package:flutter/material.dart';

class RssiTile extends DoubleValueTile {
  const RssiTile({
    super.key,
    required super.value,
  }) : super(
    title: 'Signalstärke Basisstation',
    onNoValue: 'Kein Empfang',
    unit: 'dB',
    digits: 0,
    icon: value != null ? Icons.wifi : Icons.wifi_2_bar,
  );
}
