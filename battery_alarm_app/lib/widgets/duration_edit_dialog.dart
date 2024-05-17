import 'package:battery_alarm_app/util/duration.dart';
import 'package:battery_alarm_app/widgets/duration_slider.dart';
import 'package:flutter/material.dart';

class DurationEditDialog extends StatefulWidget {
  const DurationEditDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.min,
    required this.max,
    this.value,
    required this.onChange,
  });

  final String title;
  final IconData icon;
  final Duration min, max;
  final Duration? value;
  final void Function(Duration?) onChange;

  @override
  State<StatefulWidget> createState() => _DurationEditDialogState();
}

class _DurationEditDialogState extends State<DurationEditDialog> {
  Duration? _currentValue;


  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  void _onChange(Duration value) {
    setState(() {
      _currentValue = value;
    });
  }

  String _valueString() {
    return formatDuration(_currentValue);
  }

  @override
  Widget build(BuildContext context) => SimpleDialog(
    title: Text(widget.title),
    children: [
      DurationSlider(
        title: widget.title,
        min: widget.min,
        max: widget.max,
        value: _currentValue,
        onChanged: _onChange,
      ),
      Center(child: Text(_valueString())),
      SimpleDialogOption(
        child: const Text('OK'),
        onPressed: () {
          widget.onChange(_currentValue);
          Navigator.pop(context);
        },
      ),
    ],
  );
}
