import 'package:battery_alarm_app/device_client/device_client.dart';
import 'package:battery_alarm_app/model/status.dart';
import 'package:battery_alarm_app/widgets/charging_tile.dart';
import 'package:battery_alarm_app/widgets/in_garage_tile.dart';
import 'package:battery_alarm_app/widgets/rssi_tile.dart';
import 'package:battery_alarm_app/widgets/vbat_delta_tile.dart';
import 'package:battery_alarm_app/widgets/vbat_tile.dart';
import 'package:flutter/material.dart';

class DeviceStatusWidget extends StatelessWidget {
  const DeviceStatusWidget({
    super.key,
    required this.deviceClient,
  });

  final DeviceClient deviceClient;

  @override
  Widget build(BuildContext context) => StreamBuilder<DeviceStatus>(
        stream: deviceClient.statusService.deviceStatus,
        initialData: deviceClient.statusService.deviceStatusSnapshot,
        builder: (context, status) => ListView(
          children: [
            InGarageTile(value: status.data?.inGarage),
            ChargingTile(value: status.data?.charging),
            VBatTile(value: status.data?.vbat),
            VBatDeltaTile(value: status.data?.vbatDelta),
            RssiTile(value: _lowRssiToNoValue(status.data?.rssi)),
          ],
        ),
      );
}

double? _lowRssiToNoValue(double? value) =>
    (value == null || value <= -100) ? null : value;
