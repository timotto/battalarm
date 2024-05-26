import 'package:battery_alarm_app/model/version.dart';
import 'package:flutter/material.dart';

class UpdateChooserWidget extends StatelessWidget {
  const UpdateChooserWidget({
    super.key,
    this.deviceVersion,
    this.availableVersion,
    required this.onStartUpdate,
    required this.onTapDeviceVersion,
    required this.canSelectBeta,
    required this.betaSelected,
    required this.onBetaSelected,
  });

  final Version? deviceVersion;
  final Version? availableVersion;
  final bool canSelectBeta;
  final bool betaSelected;
  final void Function() onStartUpdate;
  final void Function() onTapDeviceVersion;
  final void Function(bool?) onBetaSelected;

  bool _loading() => deviceVersion == null || availableVersion == null;

  bool _hasUpdate() =>
      deviceVersion != null &&
      availableVersion != null &&
      availableVersion!.isBetterThan(deviceVersion!);

  List<Widget> _result(BuildContext context) {
    if (_loading()) {
      return [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text('Looking for available updates...'),
        ),
        const LinearProgressIndicator(value: null),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ];
    }

    if (!_hasUpdate()) {
      return [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text('There is no update available.'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ];
    }

    return [
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
            'Adapter software version ${availableVersion!.toString()} is available!'),
      ),
      ElevatedButton(
        onPressed: onStartUpdate,
        child: const Text('Update Adapter'),
      ),
    ];
  }

  Widget _betaSelector(BuildContext context) => Row(
        children: [
          Checkbox(
            value: betaSelected,
            onChanged: onBetaSelected,
          ),
          const Text('Show beta version'),
        ],
      );

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canSelectBeta) _betaSelector(context),
          Text('Adapter version: ${deviceVersion?.toString() ?? '-'}'),
          ..._result(context),
        ],
      );
}
