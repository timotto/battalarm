import 'dart:async';

import 'package:battery_alarm_app/ota/model.dart';
import 'package:battery_alarm_app/model/version.dart';
import 'package:battery_alarm_app/ota/writer_service.dart';
import 'package:battery_alarm_app/util/busy.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

final Uuid _uuidOtaService = Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870300');
final Uuid _uuidChrVersion = Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870301');
final Uuid _uuidChrD2u = Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870311');
final Uuid _uuidChrU2d = Uuid.parse('106145DE-E2DA-435D-A093-C8C5CA870312');

class OtaService {
  OtaService(this.busy);

  final _ble = FlutterReactiveBle();
  final BusyRunner busy;
  final _versionController = StreamController<Version?>.broadcast();

  String? _deviceId;
  QualifiedCharacteristic? _chrVersion;
  QualifiedCharacteristic? _chrD2u;
  QualifiedCharacteristic? _chrU2d;
  Version? _version;

  Stream<Version?> get versionStream => _versionController.stream;

  Version? get version => _version;

  Future<void> onDeviceConnected(String deviceId) async {
    _deviceId = deviceId;

    _chrVersion = QualifiedCharacteristic(
      characteristicId: _uuidChrVersion,
      serviceId: _uuidOtaService,
      deviceId: deviceId,
    );
    _chrD2u = QualifiedCharacteristic(
      characteristicId: _uuidChrD2u,
      serviceId: _uuidOtaService,
      deviceId: deviceId,
    );
    _chrU2d = QualifiedCharacteristic(
      characteristicId: _uuidChrU2d,
      serviceId: _uuidOtaService,
      deviceId: deviceId,
    );

    _version = await readVersion();
    _versionController.add(_version);
  }

  void onDeviceDisconnected() {
    _chrVersion = null;
    _chrD2u = null;
    _chrU2d = null;
  }

  Future<Version?> readVersion() async {
    if (_chrVersion == null) {
      print('ota-service::read-version: no characteristic');
      return null;
    }
    return await busy.run(() async {
      try {
        final value = await _ble.readCharacteristic(_chrVersion!);
        return Version.parse(String.fromCharCodes(value));
      } catch (e) {
        print('ota-service::read-version: exception: $e');
        return null;
      }
    });
  }

  OtaWriter? writeFirmware(OtaArtifact artifact) {
    if (_deviceId == null) return null;
    if (_chrU2d == null) return null;
    if (_chrD2u == null) return null;

    return OtaWriter(
      deviceId: _deviceId!,
      u2d: _chrU2d!,
      d2u: _chrD2u!,
      artifact: artifact,
    );
  }
}
