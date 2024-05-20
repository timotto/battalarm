import 'package:battery_alarm_app/text.dart';
import 'package:battery_alarm_app/widgets/app_icon.dart';
import 'package:flutter/material.dart';

void showAboutAppDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const AboutDialog(
      applicationName: Texts.appTitle,
      applicationLegalese: Texts.aboutAppLegalese,
      applicationIcon: AppIcon(),
    ),
  );
}
