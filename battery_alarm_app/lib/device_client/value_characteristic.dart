import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class ValueCharacteristic<T> {
  ValueCharacteristic({
    required Uuid characteristicId,
    required Uuid serviceId,
    required String deviceId,
    required CharacteristicReadFunction<T> readFn,
    required CharacteristicWriteFunction<T> writeFn,
  })  : _characteristic = QualifiedCharacteristic(
          characteristicId: characteristicId,
          serviceId: serviceId,
          deviceId: deviceId,
        ),
        _readFn = readFn,
        _writeFn = writeFn;

  final _ble = FlutterReactiveBle();

  final QualifiedCharacteristic _characteristic;
  final CharacteristicReadFunction<T> _readFn;
  final CharacteristicWriteFunction<T> _writeFn;

  Future<T?> read() async {
    try {
      return _readFn(await _ble.readCharacteristic(_characteristic));
    } catch (_) {
      return null;
    }
  }

  Future<bool> write(T value) async {
    try {
      await _ble.writeCharacteristicWithResponse(
        _characteristic,
        value: _writeFn(value),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  bool subscribe(void Function(T?) listener) {
    try {
      _ble.subscribeToCharacteristic(_characteristic).listen(
                  (event) => listener(_readFn(event)),
                  cancelOnError: true,
                );
      return true;
    } catch (_) {
      return false;
    }
  }
}

class DurationCharacteristic extends ValueCharacteristic<Duration> {
  DurationCharacteristic({
    required super.characteristicId,
    required super.serviceId,
    required super.deviceId,
  }) : super(
          readFn: _read,
          writeFn: _write,
        );

  static Duration? _read(List<int> values) {
    final ms = IntCharacteristic._read(values);
    if (ms == null) return null;
    return Duration(milliseconds: ms);
  }

  static List<int> _write(Duration value) =>
      IntCharacteristic._write(value.inMilliseconds);
}

class DoubleCharacteristic extends ValueCharacteristic<double> {
  DoubleCharacteristic({
    required super.characteristicId,
    required super.serviceId,
    required super.deviceId,
    required int digits,
  }) : super(
          readFn: _read,
          writeFn: _write(digits),
        );

  static double? _read(List<int> values) =>
      double.tryParse(String.fromCharCodes(values));

  static CharacteristicWriteFunction<double> _write(int digits) =>
      (value) => value.toStringAsFixed(digits).codeUnits;
}

class StringCharacteristic extends ValueCharacteristic<String> {
  StringCharacteristic({
    required super.characteristicId,
    required super.serviceId,
    required super.deviceId,
  }) : super(
          readFn: _read,
          writeFn: _write,
        );

  static String? _read(List<int> values) => String.fromCharCodes(values);

  static List<int> _write(String value) => value.codeUnits;
}

class BoolCharacteristic extends ValueCharacteristic<bool> {
  BoolCharacteristic({
    required super.characteristicId,
    required super.serviceId,
    required super.deviceId,
  }) : super(
          readFn: _read,
          writeFn: _write,
        );

  static bool? _read(List<int> value) => value.isEmpty ? null : value[0] == 1;

  static List<int> _write(bool value) => [value ? 1 : 0];
}

class IntCharacteristic extends ValueCharacteristic<int> {
  IntCharacteristic({
    required super.characteristicId,
    required super.serviceId,
    required super.deviceId,
  }) : super(
          readFn: _read,
          writeFn: _write,
        );

  static int? _read(List<int> values) => values.isEmpty
      ? null
      : values.indexed.map((e) => e.$2 << (8 * e.$1)).reduce((a, b) => a + b);

  static List<int> _write(int value) {
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
}

typedef CharacteristicReadFunction<T> = T? Function(List<int>);
typedef CharacteristicWriteFunction<T> = List<int> Function(T);
