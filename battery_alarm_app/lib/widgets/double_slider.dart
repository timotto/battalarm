import 'package:flutter/material.dart';

class DoubleSlider extends StatefulWidget {
  const DoubleSlider({
    super.key,
    required this.title,
    required this.min,
    required this.max,
    required this.onChanged,
    this.stepSize,
    this.value,
  });

  final String title;
  final double min, max;
  final void Function(double) onChanged;
  final double? stepSize;
  final double? value;

  @override
  State<StatefulWidget> createState() => _DoubleSliderState();
}

class _DoubleSliderState extends State<DoubleSlider> {
  double _currentValue = 0;
  int _divisions = 1;

  @override
  void initState() {
    super.initState();

    _initCurrentValue();

    final range = widget.max - widget.min;
    if (widget.stepSize != null) {
      _divisions = (range / widget.stepSize!).toInt();
    } else {
      var steps = range / 10;
      if (steps < 1) steps = 1;
      _divisions = steps.toInt();
    }
  }


  @override
  void didUpdateWidget(DoubleSlider oldWidget) {
    super.didUpdateWidget(oldWidget);

    _initCurrentValue();
  }

  void _initCurrentValue() {
    _currentValue = widget.value ?? widget.min;

    if (_currentValue < widget.min) _currentValue = widget.min;
    if (_currentValue > widget.max) _currentValue = widget.max;
  }

  void _onChanged(double value) {
    setState(() {
      _currentValue = value;
    });
    widget.onChanged(_currentValue);
  }

  @override
  Widget build(BuildContext context) => Slider(
        value: _currentValue,
        min: widget.min,
        max: widget.max,
        divisions: _divisions,
        onChanged: _onChanged,
      );
}
