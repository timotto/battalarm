import 'dart:async';

import 'package:battery_alarm_app/device_client/config_service.dart';
import 'package:battery_alarm_app/device_client/status_service.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class DeviceClient {
  final _ble = FlutterReactiveBle();
  final StatusService statusService = StatusService();
  final ConfigService configService = ConfigService();

  final StreamController<ConnectionStateUpdate> _connectionStatusUpdate =
      StreamController.broadcast();

  StreamSubscription<ConnectionStateUpdate>? _connection;

  Stream<ConnectionStateUpdate> get connectionStatusUpdate => _connectionStatusUpdate.stream;

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

  void _onConnection(String deviceId) {
    statusService.onDeviceConnected(deviceId);
    configService.onDeviceConnected(deviceId);
  }
}
