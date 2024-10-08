import 'package:battery_alarm_app/text.dart';
import 'package:battery_alarm_app/widgets/tri_state_bool_widget.dart';
import 'package:flutter/material.dart';

class ChargingTile extends TriStateBoolWidget {
  ChargingTile({
    super.key,
    super.value,
  }) : super(
          title: Texts.labelChargingTitle(),
          labels: _chargingTriState,
        );
}

final _chargingTriState = TriStateBool(
  unknown: TriStateBoolValue(
    text: '...',
    icon: Icons.pending,
  ),
  isTrue: TriStateBoolValue(
    text: Texts.labelChargingIsCharging(),
    icon: Icons.battery_charging_full,
    trailing: const Icon(Icons.check_circle, color: Color.fromARGB(255, 0, 255, 0),),
  ),
  isFalse: TriStateBoolValue(
    text: Texts.labelChargingIsNotCharging(),
    icon: Icons.battery_2_bar,
  ),
);
