import 'package:battery_alarm_app/text.dart';
import 'package:battery_alarm_app/widgets/double_value_tile.dart';
import 'package:flutter/material.dart';

class VBatTile extends DoubleValueTile {
  VBatTile({
    super.key,
    required super.value,
  }) : super(
          title: Texts.labelVbatTile(),
          unit: 'V',
          digits: 1,
          icon: Icons.battery_full,
        );
}
