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
      await _subscribeAndRead2(_chrInGarage, _onInGarage);
      await _subscribeAndRead2(_chrCharging, _onCharging);
      await _subscribeAndRead2(_chrVbatVolt, _onVbat);
      await _subscribeAndRead2(_chrVbatDelta, _onVbatDelta);
      await _subscribeAndRead2(_chrBeaconRssi, _onRssi);
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

  Future<void> _subscribeAndRead2<T>(
      ValueCharacteristic<T>? chr, void Function(T?) onData) async {
    if (chr == null) return;
    chr.subscribe(onData);
    onData(await chr.read());
  }

  void _onInGarage(bool? value) {
    _updateState(DeviceStatus(
        inGarage: value,
        charging: _state.charging,
        vbat: _state.vbat,
        vbatDelta: _state.vbatDelta,
        rssi: _state.rssi));
  }

  void _onCharging(bool? value) {
    _updateState(DeviceStatus(
        inGarage: _state.inGarage,
        charging: value,
        vbat: _state.vbat,
        vbatDelta: _state.vbatDelta,
        rssi: _state.rssi));
  }

  void _onVbat(double? value) {
    _updateState(DeviceStatus(
        inGarage: _state.inGarage,
        charging: _state.charging,
        vbat: value,
        vbatDelta: _state.vbatDelta,
        rssi: _state.rssi));
  }

  void _onVbatDelta(double? value) {
    _updateState(DeviceStatus(
        inGarage: _state.inGarage,
        charging: _state.charging,
        vbat: _state.vbat,
        vbatDelta: value,
        rssi: _state.rssi));
  }

  void _onRssi(double? value) {
    _updateState(DeviceStatus(
        inGarage: _state.inGarage,
        charging: _state.charging,
        vbat: _state.vbat,
        vbatDelta: _state.vbatDelta,
        rssi: value));
  }
}
