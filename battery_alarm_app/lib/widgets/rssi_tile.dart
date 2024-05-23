import 'package:battery_alarm_app/text.dart';
import 'package:battery_alarm_app/widgets/double_value_tile.dart';
import 'package:flutter/material.dart';

class RssiTile extends DoubleValueTile {
  RssiTile({
    super.key,
    required super.value,
  }) : super(
    title: Texts.labelRssiTile(),
    onNoValue: Texts.labelNoSignal(),
    unit: 'dB',
    digits: 0,
    icon: value != null ? Icons.wifi : Icons.wifi_2_bar,
  );
}
