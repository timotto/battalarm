import 'package:battery_alarm_app/dev.dart';
import 'package:battery_alarm_app/device_client/device_client.dart';
import 'package:battery_alarm_app/device_client/ota_service.dart';
import 'package:battery_alarm_app/ota/download_progress_widget.dart';
import 'package:battery_alarm_app/ota/model.dart';
import 'package:battery_alarm_app/ota/ota_repo.dart';
import 'package:battery_alarm_app/ota/update_chooser_widget.dart';
import 'package:battery_alarm_app/ota/writer_progress_widget.dart';
import 'package:battery_alarm_app/ota/writer_service.dart';
import 'package:battery_alarm_app/text.dart';
import 'package:battery_alarm_app/util/smooth_eta.dart';
import 'package:flutter/material.dart';

enum _OtaDialogStep {
  chooser,
  download,
  update,
}

class OtaDialog extends StatefulWidget {
  OtaDialog({super.key});

  static show(BuildContext context) => showDialog(
        context: context,
        builder: (context) => OtaDialog(),
      );

  final _deviceClient = DeviceClient();
  final _otaRepo = OtaRepo();
  final _dev = DeveloperService();

  OtaService get _otaService => _deviceClient.otaService;

  @override
  State<StatefulWidget> createState() => _OtaDialogState();
}

class _OtaDialogState extends State<OtaDialog> {
  _OtaDialogStep _step = _OtaDialogStep.chooser;

  int _tapCount = 0;
  bool _beta = false;

  double? _downloadProgressValue;
  bool _downloadError = false;
  bool _flashError = false;
  bool _flashComplete = false;
  OtaArtifact? _artifact;
  OtaWriter? _writer;

  final _flashEta = SmoothEta();

  @override
  void deactivate() {
    _writer?.cleanup();
    super.deactivate();
  }

  void _startDownload() {
    setState(() {
      _step = _OtaDialogStep.download;
    });

    widget._otaRepo
        .loadFirmware(
          beta: _beta,
          onProgress: _onDownloadProgress,
        )
        .then(
          _onDownloadComplete,
          onError: (_) => _onDownloadError(),
        );
  }

  void _onDownloadProgress(int complete, int total) {
    setState(() {
      _downloadProgressValue = complete.toDouble() / total.toDouble();
    });
  }

  void _onDownloadComplete(OtaArtifact value) {
    _artifact = value;
    _startFlashing();
    setState(() {
      _downloadProgressValue = null;
      _step = _OtaDialogStep.update;
    });
  }

  void _onDownloadError() {
    setState(() {
      _downloadError = true;
    });
  }

  void _onFlashError({String? reason}) {
    print('ota-widget::on-flash-error=$reason');
    setState(() {
      _flashError = true;
    });
  }

  void _onFlashSuccess() {
    setState(() {
      _flashComplete = true;
    });
  }

  void _startFlashing() {
    if (_artifact == null) {
      _onDownloadError();
      return;
    }

    _writer = widget._otaService.writeFirmware(_artifact!);
    if (_writer == null) {
      _onFlashError();
      return;
    }

    _writer?.resultStream.listen(_onWriterProgress);
    _writer?.start();
  }

  void _onWriterProgress(OtaWriterProgress value) {
    if (value.error != null) {
      _onFlashError(reason: value.error);
      return;
    }

    if (value.deviceError != null) {
      _onFlashError(reason: 'code-${value.deviceError}');
      return;
    }

    if (value.done) {
      _onFlashSuccess();
      return;
    }
  }

  void _onCancel(BuildContext context) {
    Navigator.of(context).pop();
  }

  Widget? _icon() {
    if (_downloadError) return const Icon(Icons.error_outline);
    if (_flashError) return const Icon(Icons.error_outline);
    if (_flashComplete) return const Icon(Icons.info_outline);

    return null;
  }

  void _onDeviceVersionTap() {
    _tapCount++;
    if (_tapCount == 7) {
      setState(() {
        _beta = !_beta;
        _tapCount = 0;
      });
    }
  }

  void _onBetaSelected(bool? value) {
    setState(() {
      _beta = value ?? false;
    });
  }

  Widget _content(BuildContext context) {
    switch (_step) {
      case _OtaDialogStep.chooser:
        return FutureBuilder(
          future: widget._otaRepo.readAvailableVersion(beta: _beta),
          builder: (_, availableVersion) => StreamBuilder(
            stream: widget._otaService.versionStream,
            initialData: widget._otaService.version,
            builder: (_, deviceVersion) => UpdateChooserWidget(
              deviceVersion: deviceVersion.data,
              availableVersion: availableVersion.data,
              onTapDeviceVersion: _onDeviceVersionTap,
              onStartUpdate: _startDownload,
              canSelectBeta: widget._dev.isDeveloper,
              betaSelected: _beta,
              onBetaSelected: _onBetaSelected,
            ),
          ),
        );

      case _OtaDialogStep.download:
        return DownloadProgressWidget(
          value: _downloadProgressValue,
          error: _downloadError,
        );

      case _OtaDialogStep.update:
        return StreamBuilder(
          stream: _writer!.resultStream,
          initialData: _writer!.resultValue,
          builder: (_, writerProgress) => WriterProgressWidget(
            eta: _flashEta.update(writerProgress.data?.progress),
            value: writerProgress.data,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(Texts.otaDialogTitle()),
        icon: _icon(),
        actions: [
          if (_downloadError || _flashError || _flashComplete)
            TextButton(
              onPressed: () => _onCancel(context),
              child: Text(Texts.buttonOk()),
            ),
        ],
        content: _content(context),
      );
}
