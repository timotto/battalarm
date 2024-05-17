import 'package:flutter/material.dart';

class BoolConfigWidget extends StatelessWidget {
  const BoolConfigWidget({
    super.key,
    required this.title,
    required this.onChanged,
    required this.value,
  });

  final String title;
  final void Function(bool?)? onChanged;
  final bool? value;

  @override
  Widget build(BuildContext context) => CheckboxListTile(
    title: Text(title),
    value: value ?? false,
    onChanged: onChanged,
  );
}
