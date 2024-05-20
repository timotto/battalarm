import 'dart:async';

import 'package:battery_alarm_app/device_client/value_characteristic.dart';
import 'package:battery_alarm_app/util/busy.dart';
import 'package:battery_alarm_app/model/bt_uuid.dart';
import 'package:battery_alarm_app/model/status.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

final Uuid _uuidChrInGarage =
    Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870101');
final Uuid _uuidChrCharging =
    Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870102');
final Uuid _uuidChrVbatVolt =
    Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870111');
final Uuid _uuidChrVbatDelta =
    Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870112');
final Uuid _uuidChrBeaconRssi =
    Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870121');

class StatusService {
  StatusService(this.busy);

  DeviceStatus _state = DeviceStatus();

  final StreamController<DeviceStatus> _stateController =
      StreamController.broadcast();

  Stream<DeviceStatus> get deviceStatus => _stateController.stream;

  DeviceStatus get deviceStatusSnapshot => _state;

  final BusyRunner busy;

  BoolCharacteristic? _chrInGarage;
  BoolCharacteristic? _chrCharging;
  DoubleCharacteristic? _chrVbatVolt;
  DoubleCharacteristic? _chrVbatDelta;
  DoubleCharacteristic? _chrBeaconRssi;

  Future<void> onDeviceConnected(String deviceId) async {
    _chrInGarage = BoolCharacteristic(
      deviceId: deviceId,
      serviceId: uuidStatusService,
      characteristicId: _uuidChrInGarage,
    );
    _chrCharging = BoolCharacteristic(
      deviceId: deviceId,
      serviceId: uuidStatusService,
      characteristicId: _uuidChrCharging,
    );
    _chrVbatVolt = DoubleCharacteristic(
      deviceId: deviceId,
      serviceId: uuidStatusService,
      characteristicId: _uuidChrVbatVolt,
      digits: 1,
    );
    _chrVbatDelta = DoubleCharacteristic(
      deviceId: deviceId,
      serviceId: uuidStatusService,
      characteristicId: _uuidChrVbatDelta,
      digits: 2,
    );
    _chrBeaconRssi = DoubleCharacteristic(
      deviceId: deviceId,
      serviceId: uuidStatusService,
      characteristicId: _uuidChrBeaconRssi,
      digits: 0,
    );

    await busy.run(() async {
      await _subscribeAndRead(
        _chrInGarage,
        (value) => _updateStateValue((update) => update.inGarage = value),
      );
      await _subscribeAndRead(
        _chrCharging,
        (value) => _updateStateValue((update) => update.charging = value),
      );
      await _subscribeAndRead(
        _chrVbatVolt,
        (value) => _updateStateValue((update) => update.vbat = value),
      );
      await _subscribeAndRead(
        _chrVbatDelta,
        (value) => _updateStateValue((update) => update.vbatDelta = value),
      );
      await _subscribeAndRead(
        _chrBeaconRssi,
        (value) => _updateStateValue((update) => update.rssi = value),
      );
    });
  }

  void onDeviceDisconnected() {
    _chrInGarage = null;
    _chrCharging = null;
    _chrVbatVolt = null;
    _chrVbatDelta = null;
    _chrBeaconRssi = null;

    _updateState(DeviceStatus());
  }

  void _updateState(DeviceStatus state) {
    _state = state;
    _stateController.add(state);
  }

  void _updateStateValue(void Function(DeviceStatus update) fn) {
    final cpy = _state.clone();
    fn(cpy);
    _updateState(cpy);
  }

  Future<void> _subscribeAndRead<T>(
      ValueCharacteristic<T>? chr, void Function(T?) onData) async {
    if (chr == null) return;
    chr.subscribe(onData);
    onData(await chr.read());
  }
}
