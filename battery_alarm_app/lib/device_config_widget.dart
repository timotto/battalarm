import 'dart:async';

import 'package:battery_alarm_app/device_client/device_client.dart';
import 'package:battery_alarm_app/model/config.dart';
import 'package:battery_alarm_app/text.dart';
import 'package:battery_alarm_app/util/stream_and_value.dart';
import 'package:battery_alarm_app/widgets/beacon_config_widget.dart';
import 'package:battery_alarm_app/widgets/bool_config_widget.dart';
import 'package:battery_alarm_app/widgets/double_config_widget.dart';
import 'package:battery_alarm_app/widgets/duration_config_widget.dart';
import 'package:flutter/material.dart';

class DeviceConfigWidget extends StatelessWidget {
  const DeviceConfigWidget({
    super.key,
    required this.deviceClient,
    required this.expert,
  });

  final DeviceClient deviceClient;
  final bool expert;

  StreamAndValue<double?> _currentRssiReading() => StreamAndValue(
      stream: deviceClient.statusService.deviceStatus.transform(
        StreamTransformer.fromHandlers(handleData: (data, sink) {
          sink.add(data.rssi);
        }),
      ),
      value: deviceClient.statusService.deviceStatusSnapshot.rssi);

  StreamAndValue<double?> _currentVbatReading() => StreamAndValue(
      stream: deviceClient.statusService.deviceStatus.transform(
        StreamTransformer.fromHandlers(handleData: (data, sink) {
          sink.add(data.vbat);
        }),
      ),
      value: deviceClient.statusService.deviceStatusSnapshot.vbat);

  StreamAndValue<double?> _currentVbatDeltaReading() => StreamAndValue(
      stream: deviceClient.statusService.deviceStatus.transform(
        StreamTransformer.fromHandlers(handleData: (data, sink) {
          sink.add(data.vbatDelta);
        }),
      ),
      value: deviceClient.statusService.deviceStatusSnapshot.vbatDelta);

  @override
  Widget build(BuildContext context) => StreamBuilder<DeviceConfig>(
        stream: deviceClient.configService.deviceConfig,
        initialData: deviceClient.configService.deviceConfigSnapshot,
        builder: (context, config) => RefreshIndicator(
          onRefresh: deviceClient.configService.readAll,
          child: ListView(
            children: [
              DurationConfigWidget(
                title: Texts.labelDelayWarn(),
                icon: Icons.timer,
                min: const Duration(seconds: 30),
                max: const Duration(minutes: 3),
                value: config.data?.delayWarn,
                onChange: _onChanged(
                  config.data,
                  (config, value) => config.delayWarn = value,
                ),
              ),
              DurationConfigWidget(
                title: Texts.labelDelayAlert(),
                icon: Icons.alarm,
                min: const Duration(seconds: 30),
                max: const Duration(minutes: 3),
                value: config.data?.delayAlarm,
                onChange: _onChanged(
                  config.data,
                  (config, value) => config.delayAlarm = value,
                ),
              ),
              DurationConfigWidget(
                title: Texts.labelSnoozeTime(),
                icon: Icons.bed,
                min: const Duration(seconds: 30),
                max: const Duration(minutes: 3),
                value: config.data?.snoozeTime,
                onChange: _onChanged(
                  config.data,
                  (config, value) => config.snoozeTime = value,
                ),
              ),
              const Divider(),
              DoubleConfigWidget(
                title: Texts.labelRssi(),
                icon: Icons.wifi,
                min: -80,
                max: 0,
                digits: 0,
                value: config.data?.btRssiThreshold,
                unit: 'dB',
                onChange: _onChanged(
                  config.data,
                  (config, value) => config.btRssiThreshold = value,
                ),
                currentReading: _currentRssiReading(),
                onNoCurrentReading: Texts.labelNoSignal(),
              ),
              BoolConfigWidget(
                title: Texts.labelAutoTuneRssi(),
                icon: Icons.science,
                value: config.data?.btRssiAutoTune,
                onChanged: _onChanged(
                  config.data,
                  (config, value) => config.btRssiAutoTune = value,
                ),
              ),
              if (expert) ...[
                BeaconConfigWidget(
                  value: config.data?.btBeaconAddress,
                  onChanged: _onChanged(
                    config.data,
                    (config, value) => config.btBeaconAddress = value,
                  ),
                ),
                const Divider(),
                DoubleConfigWidget(
                  title: Texts.labelVbatChargeThreshold(),
                  icon: Icons.battery_charging_full,
                  min: 12,
                  max: 30,
                  value: config.data?.vbatChargeThreshold,
                  digits: 1,
                  unit: 'V',
                  onChange: _onChanged(
                    config.data,
                    (config, value) => config.vbatChargeThreshold = value,
                  ),
                  currentReading: _currentVbatReading(),
                ),
                DoubleConfigWidget(
                  title: Texts.labelVbatAlternatorThreshold(),
                  icon: Icons.drive_eta,
                  min: 12,
                  max: 30,
                  value: config.data?.vbatAlternatorThreshold,
                  digits: 1,
                  unit: 'V',
                  onChange: _onChanged(
                    config.data,
                    (config, value) => config.vbatAlternatorThreshold = value,
                  ),
                  currentReading: _currentVbatReading(),
                ),
                DoubleConfigWidget(
                  title: Texts.labelVbatDeltaThreshold(),
                  icon: Icons.battery_charging_full,
                  min: 0.001,
                  max: 1,
                  value: config.data?.vbatDeltaThreshold,
                  digits: 3,
                  unit: 'V/t',
                  onChange: _onChanged(
                    config.data,
                    (config, value) => config.vbatDeltaThreshold = value,
                  ),
                  currentReading: _currentVbatDeltaReading(),
                ),
                DoubleConfigWidget(
                  title: Texts.labelVbatTuneFactor(),
                  icon: Icons.show_chart,
                  min: 0.5,
                  max: 1.5,
                  value: config.data?.vbatTuneFactor,
                  digits: 2,
                  unit: '',
                  onChange: _onChanged(
                    config.data,
                    (config, value) => config.vbatTuneFactor = value,
                  ),
                ),
                DoubleConfigWidget(
                  title: Texts.labelVbatLpF(),
                  icon: Icons.battery_4_bar,
                  min: 0.5,
                  max: 0.9999,
                  value: config.data?.vbatLpF,
                  digits: 4,
                  unit: 'V',
                  onChange: _onChanged(
                    config.data,
                    (config, value) => config.vbatLpF = value,
                  ),
                ),
                const Divider(),
                ListTile(
                  title: Text(Texts.labelBuzzerAlerts()),
                  leading: const Icon(Icons.volume_up),
                ),
                ..._buzzerWidgets(
                  values: config.data?.buzzerAlerts,
                  onChanged: _onChanged(
                    config.data,
                    (config, value) => config.buzzerAlerts = value,
                  ),
                ),
              ],
            ],
          ),
        ),
      );

