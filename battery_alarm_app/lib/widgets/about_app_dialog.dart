import 'package:battery_alarm_app/dev.dart';
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
      applicationIcon: _DeveloperAppIconWidget(),
    ),
  );
}

class _DeveloperAppIconWidget extends StatefulWidget {
  final _dev = DeveloperService();

  @override
  State<StatefulWidget> createState() => _DeveloperAppIconState();
}

class _DeveloperAppIconState extends State<_DeveloperAppIconWidget> {
  DateTime? _lastTap;
  int _tapCount = 0;

  void _onTap(BuildContext context) {
    if (_sinceLastTap() > const Duration(seconds: 2)) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }

    if (_tapCount == 7) {
      widget._dev.isDeveloper = !widget._dev.isDeveloper;
      _tapCount = 0;

      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
        content: Text(widget._dev.isDeveloper
            ? 'You are now a developer!'
            : 'You are no longer a developer.'),
      ));
    }
  }

  Duration _sinceLastTap() {
    final now = DateTime.timestamp();

    if (_lastTap == null) {
      _lastTap = now;
      return const Duration();
    }

    final dt = now.difference(_lastTap!);
    _lastTap = now;
    return dt;
  }

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => _onTap(context),
        child: const AppIcon(),
      );
}
