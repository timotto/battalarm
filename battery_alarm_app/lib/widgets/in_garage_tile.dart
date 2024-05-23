import 'package:battery_alarm_app/text.dart';
import 'package:battery_alarm_app/widgets/tri_state_bool_widget.dart';
import 'package:flutter/material.dart';

class InGarageTile extends TriStateBoolWidget {
  InGarageTile({
    super.key,
    super.value,
  }) : super(
          title: Texts.labelInGarageTile(),
          labels: _inGarageTriState,
        );
}

final _inGarageTriState = TriStateBool(
  unknown: TriStateBoolValue(
    text: '...',
    icon: Icons.pending,
  ),
  isTrue: TriStateBoolValue(
    text: Texts.labelInGarageTileInGarage(),
    icon: Icons.home,
    trailing: const Icon(Icons.check_circle, color: Color.fromARGB(255, 0, 255, 0),),
  ),
  isFalse: TriStateBoolValue(
    text: Texts.labelInGarageTileNotInGarage(),
    icon: Icons.remove_road,
  ),
);
