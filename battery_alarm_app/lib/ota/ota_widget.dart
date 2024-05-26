import 'package:battery_alarm_app/device_client/device_client.dart';
import 'package:battery_alarm_app/device_client/ota_service.dart';
import 'package:battery_alarm_app/ota/download_progress_widget.dart';
import 'package:battery_alarm_app/ota/model.dart';
import 'package:battery_alarm_app/ota/ota_repo.dart';
import 'package:battery_alarm_app/ota/update_chooser_widget.dart';
import 'package:battery_alarm_app/ota/writer_progress_widget.dart';
import 'package:battery_alarm_app/ota/writer_service.dart';
import 'package:flutter/material.dart';

class OtaWidget extends StatefulWidget {
  OtaWidget({super.key});

  final deviceClient = DeviceClient();
  final otaRepo = OtaRepo();

  @override
  State<StatefulWidget> createState() => _OtaWidgetState();
}

class _OtaWidgetState extends State<OtaWidget> {
  int _tapCount = 0;
  bool _beta = false;

  void _runUpdate(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _OtaDialog(
        otaService: widget.deviceClient.otaService,
        otaRepo: widget.otaRepo,
        beta: _beta,
      ),
    );

    if (!context.mounted) return;
    Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Firmware update'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _onCancel(context),
          ),
        ),
        body: FutureBuilder(
          future: widget.otaRepo.readAvailableVersion(beta: _beta),
          builder: (_, availableVersion) => StreamBuilder(
            stream: widget.deviceClient.otaService.versionStream,
            initialData: widget.deviceClient.otaService.version,
            builder: (_, deviceVersion) => UpdateChooserWidget(
              deviceVersion: deviceVersion.data,
              availableVersion: availableVersion.data,
              onTapDeviceVersion: _onDeviceVersionTap,
              onStartUpdate: () => _runUpdate(context),
            ),
          ),
        ),
      );

  void _onCancel(context) {
    Navigator.pop(context);
  }
}

class _OtaDialog extends StatefulWidget {
  const _OtaDialog({
    required this.otaService,
    required this.otaRepo,
    required this.beta,
  });

  final OtaService otaService;
  final OtaRepo otaRepo;
  final bool beta;

  @override
  State<StatefulWidget> createState() => _OtaDialogState();
}

class _OtaDialogState extends State<_OtaDialog> {
  int _step = 0;
  double? _otaProgressValue;
  bool _downloadError = false;
  bool _flashError = false;
  bool _flashComplete = false;
  OtaArtifact? _artifact;
  OtaWriter? _writer;
  DateTime? _flashStart;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  @override
  void deactivate() {
    _writer?.cleanup();
    super.deactivate();
  }

  void _startDownload() {
    widget.otaRepo
        .loadFirmware(
          beta: widget.beta,
          onProgress: _onDownloadProgress,
        )
        .then(
          _onDownloadComplete,
          onError: (_) => _onDownloadError(),
        );
  }

  void _onDownloadProgress(int complete, int total) {
    setState(() {
      _otaProgressValue = complete.toDouble() / total.toDouble();
    });
  }

  void _onDownloadComplete(OtaArtifact value) {
    _artifact = value;
    _startFlashing();
    setState(() {
      _otaProgressValue = null;
      _step = 1;
    });
  }

  void _onDownloadError() {
    setState(() {
      _downloadError = true;
    });
  }

  void _onFlashError({String? reason}) {
    print('ota-widget::on-flash-error=$reason');
    _writer?.cleanup();
    setState(() {
      _flashError = true;
    });
  }

  void _onFlashSuccess() {
    _writer?.cleanup();
    setState(() {
      _flashComplete = true;
    });
  }

  void _startFlashing() {
    if (_artifact == null) {
      _onDownloadError();
      return;
    }

    _flashStart = DateTime.timestamp();
    _writer = widget.otaService.writeFirmware(_artifact!);
    if (_writer == null) {
      _onFlashError();
      return;
    }

    _writer?.resultStream.listen(_onWriterProgress);
    _writer?.start();
  }

  void _onWriterProgress(OtaWriterProgress value) {
    final now = DateTime.timestamp();
    _flashStart ??= now;

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

  Widget _content(BuildContext context) {
    switch (_step) {
      case 0:
        return DownloadProgressWidget(
          value: _otaProgressValue,
          error: _downloadError,
        );

      case 1:
        return StreamBuilder(
          stream: _writer!.resultStream,
          initialData: _writer!.resultValue,
          builder: (_, writerProgress) => WriterProgressWidget(
            started: _flashStart,
            value: writerProgress.data,
          ),
        );

      default:
        return const Text('...');
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Firmware update'),
        icon: _icon(),
        actions: [
          if (_downloadError || _flashError || _flashComplete)
            TextButton(
              onPressed: () => _onCancel(context),
              child: const Text('OK'),
            ),
        ],
        content: _content(context),
      );
}
