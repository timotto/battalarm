import 'package:battery_alarm_app/text.dart';
import 'package:battery_alarm_app/widgets/double_value_tile.dart';
import 'package:flutter/material.dart';

class VBatDeltaTile extends DoubleValueTile {
  VBatDeltaTile({
    super.key,
    required super.value,
  }) : super(
          title: Texts.labelVbatDeltaTile(),
          unit: 'V/t',
          digits: 1,
          icon: Icons.battery_3_bar,
        );
}
