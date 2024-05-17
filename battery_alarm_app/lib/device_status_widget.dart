import 'package:battery_alarm_app/device_client/device_client.dart';
import 'package:battery_alarm_app/model/status.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeviceStatusWidget extends StatelessWidget {
  const DeviceStatusWidget({super.key});

  @override
  Widget build(BuildContext context) => Consumer<DeviceClient>(
        builder: (context, deviceClient, _) => StreamBuilder<DeviceStatus>(
          stream: deviceClient.statusService.deviceStatus,
          initialData: deviceClient.statusService.deviceStatusSnapshot,
          builder: (context, status) => ListView(
            children: [
              _InGarageWidget(value: status.data?.inGarage),
              _ChargingWidget(value: status.data?.charging),
              _VBatWidget(value: status.data?.vbat),
              _VBatDeltaWidget(value: status.data?.vbatDelta),
              _RssiWidget(value: _lowRssiToNoValue(status.data?.rssi)),
            ],
          ),
        ),
      );
}

final _inGarageTriState = _TriStateBool(
  unknown: _TriStateBoolState(
    text: '...',
    icon: Icons.pending,
  ),
  isTrue: _TriStateBoolState(
    text: 'in der Garage',
    icon: Icons.home,
  ),
  isFalse: _TriStateBoolState(
    text: 'nicht in der Garage',
    icon: Icons.remove_road,
  ),
);

final _chargingTriState = _TriStateBool(
  unknown: _TriStateBoolState(
    text: '...',
    icon: Icons.pending,
  ),
  isTrue: _TriStateBoolState(
    text: 'wird geladen',
    icon: Icons.battery_charging_full,
  ),
  isFalse: _TriStateBoolState(
    text: 'wird nicht geladen',
    icon: Icons.battery_2_bar,
  ),
);

class _InGarageWidget extends _TriStateBoolWidget {
  _InGarageWidget({super.key, super.value})
      : super(
          title: 'Das Fahrzeug befindet sich',
          labels: _inGarageTriState,
        );
}

class _ChargingWidget extends _TriStateBoolWidget {
  _ChargingWidget({super.key, super.value})
      : super(
          title: 'Die Batterie',
          labels: _chargingTriState,
        );
}

class _VBatWidget extends _DoubleValueWidget {
  _VBatWidget({required super.value})
      : super(
          title: 'Batteriespannung',
          unit: 'V',
          digits: 1,
          icon: Icons.battery_full,
        );
}

class _VBatDeltaWidget extends _DoubleValueWidget {
  _VBatDeltaWidget({required super.value})
      : super(
          title: 'Ladungsveränderung',
          unit: 'V/t',
          digits: 1,
          icon: Icons.battery_3_bar,
        );
}

class _RssiWidget extends _DoubleValueWidget {
  const _RssiWidget({required super.value})
      : super(
          title: 'Signalstärke Basisstation',
          onNoValue: 'Kein Empfang',
          unit: 'dB',
          digits: 0,
          icon: value != null ? Icons.wifi : Icons.wifi_2_bar,
        );
}

class _DoubleValueWidget extends StatelessWidget {
  const _DoubleValueWidget({
    super.key,
    required this.title,
    required this.icon,
    this.value,
    required this.unit,
    required this.digits,
    this.onNoValue,
  });

  final String title;
  final IconData icon;
  final double? value;
  final String unit;
  final int digits;
  final String? onNoValue;

  String _value() {
    if (value == null) return onNoValue ?? '-';
    return '${value!.toStringAsFixed(digits)} $unit';
  }

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(title),
        subtitle: Text(_value()),
        leading: Icon(icon),
      );
}

class _TriStateBoolWidget extends StatelessWidget {
  const _TriStateBoolWidget(
      {super.key, required this.title, required this.labels, this.value});

  final String title;
  final _TriStateBool labels;
  final bool? value;

  _TriStateBoolState _state() {
    if (value == null) return labels.unknown;
    return value! ? labels.isTrue : labels.isFalse;
  }

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(title),
        subtitle: Text(_state().text),
        leading: Icon(_state().icon),
      );
}

class _TriStateBool {
  _TriStateBool(
      {required this.unknown, required this.isTrue, required this.isFalse});

  final _TriStateBoolState unknown;
  final _TriStateBoolState isTrue;
  final _TriStateBoolState isFalse;
}

class _TriStateBoolState {
  _TriStateBoolState({required this.text, required this.icon});

  final String text;
  final IconData icon;
}

double? _lowRssiToNoValue(double? value) =>
    (value == null || value <= -100) ? null : value;
