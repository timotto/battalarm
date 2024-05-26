import 'package:battery_alarm_app/util/duration.dart';
import 'package:flutter/material.dart';

class EtaWidget extends StatelessWidget {
  const EtaWidget({
    super.key,
    required this.eta,
  });

  final DateTime? eta;

  @override
  Widget build(BuildContext context) => Text(
        eta == null
            ? '-'
            : formatDuration(eta!.difference(DateTime.timestamp())),
      );
}
