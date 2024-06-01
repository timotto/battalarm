import 'dart:async';

import 'package:battery_alarm_app/device_client/object_characteristic.dart';
import 'package:battery_alarm_app/model/bt_uuid.dart';
import 'package:battery_alarm_app/model/status.dart';
import 'package:battery_alarm_app/util/busy.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

final Uuid _uuidChrInGarage =
    Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870101');
final Uuid _uuidChrCharging =
    Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870102');
final Uuid _uuidChrEngineRunning =
    Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870103');
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

  ObjectCharacteristicFactory<DeviceStatus>? _ocf;

  Future<void> onDeviceConnected(String deviceId) async {
    _ocf = ObjectCharacteristicFactory(
      deviceId: deviceId,
      serviceUuid: uuidStatusService,
      listenFn: _updateStateValue,
      subscribeAll: true,
    )..forBool(
        chrId: _uuidChrInGarage,
        readFn: (v) => v.inGarage,
        writeFn: (v, t) => v.inGarage = t,
      )
          .forBool(
            chrId: _uuidChrCharging,
            readFn: (v) => v.charging,
            writeFn: (v, t) => v.charging = t,
          )
          .forBool(
            chrId: _uuidChrEngineRunning,
            readFn: (v) => v.engineRunning,
            writeFn: (v, t) => v.engineRunning = t,
          )
          .forDouble(
            chrId: _uuidChrVbatVolt,
            readFn: (v) => v.vbat,
            writeFn: (v, t) => v.vbat = t,
            digits: 1,
          )
          .forDouble(
            chrId: _uuidChrVbatDelta,
            readFn: (v) => v.vbatDelta,
            writeFn: (v, t) => v.vbatDelta = t,
            digits: 2,
          )
          .forDouble(
            chrId: _uuidChrBeaconRssi,
            readFn: (v) => v.rssi,
            writeFn: (v, t) => v.rssi = _beaconRssiValueGuard(t),
            digits: 0,
          );

    await busy.run(() async {
      _ocf?.subscribe();
      await _ocf?.read();
    });
  }

  void onDeviceDisconnected() {
    _ocf?.clear();
    _ocf = null;

    _updateState(DeviceStatus());
  }

  void _updateState(DeviceStatus state) {
    _state = state;
    _stateController.add(state);
  }

  Future<void> _updateStateValue(
      Future<void> Function(DeviceStatus update) fn) async {
    final cpy = _state.clone();
    await fn(cpy);
    _updateState(cpy);
  }
}

double? _beaconRssiValueGuard(double? value) =>
    value == null || value <= -100 ? null : value;
