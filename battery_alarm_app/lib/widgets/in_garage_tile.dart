import 'package:battery_alarm_app/widgets/tri_state_bool_widget.dart';
import 'package:flutter/material.dart';

class InGarageTile extends TriStateBoolWidget {
  InGarageTile({
    super.key,
    super.value,
  }) : super(
          title: 'Das Fahrzeug befindet sich',
          labels: _inGarageTriState,
        );
}

final _inGarageTriState = TriStateBool(
  unknown: TriStateBoolValue(
    text: '...',
    icon: Icons.pending,
  ),
  isTrue: TriStateBoolValue(
    text: 'in der Garage',
    icon: Icons.home,
  ),
  isFalse: TriStateBoolValue(
    text: 'nicht in der Garage',
    icon: Icons.remove_road,
  ),
);
