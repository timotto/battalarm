import 'dart:async';

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
final Uuid _uuidChrBtBeaconAddr =
    Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870221');
final Uuid _uuidChrBtRssiT = Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870222');
final Uuid _uuidChrBtRssiAutoTune =
    Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870223');
final Uuid _uuidChrBuzzerAlerts =
    Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870231');

class ConfigService {
  ConfigService(this.busy);

  final _ble = FlutterReactiveBle();

  DeviceConfig _state = DeviceConfig();
  final StreamController<DeviceConfig> _stateController =
      StreamController.broadcast();

  Stream<DeviceConfig> get deviceConfig => _stateController.stream;

  DeviceConfig get deviceConfigSnapshot => _state;

  final BusyRunner busy;

  QualifiedCharacteristic? _chrDelayWarn;
  QualifiedCharacteristic? _chrDelayAlert;
  QualifiedCharacteristic? _chrSnoozeTime;

  QualifiedCharacteristic? _chrVbatLpF;
  QualifiedCharacteristic? _chrVbatChargeT;
  QualifiedCharacteristic? _chrVbatDeltaT;

  QualifiedCharacteristic? _chrBtBeaconAddr;
  QualifiedCharacteristic? _chrBtBeaconRssiT;
  QualifiedCharacteristic? _chrBtBeaconRssiAutoTune;

  QualifiedCharacteristic? _chrBuzzerAlerts;

  Future<void> onDeviceConnected(String deviceId) async {
    _chrDelayWarn = QualifiedCharacteristic(
      characteristicId: _uuidChrDelayWarn,
      serviceId: uuidConfigService,
      deviceId: deviceId,
    );

    _chrDelayAlert = QualifiedCharacteristic(
      characteristicId: _uuidChrDelayAlert,
      serviceId: uuidConfigService,
      deviceId: deviceId,
    );

    _chrSnoozeTime = QualifiedCharacteristic(
      characteristicId: _uuidChrSnoozeTime,
      serviceId: uuidConfigService,
      deviceId: deviceId,
    );

    _chrVbatLpF = QualifiedCharacteristic(
      characteristicId: _uuidChrVbatLpF,
      serviceId: uuidConfigService,
      deviceId: deviceId,
    );

    _chrVbatChargeT = QualifiedCharacteristic(
      characteristicId: _uuidChrVbatChargeT,
      serviceId: uuidConfigService,
      deviceId: deviceId,
    );

    _chrVbatDeltaT = QualifiedCharacteristic(
      characteristicId: _uuidChrVbatDeltaT,
      serviceId: uuidConfigService,
      deviceId: deviceId,
    );

    _chrBtBeaconAddr = QualifiedCharacteristic(
      characteristicId: _uuidChrBtBeaconAddr,
      serviceId: uuidConfigService,
      deviceId: deviceId,
    );

    _chrBtBeaconRssiT = QualifiedCharacteristic(
      characteristicId: _uuidChrBtRssiT,
      serviceId: uuidConfigService,
      deviceId: deviceId,
    );

    _chrBtBeaconRssiAutoTune = QualifiedCharacteristic(
      characteristicId: _uuidChrBtRssiAutoTune,
      serviceId: uuidConfigService,
      deviceId: deviceId,
    );

    _chrBuzzerAlerts = QualifiedCharacteristic(
      characteristicId: _uuidChrBuzzerAlerts,
      serviceId: uuidConfigService,
      deviceId: deviceId,
    );

    await readAll();
    _ble.subscribeToCharacteristic(_chrBtBeaconRssiT!).listen(
          (event) => _onRssiThreshold(_parseChrDouble(event)),
          cancelOnError: true,
        );
  }

  void onDeviceDisconnected() {
    _state = DeviceConfig();
    _stateController.add(_state);
  }

