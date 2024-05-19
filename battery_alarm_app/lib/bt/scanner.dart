import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleScanner {
  static final BleScanner _sharedInstance = BleScanner._();

  factory BleScanner() => _sharedInstance;

  BleScanner._();

  final _ble = FlutterReactiveBle();

  final StreamController<BleScannerState> _stateStreamController =
      StreamController.broadcast();

  BleScannerState _stateSnapshot = BleScannerState.empty();

  final _devices = <DiscoveredDevice>[];

  StreamSubscription? _subscription;

  Stream<BleScannerState> get state => _stateStreamController.stream;

  BleScannerState get stateSnapshot => _stateSnapshot;

  Future<void> dispose() async {
    await _stateStreamController.close();
  }

  void startScan(List<Uuid> serviceIds) {
    _devices.clear();
    _subscription?.cancel();
    _subscription =
        _ble.scanForDevices(withServices: serviceIds, scanMode: ScanMode.lowLatency).listen((device) {
      final knownDeviceIndex = _devices.indexWhere((d) => d.id == device.id);
      if (knownDeviceIndex >= 0) {
        _devices[knownDeviceIndex] = device;
      } else {
        _devices.add(device);
      }
      _pushState();
    }, onError: (Object e) => print('Device scan fails with error: $e'));
    _pushState();
  }

  Future<void> stopScan() async {
    await _subscription?.cancel();
    _subscription = null;
    _pushState();
  }

  void _pushState() {
    final state = BleScannerState(
      discoveredDevices: _devices,
      scanIsInProgress: _subscription != null,
    );
    _stateSnapshot = state;
    _stateStreamController.add(state);
  }
}

@immutable
class BleScannerState {
  const BleScannerState({
    required this.discoveredDevices,
    required this.scanIsInProgress,
  });

  static BleScannerState empty() => const BleScannerState(
        discoveredDevices: [],
        scanIsInProgress: false,
      );

  final List<DiscoveredDevice> discoveredDevices;
  final bool scanIsInProgress;
}
