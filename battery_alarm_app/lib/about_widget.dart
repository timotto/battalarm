import 'package:battery_alarm_app/text.dart';
import 'package:flutter/material.dart';

class AboutWidget extends StatelessWidget {
  const AboutWidget({super.key});

  List<Widget> _text() => Texts.helpPageTexts
      .map((text) => _paddedText(text, 8))
      .toList(growable: false);

  @override
  Widget build(BuildContext context) => Center(
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: _text(),
        ),
      );
}

Widget _paddedText(String text, double padding) =>
    Padding(padding: EdgeInsets.all(padding), child: Text(text));
