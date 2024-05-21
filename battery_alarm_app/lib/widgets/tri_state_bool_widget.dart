import 'package:flutter/material.dart';

class TriStateBoolWidget extends StatelessWidget {
  const TriStateBoolWidget({
    super.key,
    required this.title,
    required this.labels,
    this.value,
  });

  final String title;
  final TriStateBool labels;
  final bool? value;

  TriStateBoolValue _state() {
    if (value == null) return labels.unknown;
    return value! ? labels.isTrue : labels.isFalse;
  }

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(title),
        subtitle: Text(_state().text),
        leading: Icon(_state().icon),
        trailing: _state().trailing,
      );
}

class TriStateBool {
  TriStateBool({
    required this.unknown,
    required this.isTrue,
    required this.isFalse,
  });

  final TriStateBoolValue unknown;
  final TriStateBoolValue isTrue;
  final TriStateBoolValue isFalse;
}

class TriStateBoolValue {
  TriStateBoolValue({
    required this.text,
    required this.icon,
    this.trailing,
  });

  final String text;
  final IconData icon;
  final Widget? trailing;
}