  void Function(T?) _onChanged<T>(
    DeviceConfig? config,
    void Function(DeviceConfig, T?) updater,
  ) {
    return (value) {
      final cpy = config?.clone() ?? DeviceConfig();
      updater(cpy, value);
      deviceClient.configService.update(cpy);
    };
  }
}

List<Widget> _buzzerWidgets({
  required Map<BuzzerAlerts, bool>? values,
  required void Function(Map<BuzzerAlerts, bool>) onChanged,
}) {
  return [
    _buzzerConfigWidget(
      title: Texts.labelBuzzerGarage(),
      key: BuzzerAlerts.garage,
      values: values,
      onChanged: onChanged,
    ),
    _buzzerConfigWidget(
      title: Texts.labelBuzzerCharging(),
      key: BuzzerAlerts.charging,
      values: values,
      onChanged: onChanged,
    ),
    _buzzerConfigWidget(
      title: Texts.labelBuzzerHello(),
      key: BuzzerAlerts.hello,
      values: values,
      onChanged: onChanged,
    ),
    _buzzerConfigWidget(
      title: Texts.labelBuzzerButton(),
      key: BuzzerAlerts.button,
      values: values,
      onChanged: onChanged,
    ),
    _buzzerConfigWidget(
      title: Texts.labelBuzzerBluetooth(),
      key: BuzzerAlerts.bluetooth,
      values: values,
      onChanged: onChanged,
    ),
  ];
}

Widget _buzzerConfigWidget({
  required String title,
  required BuzzerAlerts key,
  required Map<BuzzerAlerts, bool>? values,
  required void Function(Map<BuzzerAlerts, bool>) onChanged,
}) {
  return BoolConfigWidget(
    title: title,
    onChanged: (value) {
      final cpy =
          Map<BuzzerAlerts, bool>.from(values ?? <BuzzerAlerts, bool>{});
      cpy[key] = value ?? false;
      onChanged(cpy);
    },
    value: values?[key],
  );
}
