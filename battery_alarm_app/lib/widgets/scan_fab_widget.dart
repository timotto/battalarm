import 'package:battery_alarm_app/bt/scanner.dart';
import 'package:flutter/material.dart';

class ScanFabWidget extends StatelessWidget {
  const ScanFabWidget({
    super.key,
    required this.state,
    required this.onStartScan,
    required this.onStopScan,
  });

  final BleScannerState? state;
  final void Function() onStartScan;
  final void Function() onStopScan;

  @override
  Widget build(BuildContext context) => (state?.scanIsInProgress ?? false)
      ? FloatingActionButton(
          onPressed: onStartScan,
          child: const Icon(Icons.search),
        )
      : FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: onStopScan,
          child: const Icon(Icons.stop),
        );
}
