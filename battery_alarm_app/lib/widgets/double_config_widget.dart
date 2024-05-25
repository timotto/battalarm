import 'package:battery_alarm_app/util/stream_and_value.dart';
import 'package:battery_alarm_app/widgets/double_edit_dialog.dart';
import 'package:flutter/material.dart';

class DoubleConfigWidget extends StatelessWidget {
  const DoubleConfigWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.min,
    required this.max,
    required this.digits,
    required this.value,
    required this.unit,
    required this.onChange,
    this.currentReading,
    this.onNoCurrentReading,
  });

  final String title;
  final IconData icon;
  final double min, max;
  final double? value;
  final int digits;
  final String unit;
  final void Function(double?) onChange;

  final StreamAndValue<double?>? currentReading;
  final String? onNoCurrentReading;

  String _value() {
    if (value == null) return '-';
    return '${value?.toStringAsFixed(digits)} $unit';
  }

  void _onTap(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) => DoubleEditDialog(
              title: title,
              icon: icon,
              min: min,
              max: max,
              unit: unit,
              digits: digits,
              onChange: onChange,
              value: value,
              currentReading: currentReading,
              onNoCurrentReading: onNoCurrentReading,
            ));
  }

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(title),
        leading: Icon(icon),
        subtitle: Text(_value()),
        enabled: value != null,
        onTap: value == null ? null : () => _onTap(context),
      );
}
