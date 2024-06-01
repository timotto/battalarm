import 'package:battery_alarm_app/device_client/value_characteristic.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class ObjectCharacteristic<T, V> {
  ObjectCharacteristic({
    required this.chr,
    required this.readFn,
    required this.writeFn,
    this.listenFn,
    bool? subscribe,
  }) : _subscribe = subscribe ?? false;

  final ValueCharacteristic<T> chr;
  final ObjectReadFn<T, V> readFn;
  final ObjectWriteFn<T, V> writeFn;
  final ObjectListenerFn<V>? listenFn;
  final bool _subscribe;

  Future<void> writeIfChanged(V reference, V update) async {
    final refVal = readFn(reference);
    final upVal = readFn(update);

    if (upVal == null) return;
    if (upVal == refVal) return;

    await chr.write(upVal);
  }

  Future<void> read(V target) async {
    final val = await chr.read();
    writeFn(target, val);
  }

  void subscribe() {
    if (!_subscribe || listenFn == null) return;
    chr.subscribe(
        (value) => listenFn!((update) async => writeFn(update, value)));
  }
}

typedef ObjectReadFn<T, V> = T? Function(V);

typedef ObjectWriteFn<T, V> = void Function(V, T?);

typedef ObjectListenerFn<V> = Future<void> Function(Future<void> Function(V));

class ObjectCharacteristicFactory<V> {
  final String deviceId;
  final Uuid serviceUuid;
  final ObjectListenerFn<V> listenFn;
  final bool _subscribeAll;
  final List<ObjectCharacteristic> _characteristics = [];

  ObjectCharacteristicFactory({
    required this.deviceId,
    required this.serviceUuid,
    required this.listenFn,
    bool? subscribeAll,
  }) : _subscribeAll = subscribeAll ?? false;

  void clear() {
    _characteristics.clear();
  }

  Future<void> read() async {
    await listenFn((target) async {
      for (var chr in _characteristics) {
        await chr.read(target);
      }
    });
  }

  Future<void> writeIfChanged(V reference, V update) async {
    for (var chr in _characteristics) {
      await chr.writeIfChanged(reference, update);
    }
  }

  void subscribe() {
    for (var chr in _characteristics) {
      chr.subscribe();
    }
  }

  ObjectCharacteristicFactory<V> forDuration({
    required Uuid chrId,
    required ObjectReadFn<Duration, V> readFn,
    required ObjectWriteFn<Duration, V> writeFn,
    bool? subscribe,
  }) {
    _characteristics.add(ObjectCharacteristic<Duration, V>(
      chr: DurationCharacteristic(
        deviceId: deviceId,
        serviceId: serviceUuid,
        characteristicId: chrId,
      ),
      readFn: readFn,
      writeFn: writeFn,
      listenFn: listenFn,
      subscribe: subscribe ?? _subscribeAll,
    ));

    return this;
  }

  ObjectCharacteristicFactory<V> forDouble({
    required Uuid chrId,
    required ObjectReadFn<double, V> readFn,
    required ObjectWriteFn<double, V> writeFn,
    bool? subscribe,
    required int digits,
  }) {
    _characteristics.add(ObjectCharacteristic<double, V>(
      chr: DoubleCharacteristic(
        deviceId: deviceId,
        serviceId: serviceUuid,
        characteristicId: chrId,
        digits: digits,
      ),
      readFn: readFn,
      writeFn: writeFn,
      listenFn: listenFn,
      subscribe: subscribe ?? _subscribeAll,
    ));

    return this;
  }

  ObjectCharacteristicFactory<V> forString({
    required Uuid chrId,
    required ObjectReadFn<String, V> readFn,
    required ObjectWriteFn<String, V> writeFn,
    bool? subscribe,
  }) {
    _characteristics.add(ObjectCharacteristic<String, V>(
      chr: StringCharacteristic(
        deviceId: deviceId,
        serviceId: serviceUuid,
        characteristicId: chrId,
      ),
      readFn: readFn,
      writeFn: writeFn,
      listenFn: listenFn,
      subscribe: subscribe ?? _subscribeAll,
    ));

    return this;
  }

  ObjectCharacteristicFactory<V> forBool({
    required Uuid chrId,
    required ObjectReadFn<bool, V> readFn,
    required ObjectWriteFn<bool, V> writeFn,
    bool? subscribe,
  }) {
    _characteristics.add(ObjectCharacteristic<bool, V>(
      chr: BoolCharacteristic(
        deviceId: deviceId,
        serviceId: serviceUuid,
        characteristicId: chrId,
      ),
      readFn: readFn,
      writeFn: writeFn,
      listenFn: listenFn,
      subscribe: subscribe ?? _subscribeAll,
    ));

    return this;
  }

  ObjectCharacteristicFactory<V> forInt({
    required Uuid chrId,
    required ObjectReadFn<int, V> readFn,
    required ObjectWriteFn<int, V> writeFn,
    bool? subscribe,
  }) {
    _characteristics.add(ObjectCharacteristic<int, V>(
      chr: IntCharacteristic(
        deviceId: deviceId,
        serviceId: serviceUuid,
        characteristicId: chrId,
      ),
      readFn: readFn,
      writeFn: writeFn,
      listenFn: listenFn,
      subscribe: subscribe ?? _subscribeAll,
    ));

    return this;
  }
}
