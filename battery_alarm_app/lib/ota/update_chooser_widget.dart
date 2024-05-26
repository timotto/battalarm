import 'package:battery_alarm_app/model/version.dart';
import 'package:flutter/material.dart';

class UpdateChooserWidget extends StatelessWidget {
  const UpdateChooserWidget({
    super.key,
    this.deviceVersion,
    this.availableVersion,
    required this.onStartUpdate,
    required this.onTapDeviceVersion,
  });

  final Version? deviceVersion;
  final Version? availableVersion;
  final void Function() onStartUpdate;
  final void Function() onTapDeviceVersion;

  bool _loading() => deviceVersion == null || availableVersion == null;

  bool _hasUpdate() =>
      deviceVersion != null &&
      availableVersion != null &&
      availableVersion!.isBetterThan(deviceVersion!);

  List<Widget> _result() {
    if (_loading()) {
      return [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text('Looking for available updates...'),
        ),
        const LinearProgressIndicator(value: null),
      ];
    }

    if (!_hasUpdate()) {
      return [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text('There is no update available.'),
        ),
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text('Your adapter has the latest software version.'),
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

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Adapter software version'),
            subtitle: Text(deviceVersion?.toString() ?? '...'),
            onTap: onTapDeviceVersion,
          ),
          ..._result(),
        ],
      );
}
