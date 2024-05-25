import 'dart:async';

import 'package:battery_alarm_app/device_client/value_characteristic.dart';
import 'package:battery_alarm_app/util/busy.dart';
import 'package:battery_alarm_app/model/bt_uuid.dart';
import 'package:battery_alarm_app/model/config.dart';
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

  DurationCharacteristic? _chrDelayWarn;
  DurationCharacteristic? _chrDelayAlert;
  DurationCharacteristic? _chrSnoozeTime;

  DoubleCharacteristic? _chrVbatLpF;
  DoubleCharacteristic? _chrVbatChargeT;
  DoubleCharacteristic? _chrVbatAlternatorT;
  DoubleCharacteristic? _chrVbatDeltaT;
  DoubleCharacteristic? _chrVbatTuneF;

  StringCharacteristic? _chrBtBeaconAddr;
  DoubleCharacteristic? _chrBtBeaconRssiT;
  BoolCharacteristic? _chrBtBeaconRssiAutoTune;

  IntCharacteristic? _chrBuzzerAlerts;

  Future<void> onDeviceConnected(String deviceId) async {
    _chrDelayWarn = DurationCharacteristic(
      characteristicId: _uuidChrDelayWarn,
      serviceId: uuidConfigService,
      deviceId: deviceId,
    );

    _chrDelayAlert = DurationCharacteristic(
      characteristicId: _uuidChrDelayAlert,
      serviceId: uuidConfigService,
      deviceId: deviceId,
    );

    _chrSnoozeTime = DurationCharacteristic(
      characteristicId: _uuidChrSnoozeTime,
      serviceId: uuidConfigService,
      deviceId: deviceId,
    );

    _chrVbatLpF = DoubleCharacteristic(
      characteristicId: _uuidChrVbatLpF,
      serviceId: uuidConfigService,
      deviceId: deviceId,
      digits: 4,
    );

    _chrVbatChargeT = DoubleCharacteristic(
      characteristicId: _uuidChrVbatChargeT,
      serviceId: uuidConfigService,
      deviceId: deviceId,
      digits: 1,
    );

    _chrVbatAlternatorT = DoubleCharacteristic(
      characteristicId: _uuidChrVbatAlternatorT,
      serviceId: uuidConfigService,
      deviceId: deviceId,
      digits: 1,
    );

    _chrVbatDeltaT = DoubleCharacteristic(
      characteristicId: _uuidChrVbatDeltaT,
      serviceId: uuidConfigService,
      deviceId: deviceId,
      digits: 2,
    );

    _chrVbatTuneF = DoubleCharacteristic(
      characteristicId: _uuidChrVbatTuneF,
      serviceId: uuidConfigService,
      deviceId: deviceId,
      digits: 2,
    );

    _chrBtBeaconAddr = StringCharacteristic(
      characteristicId: _uuidChrBtBeaconAddr,
      serviceId: uuidConfigService,
      deviceId: deviceId,
    );

    _chrBtBeaconRssiT = DoubleCharacteristic(
      characteristicId: _uuidChrBtRssiT,
      serviceId: uuidConfigService,
      deviceId: deviceId,
      digits: 0,
    );

    _chrBtBeaconRssiAutoTune = BoolCharacteristic(
      characteristicId: _uuidChrBtRssiAutoTune,
      serviceId: uuidConfigService,
      deviceId: deviceId,
    );

    _chrBuzzerAlerts = IntCharacteristic(
      characteristicId: _uuidChrBuzzerAlerts,
      serviceId: uuidConfigService,
      deviceId: deviceId,
    );

    await readAll();
    _chrBtBeaconRssiT?.subscribe((value) => _onRssiThreshold(value));
  }

  void onDeviceDisconnected() {
    _state = DeviceConfig();
    _stateController.add(_state);
  }

  Future<void> update(DeviceConfig update) async {
    await busy.run(() async {
      await _writeIfChanged(
        _chrDelayWarn,
        _state.delayWarn,
        update.delayWarn,
      );
      await _writeIfChanged(
        _chrDelayAlert,
        _state.delayAlarm,
        update.delayAlarm,
      );
      await _writeIfChanged(
        _chrSnoozeTime,
        _state.snoozeTime,
        update.snoozeTime,
      );

      await _writeIfChanged(
        _chrVbatLpF,
        _state.vbatLpF,
        update.vbatLpF,
      );
      await _writeIfChanged(
        _chrVbatChargeT,
        _state.vbatChargeThreshold,
        update.vbatChargeThreshold,
      );
      await _writeIfChanged(
        _chrVbatAlternatorT,
        _state.vbatAlternatorThreshold,
        update.vbatAlternatorThreshold,
      );
      await _writeIfChanged(
        _chrVbatDeltaT,
        _state.vbatDeltaThreshold,
        update.vbatDeltaThreshold,
      );
      await _writeIfChanged(
        _chrVbatTuneF,
        _state.vbatTuneFactor,
        update.vbatTuneFactor,
      );

      await _writeIfChanged(
        _chrBtBeaconAddr,
        _state.btBeaconAddress,
        update.btBeaconAddress,
      );
      await _writeIfChanged(
        _chrBtBeaconRssiT,
        _state.btRssiThreshold,
        update.btRssiThreshold,
      );
      await _writeIfChanged(
        _chrBtBeaconRssiAutoTune,
        _state.btRssiAutoTune,
        update.btRssiAutoTune,
      );

      await _writeIfChanged(
          _chrBuzzerAlerts,
          _formatBuzzerAlerts(_state.buzzerAlerts),
          _formatBuzzerAlerts(update.buzzerAlerts));
    });

    _state = update;
    _stateController.add(_state);
  }

  Future<void> readAll() async {
    await busy.run(() async {
      _state = DeviceConfig(
        delayWarn: await _chrDelayWarn?.read(),
        delayAlarm: await _chrDelayAlert?.read(),
        snoozeTime: await _chrSnoozeTime?.read(),
        vbatLpF: await _chrVbatLpF?.read(),
        vbatChargeThreshold: await _chrVbatChargeT?.read(),
        vbatAlternatorThreshold: await _chrVbatAlternatorT?.read(),
        vbatDeltaThreshold: await _chrVbatDeltaT?.read(),
        vbatTuneFactor: await _chrVbatTuneF?.read(),
        btBeaconAddress: await _chrBtBeaconAddr?.read(),
        btRssiThreshold: await _chrBtBeaconRssiT?.read(),
        btRssiAutoTune: await _chrBtBeaconRssiAutoTune?.read(),
        buzzerAlerts: _parseBuzzerAlerts(await _chrBuzzerAlerts?.read()),
      );
    });

    _stateController.add(_state);
  }

  void _onRssiThreshold(double? value) {
    final clone = _state.clone();
    clone.btRssiThreshold = value;
    _state = clone;
    _stateController.add(_state);
  }

  Future<void> _writeIfChanged<T>(
      ValueCharacteristic<T>? chr, T? ref, T? update) async {
    if (chr == null) return;
    if (update == null) return;
    if (update == ref) return;

    await chr.write(update);
  }
}

Map<BuzzerAlerts, bool>? _parseBuzzerAlerts(int? value) => value == null
    ? null
    : <BuzzerAlerts, bool>{
        BuzzerAlerts.garage: (value & 1) != 0,
        BuzzerAlerts.charging: (value & 2) != 0,
        BuzzerAlerts.hello: (value & 4) != 0,
        BuzzerAlerts.button: (value & 8) != 0,
        BuzzerAlerts.bluetooth: (value & 16) != 0,
      };

int _formatBuzzerAlerts(Map<BuzzerAlerts, bool>? values) =>
    _boolToBitValue(values?[BuzzerAlerts.garage], 0) |
    _boolToBitValue(values?[BuzzerAlerts.charging], 1) |
    _boolToBitValue(values?[BuzzerAlerts.hello], 2) |
    _boolToBitValue(values?[BuzzerAlerts.button], 3) |
    _boolToBitValue(values?[BuzzerAlerts.bluetooth], 4);

int _boolToBitValue(bool? value, int bit) => ((value ?? false) ? 1 : 0) << bit;
