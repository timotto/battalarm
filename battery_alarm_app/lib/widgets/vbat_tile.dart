import 'package:battery_alarm_app/widgets/double_value_tile.dart';
import 'package:flutter/material.dart';

class VBatTile extends DoubleValueTile {
  const VBatTile({
    super.key,
    required super.value,
  }) : super(
    title: 'Batteriespannung',
    unit: 'V',
    digits: 1,
    icon: Icons.battery_full,
  );
}
