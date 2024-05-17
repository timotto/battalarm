import 'dart:async';

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
  final _ble = FlutterReactiveBle();

  DeviceStatus _state = DeviceStatus();
  final StreamController<DeviceStatus> _stateController = StreamController.broadcast();

  Stream<DeviceStatus> get deviceStatus => _stateController.stream;

  DeviceStatus get deviceStatusSnapshot => _state;

  QualifiedCharacteristic? _chrInGarage;
  QualifiedCharacteristic? _chrCharging;
  QualifiedCharacteristic? _chrVbatVolt;
  QualifiedCharacteristic? _chrVbatDelta;
  QualifiedCharacteristic? _chrBeaconRssi;

  void onDeviceConnected(String deviceId) async {
    _chrInGarage = QualifiedCharacteristic(
        deviceId: deviceId,
        serviceId: uuidStatusService,
        characteristicId: _uuidChrInGarage);
    _chrCharging = QualifiedCharacteristic(
        deviceId: deviceId,
        serviceId: uuidStatusService,
        characteristicId: _uuidChrCharging);
    _chrVbatVolt = QualifiedCharacteristic(
        deviceId: deviceId,
        serviceId: uuidStatusService,
        characteristicId: _uuidChrVbatVolt);
    _chrVbatDelta = QualifiedCharacteristic(
        deviceId: deviceId,
        serviceId: uuidStatusService,
        characteristicId: _uuidChrVbatDelta);
    _chrBeaconRssi = QualifiedCharacteristic(
        deviceId: deviceId,
        serviceId: uuidStatusService,
        characteristicId: _uuidChrBeaconRssi);

    await _subscribeAndRead(
        _chrInGarage!, (event) => _onInGarage(_parseChrBool(event)));
    await _subscribeAndRead(
        _chrCharging!, (event) => _onCharging(_parseChrBool(event)));
    await _subscribeAndRead(
        _chrVbatVolt!, (event) => _onVbat(_parseChrDouble(event)));
    await _subscribeAndRead(
        _chrVbatDelta!, (event) => _onVbatDelta(_parseChrDouble(event)));
    await _subscribeAndRead(
        _chrBeaconRssi!, (event) => _onRssi(_parseChrDouble(event)));
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

  Future<void> _subscribeAndRead(
      QualifiedCharacteristic chr, void Function(List<int> event) onData) async {
    _ble.subscribeToCharacteristic(chr).listen(onData, cancelOnError: true);
    final data = await _ble.readCharacteristic(chr);
    onData(data);
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

bool? _parseChrBool(List<int> value) => value.isEmpty ? null : value[0] == 1;

double? _parseChrDouble(List<int> value) =>
    double.tryParse(String.fromCharCodes(value));
