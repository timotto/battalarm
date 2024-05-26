import 'dart:async';

import 'package:battery_alarm_app/device_client/ota_service.dart';
import 'package:battery_alarm_app/util/busy.dart';
import 'package:battery_alarm_app/device_client/config_service.dart';
import 'package:battery_alarm_app/device_client/status_service.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class DeviceClient {
  static final DeviceClient _sharedInstance = DeviceClient._();

  factory DeviceClient() => _sharedInstance;

  DeviceClient._();

  final _busy = Busy();
  final _ble = FlutterReactiveBle();
  late StatusService statusService = StatusService(_busy);
  late ConfigService configService = ConfigService(_busy);
  late OtaService otaService = OtaService(_busy);

  final StreamController<ConnectionStateUpdate> _connectionStatusUpdate =
      StreamController.broadcast();

  StreamSubscription<ConnectionStateUpdate>? _connection;

  Stream<ConnectionStateUpdate> get connectionStatusUpdate => _connectionStatusUpdate.stream;

  BusySource get busy => _busy;

  Future<void> connect(String address) async {
    await disconnect();
    print('device-client: connect');
    _connection =
        _ble.connectToDevice(id: address, connectionTimeout: const Duration(seconds: 5)).listen(_onConnectionStatusUpdate);
  }

  Future<void> disconnect() async {
    print('device-client: disconnect');
    await _connection?.cancel();
    statusService.onDeviceDisconnected();
    configService.onDeviceDisconnected();
    otaService.onDeviceDisconnected();
  }

  void _onConnectionStatusUpdate(ConnectionStateUpdate update) {
    print('device-client: on-connection-status-update: $update');
    _connectionStatusUpdate.add(update);

    switch (update.connectionState) {
      case DeviceConnectionState.connected:
        _onConnection(update.deviceId);
        break;

      default:
        break;
    }
  }

  void _onConnection(String deviceId) async {
    await statusService.onDeviceConnected(deviceId);
    await configService.onDeviceConnected(deviceId);
    await otaService.onDeviceConnected(deviceId);
  }
}