  Future<void> update(DeviceConfig update) async {
    await busy.run(() async {
      await _writeIfChanged(_chrDelayWarn, _state.delayWarn, update.delayWarn,
          _formatChrMsDuration);
      await _writeIfChanged(_chrDelayAlert, _state.delayAlarm,
          update.delayAlarm, _formatChrMsDuration);
      await _writeIfChanged(_chrSnoozeTime, _state.snoozeTime,
          update.snoozeTime, _formatChrMsDuration);

      await _writeIfChanged(
          _chrVbatLpF, _state.vbatLpF, update.vbatLpF, _formatChrDouble(4));
      await _writeIfChanged(_chrVbatChargeT, _state.vbatChargeThreshold,
          update.vbatChargeThreshold, _formatChrDouble(1));
      await _writeIfChanged(_chrVbatDeltaT, _state.vbatDeltaThreshold,
          update.vbatDeltaThreshold, _formatChrDouble(2));

      await _writeIfChanged(_chrBtBeaconAddr, _state.btBeaconAddress,
          update.btBeaconAddress, _formatChrString);
      await _writeIfChanged(_chrBtBeaconRssiT, _state.btRssiThreshold,
          update.btRssiThreshold, _formatChrDouble(0));
      await _writeIfChanged(_chrBtBeaconRssiAutoTune, _state.btRssiAutoTune,
          update.btRssiAutoTune, _formatChrBool);

      await _writeIfChanged(
          _chrBuzzerAlerts,
          _formatBuzzerAlerts(_state.buzzerAlerts),
          _formatBuzzerAlerts(update.buzzerAlerts),
          _formatChrUInt32);
    });

    _state = update;
    _stateController.add(_state);
  }

  Future<void> readAll() async {
    await busy.run(() async {
      _state = DeviceConfig(
        delayWarn: await _readChrIntMsDuration(_chrDelayWarn),
        delayAlarm: await _readChrIntMsDuration(_chrDelayAlert),
        snoozeTime: await _readChrIntMsDuration(_chrSnoozeTime),
        vbatLpF: await _readChrDouble(_chrVbatLpF),
        vbatChargeThreshold: await _readChrDouble(_chrVbatChargeT),
        vbatDeltaThreshold: await _readChrDouble(_chrVbatDeltaT),
        btBeaconAddress: await _readChrString(_chrBtBeaconAddr),
        btRssiThreshold: await _readChrDouble(_chrBtBeaconRssiT),
        btRssiAutoTune: await _readChrBool(_chrBtBeaconRssiAutoTune),
        buzzerAlerts: _parseBuzzerAlerts(await _readChrInt(_chrBuzzerAlerts)),
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

  Future<bool?> _readChrBool(QualifiedCharacteristic? chr) async =>
      chr == null ? null : _parseChrBool(await _ble.readCharacteristic(chr));

  Future<double?> _readChrDouble(QualifiedCharacteristic? chr) async =>
      chr == null ? null : _parseChrDouble(await _ble.readCharacteristic(chr));

  Future<int?> _readChrInt(QualifiedCharacteristic? chr) async =>
      chr == null ? null : _parseChrInt(await _ble.readCharacteristic(chr));

  Future<Duration?> _readChrIntMsDuration(QualifiedCharacteristic? chr) async {
    final ms = await _readChrInt(chr);

    if (ms == null) return null;
    return Duration(milliseconds: ms);
  }

  Future<String?> _readChrString(QualifiedCharacteristic? chr) async =>
      chr == null
          ? null
          : String.fromCharCodes(await _ble.readCharacteristic(chr));

  Future<void> _writeIfChanged<T>(QualifiedCharacteristic? chr, T? ref,
      T? update, List<int> Function(T) formatFn) async {
    if (chr == null) return;
    if (update == null) return;
    if (update == ref) return;

    await _ble.writeCharacteristicWithResponse(chr, value: formatFn(update));
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

bool? _parseChrBool(List<int> value) => value.isEmpty ? null : value[0] == 1;

double? _parseChrDouble(List<int> value) =>
    double.tryParse(String.fromCharCodes(value));

int? _parseChrInt(List<int> values) => values.isEmpty
    ? null
    : values.indexed.map((e) => e.$2 << (8 * e.$1)).reduce((a, b) => a + b);

List<int> _formatChrMsDuration(Duration value) =>
    _formatChrUInt32(value.inMilliseconds);

List<int> _formatChrUInt32(int value) {
  final List<int> result = [];

  result.add(value & 0xff);

  value = value >> 8;
  result.add(value & 0xff);

  value = value >> 8;
  result.add(value & 0xff);

  value = value >> 8;
  result.add(value & 0xff);

  return result;
}

List<int> Function(double value) _formatChrDouble(int digits) =>
    (value) => value.toStringAsFixed(digits).codeUnits;

List<int> _formatChrString(String value) => value.codeUnits;

List<int> _formatChrBool(bool value) => [value ? 1 : 0];
