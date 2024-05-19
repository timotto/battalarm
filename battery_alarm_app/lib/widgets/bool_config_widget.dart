import 'package:flutter/material.dart';

class BoolConfigWidget extends StatelessWidget {
  const BoolConfigWidget({
    super.key,
    required this.title,
    this.icon,
    required this.onChanged,
    required this.value,
  });

  final String title;
  final IconData? icon;
  final void Function(bool?)? onChanged;
  final bool? value;

  @override
  Widget build(BuildContext context) => CheckboxListTile(
    title: Text(title),
    secondary: icon != null ? Icon(icon) : null,
    value: value ?? false,
    onChanged: onChanged,
  );
}
