import 'package:flutter/material.dart';

class DurationSlider extends StatefulWidget {
  const DurationSlider({
    super.key,
    required this.title,
    required this.min,
    required this.max,
    required this.onChanged,
    this.value,
  });

  final String title;
  final Duration min, max;
  final Duration? value;
  final void Function(Duration) onChanged;

  @override
  State<StatefulWidget> createState() => _DurationSliderState();
}

class _DurationSliderState extends State<DurationSlider> {
  double _currentValue = 0;
  double _minValue = 0;
  double _maxValue = 0;
  int _divisions = 1;

  @override
  void initState() {
    super.initState();
    _currentValue =
        (widget.value?.inSeconds ?? widget.min.inSeconds).toDouble();
    _minValue = widget.min.inSeconds.toDouble();
    _maxValue = widget.max.inSeconds.toDouble();

    if (_currentValue < _minValue) _currentValue = _minValue;
    if (_currentValue > _maxValue) _currentValue = _maxValue;

    final range = _maxValue - _minValue;
    var steps = range / 10;
    if (steps < 1) steps = 1;
    _divisions = steps.toInt();
  }

  void _onChanged(double value) {
    setState(() {
      _currentValue = value;
    });
    widget.onChanged(_duration());
  }

  Duration _duration() {
    return Duration(seconds: _currentValue.toInt());
  }

  @override
  Widget build(BuildContext context) => Slider(
    value: _currentValue,
    min: _minValue,
    max: _maxValue,
    divisions: _divisions,
    onChanged: _onChanged,
  );
}
