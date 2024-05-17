import 'package:flutter/material.dart';

class DoubleValueTile extends StatelessWidget {
  const DoubleValueTile({
    super.key,
    required this.title,
    required this.icon,
    this.value,
    required this.unit,
    required this.digits,
    this.onNoValue,
  });

  final String title;
  final IconData icon;
  final double? value;
  final String unit;
  final int digits;
  final String? onNoValue;

  String _value() {
    if (value == null) return onNoValue ?? '-';
    return '${value!.toStringAsFixed(digits)} $unit';
  }

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(title),
    subtitle: Text(_value()),
    leading: Icon(icon),
  );
}
