import 'package:flutter/material.dart';

class ScanningIndicatorWidget extends StatelessWidget {
  const ScanningIndicatorWidget({super.key, this.value});

  final bool? value;

  double? _value() => (value ?? false) ? null : 0;

  @override
  Widget build(BuildContext context) =>
      LinearProgressIndicator(value: _value());
}
