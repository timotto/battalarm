import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutWidget extends StatelessWidget {
  const AboutWidget({super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            Text(
                'Mit dieser App kannst du den Fahrzeug-in-der-Garage-aber-Batterie-wird-nicht-geladen-Alarm-Adapter einstellen.'),
            Text(
                'Viele der Einstellungen sind verwirrend und helfen dir nur, wenn du den Source Code vom Adapter kennst.'),
            Text(
                'Den Source Code vom Adapter, sowie alle weiteren Informationen um dir selber einen zu bauen, findest du unter https://github.com/timotto/battalarm'),
          ],
        ),
      );
}
