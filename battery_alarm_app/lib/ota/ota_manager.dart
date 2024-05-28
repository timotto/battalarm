import 'dart:async';

import 'package:battery_alarm_app/device_client/device_client.dart';
import 'package:battery_alarm_app/model/version.dart';
import 'package:battery_alarm_app/ota/model.dart';
import 'package:battery_alarm_app/ota/ota_repo.dart';
import 'package:battery_alarm_app/ota/writer_service.dart';

class OtaManager {
  final _deviceClient = DeviceClient();
  final _otaRepo = OtaRepo();

  OtaManagerState _state = OtaManagerState.checking(
    deviceVersion: null,
  );

  late StreamController<OtaManagerState> _controller;

  OtaManagerState get state => _state;

  Stream<OtaManagerState> get stream => _controller.stream;

  OtaArtifact? _artifact;

  OtaWriter? _writer;

  OtaManager() {
    _controller = StreamController<OtaManagerState>(onCancel: _onCancel);
  }

  void loadAvailableVersion({required bool beta}) {
    _updateState(OtaManagerState.checking(
      deviceVersion: _deviceClient.otaService.version,
    ));

    _otaRepo.readAvailableVersion(beta: beta).then(
          _onAvailableVersion,
          onError: (_) => _onError(OtaManagerError.availableVersionCheckFailed),
        );
  }

  void _onAvailableVersion(Version? version) {
    final deviceVersion = _deviceClient.otaService.version;
    if (deviceVersion == null || version == null) {
      _onError(OtaManagerError.availableVersionCheckFailed);
      return;
    }

    if (!version.isBetterThan(deviceVersion)) {
      _updateState(OtaManagerState.noUpdate(
        availableVersion: version,
        deviceVersion: deviceVersion,
      ));
      return;
    }

    _updateState(OtaManagerState.chooser(
      availableVersion: version,
      deviceVersion: deviceVersion,
    ));
  }

  void loadFirmware({required bool beta}) {
    _otaRepo.loadFirmware(beta: beta).then((p) => p.listen(_onLoaderProgress,
        onError: (_) => _onError(OtaManagerError.loadFirmwareFailed)));
  }

  void _onLoaderProgress(OtaLoaderProgress loaderProgress) {
    _updateState(OtaManagerState.download(loaderProgress));
    if (loaderProgress.artifact != null) {
      _artifact = loaderProgress.artifact;
      writeFirmware();
    }
  }

  void writeFirmware() {
    print('ota-manager::write-firmware');

    if (_artifact == null) {
      print('ota-manager::write-firmware::no-artifact');
      _onError(OtaManagerError.loadFirmwareFailed, reason: 'no-artifact');
      return;
    }

    _writer = _deviceClient.otaService.writeFirmware(_artifact!);
    if (_writer == null) {
      print('ota-manager::write-firmware::no-writer');
      _onError(OtaManagerError.writeFirmwareFailed, reason: 'no-writer');
      return;
    }

    _updateState(OtaManagerState.writing(null));

    _writer!.resultStream.listen(
      _onWriteProgress,
      onError: (e) => _onError(OtaManagerError.writeFirmwareFailed, reason: e),
    );

    _writer!.start();
  }

  void _onWriteProgress(OtaWriterProgress event) {
    if (event.done) {
      _updateState(OtaManagerState.onSuccess());
    } else {
      _updateState(OtaManagerState.writing(event));
    }
  }

  void onDispose() {
    _onCancel();
  }

  void _onError(OtaManagerError error, {dynamic reason}) =>
      _updateState(OtaManagerState.onError(error, reason: reason));

  void _updateState(OtaManagerState state) {
    _state = state;
    _controller.add(state);
  }

  void _onCancel() {
    print('ota-manager::on-cancel');
    switch (_state.step) {
      case OtaManagerStep.checking:
      case OtaManagerStep.chooser:
      case OtaManagerStep.noUpdate:
      case OtaManagerStep.success:
      case OtaManagerStep.error:
        // no cleanup needed
        break;

      case OtaManagerStep.download:
        // cleanup happens in downloader stream
        break;

      case OtaManagerStep.writing:
        _writer?.abort();
        break;
    }
  }
}

class OtaManagerState {
  final OtaManagerStep step;
  final Version? deviceVersion;
  final Version? availableVersion;
  final OtaLoaderProgress? loaderProgress;
  final OtaWriterProgress? writerProgress;
  final OtaManagerError? error;
  final dynamic errorReason;

  OtaManagerState({
    required this.step,
    this.deviceVersion,
    this.availableVersion,
    this.loaderProgress,
    this.writerProgress,
    this.error,
    this.errorReason,
  });

  static OtaManagerState checking({
    Version? deviceVersion,
  }) =>
      OtaManagerState(
        step: OtaManagerStep.checking,
        deviceVersion: deviceVersion,
      );

  static OtaManagerState chooser({
    Version? availableVersion,
    Version? deviceVersion,
  }) =>
      OtaManagerState(
        step: OtaManagerStep.chooser,
        availableVersion: availableVersion,
        deviceVersion: deviceVersion,
      );

  static OtaManagerState noUpdate({
    Version? availableVersion,
    Version? deviceVersion,
  }) =>
      OtaManagerState(
        step: OtaManagerStep.noUpdate,
        availableVersion: availableVersion,
        deviceVersion: deviceVersion,
      );

  static OtaManagerState download(OtaLoaderProgress? loaderProgress) =>
      OtaManagerState(
        step: OtaManagerStep.download,
        loaderProgress: loaderProgress,
      );

  static OtaManagerState writing(OtaWriterProgress? writerProgress) =>
      OtaManagerState(
        step: OtaManagerStep.writing,
        writerProgress: writerProgress,
      );

  static OtaManagerState onSuccess() => OtaManagerState(
        step: OtaManagerStep.success,
      );

  static OtaManagerState onError(OtaManagerError error, {dynamic reason}) =>
      OtaManagerState(
        step: OtaManagerStep.error,
        error: error,
        errorReason: reason,
      );
}

enum OtaManagerStep {
  checking,
  noUpdate,
  chooser,
  download,
  writing,
  success,
  error,
}

enum OtaManagerError {
  availableVersionCheckFailed,
  loadFirmwareFailed,
  writeFirmwareFailed,
}
