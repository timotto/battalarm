import 'package:battery_alarm_app/text.dart';
import 'package:battery_alarm_app/version.dart';
import 'package:battery_alarm_app/widgets/app_icon.dart';
import 'package:flutter/material.dart';

void showAboutAppDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AboutDialog(
      applicationName: Texts.appTitle(),
      applicationVersion: appVersion,
      applicationLegalese: Texts.aboutAppLegalese(),
      applicationIcon: const AppIcon(),
    ),
  );
}
