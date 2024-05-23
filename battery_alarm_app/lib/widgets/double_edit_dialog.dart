import 'package:battery_alarm_app/text.dart';
import 'package:battery_alarm_app/util/stream_and_value.dart';
import 'package:flutter/material.dart';

class DoubleEditDialog extends StatefulWidget {
  const DoubleEditDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.min,
    required this.max,
    required this.unit,
    required this.digits,
    this.value,
    required this.onChange,
    this.currentReading,
    this.onNoCurrentReading,
  });

  final String title;
  final IconData icon;
  final double min, max;
  final int digits;
  final String unit;
  final double? value;
  final void Function(double?) onChange;

  final StreamAndValue<double?>? currentReading;
  final String? onNoCurrentReading;

  @override
  State<StatefulWidget> createState() => _DoubleEditDialogState();
}

class _DoubleEditDialogState extends State<DoubleEditDialog> {
  double? _currentValue;
  String? _errorText;
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _controller = TextEditingController(
      text: widget.value?.toStringAsFixed(widget.digits) ?? '',
    );
  }

  bool _signed() {
    return widget.min < 0;
  }

  bool _hasErrors() => _errorText != null;

  void _textChanged(String text) {
    final value = double.tryParse(text);
    if (value == null) {
      setState(() {
        _errorText = Texts.doubleEditDialogNotANumber();
      });
      return;
    }

    if (value < widget.min) {
      setState(() {
        _errorText = Texts.doubleEditDialogToLow(
            widget.min.toStringAsFixed(widget.digits));
      });
      return;
    }

    if (value > widget.max) {
      setState(() {
        _errorText = Texts.doubleEditDialogToHigh(
            widget.max.toStringAsFixed(widget.digits));
      });
      return;
    }

    setState(() {
      _currentValue = value;
      _errorText = null;
    });
  }

  void _onApply(double value) {
    final text = value.toStringAsFixed(widget.digits);
    _controller?.text = text;
    _textChanged(text);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                suffix: Text(widget.unit),
                errorText: _errorText,
              ),
              keyboardType: TextInputType.numberWithOptions(
                decimal: widget.digits == 0,
                signed: _signed(),
              ),
              onChanged: _textChanged,
            ),
            if (widget.currentReading != null)
              _CurrentReadingWidget(
                currentReading: widget.currentReading!,
                onNoCurrentReading: widget.onNoCurrentReading,
                unit: widget.unit,
                digits: widget.digits,
              ),
          ],
        ),
        actions: [
          if (widget.currentReading != null)
            _ApplyCurrentReadingWidget(
              currentReading: widget.currentReading!,
              onApply: _onApply,
            ),
          TextButton(
            onPressed: _hasErrors()
                ? null
                : () {
                    widget.onChange(_currentValue);
                    Navigator.pop(context);
                  },
            child: Text(Texts.buttonOk()),
          ),
        ],
      );
}

class _CurrentReadingWidget extends StatelessWidget {
  const _CurrentReadingWidget({
    required this.currentReading,
    required this.onNoCurrentReading,
    required this.unit,
    required this.digits,
  });

  final StreamAndValue<double?> currentReading;
  final String? onNoCurrentReading;
  final String unit;
  final int digits;

  String _value(double? value) {
    if (value == null) {
      if (onNoCurrentReading != null) return onNoCurrentReading!;
      return '-';
    }

    return '${value.toStringAsFixed(digits)} $unit';
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: currentReading.stream,
        initialData: currentReading.value,
        builder: (context, readingSnapshot) => Text(
            '${Texts.labelCurrentValue()}: ${_value(readingSnapshot.data)}'),
      );
}

class _ApplyCurrentReadingWidget extends StatelessWidget {
  const _ApplyCurrentReadingWidget({
    required this.currentReading,
    required this.onApply,
  });

  final StreamAndValue<double?> currentReading;
  final void Function(double) onApply;

  void Function()? _applyFunction(double? value) =>
      value == null ? null : () => onApply(value);

  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: currentReading.stream,
      initialData: currentReading.value,
      builder: (context, readingSnapshot) => TextButton(
            onPressed: _applyFunction(readingSnapshot.data),
            child: Text(Texts.buttonApplyValue()),
          ));
}
