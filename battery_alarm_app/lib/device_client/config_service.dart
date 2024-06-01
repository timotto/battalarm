import 'dart:async';

import 'package:battery_alarm_app/device_client/object_characteristic.dart';
import 'package:battery_alarm_app/model/bt_uuid.dart';
import 'package:battery_alarm_app/model/config.dart';
import 'package:battery_alarm_app/util/busy.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

final Uuid _uuidChrDelayWarn =
    Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870201');
final Uuid _uuidChrDelayAlert =
    Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870202');
final Uuid _uuidChrSnoozeTime =
    Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870203');
final Uuid _uuidChrVbatLpF = Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870211');
final Uuid _uuidChrVbatChargeT =
    Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870212');
final Uuid _uuidChrVbatDeltaT =
    Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870213');
final Uuid _uuidChrVbatTuneF =
    Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870214');
final Uuid _uuidChrVbatAlternatorT =
    Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870215');
final Uuid _uuidChrBtBeaconAddr =
    Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870221');
final Uuid _uuidChrBtRssiT = Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870222');
final Uuid _uuidChrBtRssiAutoTune =
    Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870223');
final Uuid _uuidChrBuzzerAlerts =
    Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870231');

class ConfigService {
  ConfigService(this.busy);

  DeviceConfig _state = DeviceConfig();

  final StreamController<DeviceConfig> _stateController =
      StreamController.broadcast();

  Stream<DeviceConfig> get deviceConfig => _stateController.stream;

  DeviceConfig get deviceConfigSnapshot => _state;

  final BusyRunner busy;

  ObjectCharacteristicFactory<DeviceConfig>? _ocf;

  Future<void> onDeviceConnected(String deviceId) async {
    _ocf = ObjectCharacteristicFactory<DeviceConfig>(
      deviceId: deviceId,
      serviceUuid: uuidConfigService,
      listenFn: _updateConfigValue,
    )..forDuration(
        chrId: _uuidChrDelayWarn,
        readFn: (c) => c.delayWarn,
        writeFn: (c, v) => c.delayWarn = v,
      )
          .forDuration(
            chrId: _uuidChrDelayAlert,
            readFn: (c) => c.delayAlarm,
            writeFn: (c, v) => c.delayAlarm = v,
          )
          .forDuration(
            chrId: _uuidChrSnoozeTime,
            readFn: (c) => c.snoozeTime,
            writeFn: (c, v) => c.snoozeTime = v,
          )
          .forDouble(
            chrId: _uuidChrVbatLpF,
            readFn: (c) => c.vbatLpF,
            writeFn: (c, v) => c.vbatLpF = v,
            digits: 4,
          )
          .forDouble(
            chrId: _uuidChrVbatChargeT,
            readFn: (c) => c.vbatChargeThreshold,
            writeFn: (c, v) => c.vbatChargeThreshold = v,
            digits: 1,
          )
          .forDouble(
            chrId: _uuidChrVbatAlternatorT,
            readFn: (c) => c.vbatAlternatorThreshold,
            writeFn: (c, v) => c.vbatAlternatorThreshold = v,
            digits: 1,
          )
          .forDouble(
            chrId: _uuidChrVbatDeltaT,
            readFn: (c) => c.vbatDeltaThreshold,
            writeFn: (c, v) => c.vbatDeltaThreshold = v,
            digits: 2,
          )
          .forDouble(
            chrId: _uuidChrVbatTuneF,
            readFn: (c) => c.vbatTuneFactor,
            writeFn: (c, v) => c.vbatTuneFactor = v,
            digits: 2,
          )
          .forString(
            chrId: _uuidChrBtBeaconAddr,
            readFn: (c) => c.btBeaconAddress,
            writeFn: (c, v) => c.btBeaconAddress = v,
          )
          .forDouble(
            chrId: _uuidChrBtRssiT,
            readFn: (c) => c.btRssiThreshold,
            writeFn: (c, v) => c.btRssiThreshold = v,
            digits: 0,
            subscribe: true,
          )
          .forBool(
            chrId: _uuidChrBtRssiAutoTune,
            readFn: (c) => c.btRssiAutoTune,
            writeFn: (c, v) => c.btRssiAutoTune = v,
          )
          .forInt(
            chrId: _uuidChrBuzzerAlerts,
            readFn: (c) => BuzzerAlerts.format(c.buzzerAlerts),
            writeFn: (c, v) => c.buzzerAlerts = BuzzerAlerts.parse(v),
          );

    await readAll();
    _ocf?.subscribe();
  }

  void onDeviceDisconnected() {
    _state = DeviceConfig();
    _stateController.add(_state);
    _ocf?.clear();
    _ocf = null;
  }

  Future<void> update(DeviceConfig update) async {
    await busy.run(() async {
      await _ocf?.writeIfChanged(_state, update);
    });

    _state = update;
    _stateController.add(_state);
  }

  Future<void> readAll() async {
    await busy.run(() async => await _ocf?.read());
  }

  Future<void> _updateConfigValue(
      Future<void> Function(DeviceConfig update) fn) async {
    final cpy = _state.clone();
    await fn(cpy);
    _state = cpy;
    _stateController.add(_state);
  }
}
