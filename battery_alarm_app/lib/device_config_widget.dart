import 'package:battery_alarm_app/device_client/device_client.dart';
import 'package:battery_alarm_app/model/config.dart';
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

  @override
  Widget build(BuildContext context) => StreamBuilder<DeviceConfig>(
        stream: deviceClient.configService.deviceConfig,
        initialData: deviceClient.configService.deviceConfigSnapshot,
        builder: (context, config) => RefreshIndicator(
          onRefresh: deviceClient.configService.readAll,
          child: ListView(
            children: [
              DurationConfigWidget(
                title: 'Verzögerung bis zur Warnung',
                icon: Icons.timer,
                min: const Duration(seconds: 30),
                max: const Duration(minutes: 3),
                value: config.data?.delayWarn,
                onChange: _onChanged(
                  deviceClient,
                  config.data,
                  (config, value) => config.delayWarn = value,
                ),
              ),
              DurationConfigWidget(
                title: 'Verzögerung bis zum Alarm',
                icon: Icons.alarm,
                min: const Duration(seconds: 30),
                max: const Duration(minutes: 3),
                value: config.data?.delayAlarm,
                onChange: _onChanged(
                  deviceClient,
                  config.data,
                  (config, value) => config.delayAlarm = value,
                ),
              ),
              DurationConfigWidget(
                title: 'Snooze time',
                icon: Icons.bed,
                min: const Duration(seconds: 30),
                max: const Duration(minutes: 3),
                value: config.data?.snoozeTime,
                onChange: _onChanged(
                  deviceClient,
                  config.data,
                  (config, value) => config.snoozeTime = value,
                ),
              ),
              const Divider(),
              DoubleConfigWidget(
                title: 'Basisstation Signalstärke in Garage',
                icon: Icons.wifi,
                min: -80,
                max: 0,
                digits: 0,
                value: config.data?.btRssiThreshold,
                unit: 'dB',
                onChange: _onChanged(
                  deviceClient,
                  config.data,
                  (config, value) => config.btRssiThreshold = value,
                ),
              ),
              BoolConfigWidget(
                title: 'Signalstärke automatisch anpassen',
                icon: Icons.science,
                value: config.data?.btRssiAutoTune,
                onChanged: _onChanged(
                  deviceClient,
                  config.data,
                  (config, value) => config.btRssiAutoTune = value,
                ),
              ),
              if (expert) ...[
                BeaconConfigWidget(
                  value: config.data?.btBeaconAddress,
                  onChanged: _onChanged(
                    deviceClient,
                    config.data,
                    (config, value) => config.btBeaconAddress = value,
                  ),
                ),
                const Divider(),
                DoubleConfigWidget(
                  title: 'Batterieladegerät Endspannung',
                  icon: Icons.battery_charging_full,
                  min: 12,
                  max: 30,
                  value: config.data?.vbatChargeThreshold,
                  digits: 1,
                  unit: 'V',
                  onChange: _onChanged(
                    deviceClient,
                    config.data,
                    (config, value) => config.vbatChargeThreshold = value,
                  ),
                ),
                DoubleConfigWidget(
                  title: 'Batterieladegerät Geschwindigkeit',
                  icon: Icons.battery_charging_full,
                  min: 0.001,
                  max: 1,
                  value: config.data?.vbatDeltaThreshold,
                  digits: 1,
                  unit: 'V/t',
                  onChange: _onChanged(
                    deviceClient,
                    config.data,
                    (config, value) => config.vbatDeltaThreshold = value,
                  ),
                ),
                DoubleConfigWidget(
                  title: 'Batteriespannung Feinjustierung',
                  icon: Icons.show_chart,
                  min: 0.5,
                  max: 1.5,
                  value: config.data?.vbatTuneFactor,
                  digits: 2,
                  unit: '',
                  onChange: _onChanged(
                    deviceClient,
                    config.data,
                    (config, value) => config.vbatTuneFactor = value,
                  ),
                ),
                DoubleConfigWidget(
                  title: 'Batteriespannung Tiefpass Faktor',
                  icon: Icons.battery_4_bar,
                  min: 0.5,
                  max: 0.9999,
                  value: config.data?.vbatLpF,
                  digits: 4,
                  unit: 'V',
                  onChange: _onChanged(
                    deviceClient,
                    config.data,
                    (config, value) => config.vbatLpF = value,
                  ),
                ),
                const Divider(),
                const ListTile(
                  title: Text('Akkustische Benachrichtigung bei:'),
                  leading: Icon(Icons.volume_up),
                ),
                ..._buzzerWidgets(
                  values: config.data?.buzzerAlerts,
                  onChanged: _onChanged(
                    deviceClient,
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
    DeviceClient deviceClient,
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
      title: 'Garage betreten oder verlassen',
      key: BuzzerAlerts.garage,
      values: values,
      onChanged: onChanged,
    ),
    _buzzerConfigWidget(
      title: 'Batterieladegerät angeschlossen',
      key: BuzzerAlerts.charging,
      values: values,
      onChanged: onChanged,
    ),
    _buzzerConfigWidget(
      title: 'Begrüßung',
      key: BuzzerAlerts.hello,
      values: values,
      onChanged: onChanged,
    ),
    _buzzerConfigWidget(
      title: 'Knopf am Gerät',
      key: BuzzerAlerts.button,
      values: values,
      onChanged: onChanged,
    ),
    _buzzerConfigWidget(
      title: 'Bluetooth Aktivität',
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
