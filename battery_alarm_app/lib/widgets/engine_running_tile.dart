import 'package:battery_alarm_app/text.dart';
import 'package:battery_alarm_app/widgets/tri_state_bool_widget.dart';
import 'package:flutter/material.dart';

class EngineRunningTile extends TriStateBoolWidget {
  EngineRunningTile({
    super.key,
    super.value,
  }) : super(
          title: Texts.labelEngineRunningTitle(),
          labels: _triState,
        );
}

final _triState = TriStateBool(
  unknown: TriStateBoolValue(
    text: '...',
    icon: Icons.pending,
  ),
  isTrue: TriStateBoolValue(
    text: Texts.labelEngineRunningOn(),
    icon: Icons.car_rental,
  ),
  isFalse: TriStateBoolValue(
    text: Texts.labelEngineRunningOff(),
    icon: Icons.car_rental,
    trailing: const Icon(
      Icons.check_circle,
      color: Color.fromARGB(255, 0, 255, 0),
    ),
  ),
);
