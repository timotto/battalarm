import 'package:battery_alarm_app/util/duration.dart';
import 'package:battery_alarm_app/widgets/duration_edit_dialog.dart';
import 'package:flutter/material.dart';

class DurationConfigWidget extends StatelessWidget {
  const DurationConfigWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.min,
    required this.max,
    required this.value,
    required this.onChange,
  });

  final String title;
  final IconData icon;
  final Duration min, max;
  final Duration? value;
  final void Function(Duration?) onChange;

  String _value() {
    return formatDuration(value);
  }

  void _onTap(BuildContext context) async {
    await showDialog<Duration>(
        context: context,
        builder: (_) => DurationEditDialog(
          title: title,
          icon: icon,
          min: min,
          max: max,
          value: value,
          onChange: onChange,
        ));
  }

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(title),
    leading: Icon(icon),
    subtitle: Text(_value()),
    onTap: () => _onTap(context),
  );
}
