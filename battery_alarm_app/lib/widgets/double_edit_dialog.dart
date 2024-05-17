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
  });

  final String title;
  final IconData icon;
  final double min, max;
  final int digits;
  final String unit;
  final double? value;
  final void Function(double?) onChange;

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
        _errorText = 'Das ist keine Zahl 🤦';
      });
      return;
    }

    if (value < widget.min) {
      setState(() {
        _errorText = 'Die Eingabe ist zu niedrig, mindestens ${widget.min.toStringAsFixed(widget.digits)}.';
      });
      return;
    }

    if (value > widget.max) {
      setState(() {
        _errorText = 'Die Eingabe ist zu hoch, höchstens ${widget.max.toStringAsFixed(widget.digits)}.';
      });
      return;
    }

    setState((){
      _currentValue = value;
      _errorText = null;
    });
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.title),
        content: TextField(
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
        actions: [
          TextButton(
            onPressed: _hasErrors() ? null : () {
              widget.onChange(_currentValue);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      );
}
