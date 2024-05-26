import 'package:battery_alarm_app/util/duration.dart';
import 'package:flutter/material.dart';

class EtaWidget extends StatelessWidget {
  const EtaWidget({
    super.key,
    required this.value,
  });

  final Duration? value;

  @override
  Widget build(BuildContext context) =>
      Text('Time remaining: ${formatDuration(value)}');
}
