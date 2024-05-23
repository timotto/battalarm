import 'package:battery_alarm_app/text.dart';
import 'package:battery_alarm_app/util/beacon.dart';
import 'package:battery_alarm_app/widgets/beacon_scan_widget.dart';
import 'package:flutter/material.dart';

class BeaconConfigWidget extends StatelessWidget {
  const BeaconConfigWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final void Function(String value) onChanged;

  void _openScanner(BuildContext context) async {
    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
          builder: (_) => BeaconScanWidget(
                currentBeaconId: value,
              )),
    );
    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(Texts.labelBeacon()),
        subtitle: Text(formatBeaconAddress(value)),
        leading: const Icon(Icons.settings_input_antenna),
        onTap: () => _openScanner(context),
      );
}
