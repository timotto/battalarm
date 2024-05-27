import 'package:battery_alarm_app/model/version.dart';
import 'package:battery_alarm_app/text.dart';
import 'package:flutter/material.dart';

class UpdateChooserWidget extends StatelessWidget {
  const UpdateChooserWidget({
    super.key,
    this.deviceVersion,
    this.availableVersion,
    required this.onStartUpdate,
    required this.canSelectBeta,
    required this.betaSelected,
    required this.onBetaSelected,
  });

  final Version? deviceVersion;
  final Version? availableVersion;
  final bool canSelectBeta;
  final bool betaSelected;
  final void Function() onStartUpdate;
  final void Function(bool?) onBetaSelected;

  bool _loading() => deviceVersion == null || availableVersion == null;

  bool _hasUpdate() =>
      deviceVersion != null &&
      availableVersion != null &&
      availableVersion!.isBetterThan(deviceVersion!);

  List<Widget> _result(BuildContext context) {
    if (_loading()) {
      return [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(Texts.labelSearchingUpdates()),
        ),
        const LinearProgressIndicator(value: null),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(Texts.buttonCancel()),
        ),
      ];
    }

    if (!_hasUpdate()) {
      return [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(Texts.labelNoUpdateAvailable()),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(Texts.buttonOk()),
        ),
      ];
    }

    return [
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(Texts.labelUpdateAvailable(availableVersion!.toString())),
      ),
      ElevatedButton(
        onPressed: onStartUpdate,
        child: Text(Texts.buttonUpdateAdapter()),
      ),
    ];
  }

  Widget _betaSelector(BuildContext context) => Row(
        children: [
          Checkbox(
            value: betaSelected,
            onChanged: onBetaSelected,
          ),
          Text(Texts.labelShowBetaVersion()),
        ],
      );

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canSelectBeta) _betaSelector(context),
          Text(Texts.labelAdapterVersion(deviceVersion?.toString() ?? '-')),
          ..._result(context),
        ],
      );
}
