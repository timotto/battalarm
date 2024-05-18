import 'package:flutter/material.dart';

class AboutWidget extends StatelessWidget {
  const AboutWidget({super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            _paddedText(
                'Mit dieser App kannst du den Fahrzeug-in-der-Garage-aber-Batterie-wird-nicht-geladen-Alarm-Adapter einstellen.',
                8),
            _paddedText(
                'Solange hier nur so ein spärlicher Text steht sind viele der Einstellungen verwirrend und helfen dir nur, wenn du den Source Code vom Adapter kennst.',
                8),
            _paddedText(
                'Den Source Code vom Adapter, sowie alle weiteren Informationen um dir selber einen zu bauen, findest du unter https://github.com/timotto/battalarm',
                8),
          ],
        ),
      );
}

Widget _paddedText(String text, double padding) =>
    Padding(padding: EdgeInsets.all(padding), child: Text(text));
