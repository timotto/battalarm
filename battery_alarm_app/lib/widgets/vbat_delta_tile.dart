import 'package:battery_alarm_app/widgets/double_value_tile.dart';
import 'package:flutter/material.dart';

class VBatDeltaTile extends DoubleValueTile {
  const VBatDeltaTile({
    super.key,
    required super.value,
  }) : super(
    title: 'Ladungsveränderung',
    unit: 'V/t',
    digits: 1,
    icon: Icons.battery_3_bar,
  );
}
