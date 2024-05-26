import 'dart:async';

import 'package:battery_alarm_app/ota/model.dart';
import 'package:battery_alarm_app/ota/protocol.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

const _mtuHeader = 3;
const _mtuMax = 500;

class OtaWriter {
  OtaWriter({
    required this.deviceId,
    required this.u2d,
    required this.d2u,
    required this.artifact,
  });

  final _ble = FlutterReactiveBle();

  final String deviceId;
  final QualifiedCharacteristic u2d;
  final QualifiedCharacteristic d2u;
  final OtaArtifact artifact;

  final _resultController = StreamController<OtaWriterProgress>.broadcast();

  OtaWriterProgress _resultValue = OtaWriterProgress.empty();

  _OtaWriterState _writerState = _OtaWriterState.idle;

  int _writerOffset = 0;

  int _mtu = 100;

  StreamSubscription<List<int>>? _d2uSubscription;

  Stream<OtaWriterProgress> get resultStream => _resultController.stream;

  OtaWriterProgress get resultValue => _resultValue;

  void start() async {
    if (_writerState != _OtaWriterState.idle) {
      throw 'writer not idle';
    }

    _mtu = await _ble.requestMtu(deviceId: deviceId, mtu: 512);
    // _mtu = 256;
    print('ota-writer::mtu=$_mtu');
    if (_mtu <= _mtuHeader) {
      throw 'mtu too small';
    }
    _mtu -= _mtuHeader;

    if (_mtu > _mtuMax) {
      _mtu = _mtuMax;
    }

    _writerState = _OtaWriterState.begin;
    _writerOffset = 0;
    _d2uSubscription = _ble.subscribeToCharacteristic(d2u).listen(
          _onD2u,
          onError: (_) => _onD2uError(),
        );

    Future.delayed(const Duration(milliseconds: 100)).then((_) async {
      if (_writerState != _OtaWriterState.begin) return;
      print('ota-writer::d2u-explicit-read');
      await _ble.readCharacteristic(d2u);
    });
  }

  void abort() => _u2dAbort();

  void cleanup() => _cleanup();

  void _onD2u(List<int> data) {
    if (data.isEmpty) return;
    final deviceState = OtaDeviceStateP.parse(data[0]);

    switch (deviceState) {
      case null:
        _updateResult(OtaWriterProgress.failed('parse-d2u'));
        _cleanup();
        return;

      case OtaDeviceState.complete:
        _updateResult(OtaWriterProgress.success());
        _cleanup();
        return;

      case OtaDeviceState.error:
        if (_writerState == _OtaWriterState.begin) {
          _u2dBegin();
          return;
        }

        if (data.length < 2) {
          _updateResult(OtaWriterProgress.failed('parse-device-error-short'));
          _cleanup();
          return;
        }

        final deviceError = OtaDeviceErrorP.parse(data[1]);
        if (deviceError == null) {
          _updateResult(OtaWriterProgress.failed('parse-device-error-unknown'));
          _cleanup();
          return;
        }

        _updateResult(OtaWriterProgress.deviceFailed(deviceError));
        _cleanup();
        return;

      case OtaDeviceState.idle:
        if (_writerState != _OtaWriterState.begin) {
          _updateResult(OtaWriterProgress.failed('unexpected-idle'));
          _cleanup();
          return;
        }
        _u2dBegin();
        return;

      case OtaDeviceState.expect:
        if (data.length < 5) {
          _updateResult(OtaWriterProgress.failed('parse-expect-short'));
          _u2dAbort();
          _cleanup();
          return;
        }

        int requestedOffset =
            data[1] | (data[2] << 8) | (data[3] << 16) | (data[4] << 24);

        if (requestedOffset != _writerOffset) {
          _updateResult(OtaWriterProgress.failed(
              'unexpected-offset-$_writerOffset-$requestedOffset'));
          _u2dAbort();
          _cleanup();
          return;
        }

        _u2dSend();
        return;
    }
  }

  void _u2dBegin() {
    _writerState = _OtaWriterState.started;

    List<int> args = [
      (artifact.size & 0xff),
      ((artifact.size >> 8) & 0xff),
      ((artifact.size >> 16) & 0xff),
      ((artifact.size >> 24) & 0xff),
    ];

    args.addAll(artifact.sha256);

    _send(OtaUpdaterCommand.begin, arguments: args);
  }

  Future<void> _u2dSend() async {
    int size = artifact.size - _writerOffset;
    if (size > _mtu) size = _mtu;

    final args = artifact.data.sublist(_writerOffset, _writerOffset + size);

    try {
      _writerOffset += size;
      await _send(OtaUpdaterCommand.send, arguments: args);
      _updateResult(OtaWriterProgress.sending(
          _writerOffset.toDouble() / artifact.size.toDouble()));
    } catch (e) {
      print('ota-writer::u2d-send::exception=$e');
      _updateResult(OtaWriterProgress.failed('send-failed-$e'));
      _u2dAbort();
      _cleanup();
    }
  }

  void _u2dAbort() => _send(OtaUpdaterCommand.abort);

  Future<void> _send(OtaUpdaterCommand command, {List<int>? arguments}) async {
    List<int> data = [OtaUpdaterCommandP.format(command)];
    if (arguments != null) data.addAll(arguments);
    await _ble.writeCharacteristicWithResponse(u2d, value: data);
  }

  void _onD2uError() {
    _updateResult(OtaWriterProgress.failed('device-disconnected'));
    _cleanup();
  }

  void _updateResult(OtaWriterProgress value) {
    _resultValue = value;
    _resultController.add(value);
  }

  void _cleanup() {
    _d2uSubscription?.cancel();
    _writerState = _OtaWriterState.idle;
  }
}

enum _OtaWriterState {
  idle,
  begin,
  started,
}

class OtaWriterProgress {
  OtaWriterProgress({
    required this.progress,
    required this.done,
    this.error,
    this.deviceError,
  });

  final double progress;
  final bool done;
  final String? error;
  final OtaDeviceError? deviceError;

  static OtaWriterProgress empty() => OtaWriterProgress(
        progress: 0,
        done: false,
      );

  static OtaWriterProgress success() => OtaWriterProgress(
        progress: 1,
        done: true,
      );

  static OtaWriterProgress sending(double value) => OtaWriterProgress(
        progress: value > 1
            ? 1
            : value < 0
                ? 0
                : value,
        done: false,
      );

  static OtaWriterProgress failed(String value) => OtaWriterProgress(
        progress: 0,
        done: true,
        error: value,
      );

  static OtaWriterProgress deviceFailed(OtaDeviceError value) =>
      OtaWriterProgress(
        progress: 0,
        done: true,
        error: 'device',
        deviceError: value,
      );
}
