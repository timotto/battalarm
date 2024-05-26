import 'dart:async';

import 'package:battery_alarm_app/device_client/device_client.dart';
import 'package:battery_alarm_app/device_client/ota_service.dart';
import 'package:battery_alarm_app/ota/model.dart';
import 'package:battery_alarm_app/model/version.dart';
import 'package:battery_alarm_app/ota/ota_repo.dart';
import 'package:battery_alarm_app/ota/writer_service.dart';
import 'package:battery_alarm_app/util/duration.dart';
import 'package:flutter/material.dart';

class OtaWidget extends StatefulWidget {
  OtaWidget({super.key})
      : deviceClient = DeviceClient(),
        otaRepo = OtaRepo() {
    _loader = _VersionsLoader(
      deviceClient: deviceClient,
      otaRepo: otaRepo,
    );
  }

  final DeviceClient deviceClient;
  final OtaRepo otaRepo;
  late _VersionsLoader _loader;

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
        body: Column(
          children: [
            StreamBuilder(
              stream: widget.deviceClient.busy.stream,
              initialData: widget.deviceClient.busy.value,
              builder: (_, busy) => LinearProgressIndicator(
                value: busy.data ?? false ? null : 0,
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: widget._loader.load(beta: _beta),
                initialData: _Versions.empty(),
                builder: (context, versions) => ListView(
                  children: [
                    ListTile(
                      title: StreamBuilder(
                        stream: widget.deviceClient.otaService.versionStream,
                        initialData: widget.deviceClient.otaService.version,
                        builder: (_, version) => _PendingWidget(
                          value: version.data,
                          builder: (version) => Text(version.toString()),
                        ),
                      ),
                      subtitle: const Text('Device firmware version'),
                      onTap: _onDeviceVersionTap,
                    ),
                    ListTile(
                      title: _PendingWidget(
                        value: versions.data?.availableVersion,
                        builder: (version) => Text(version.toString()),
                      ),
                      subtitle: Text(
                        !_beta
                            ? 'Available firmware version'
                            : 'Available firmware version (beta)',
                      ),
                    ),
                    if (_beta)
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                            'A beta firmware may cause your Adapter to function incorrectly and can even require restore the Adapter by connecting it to a computer.'),
                      ),
                    if (versions.data?.hasUpdate ?? false)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () => _runUpdate(context),
                          child: const Text('Update adapter'),
                        ),
                      ),
                    if (versions.data?.hasNoUpdate ?? false)
                      const ListTile(
                        title: Text('No update available'),
                      ),
                  ],
                ),
              ),
            )
          ],
        ),
      );

  void _onCancel(context) {
    Navigator.pop(context);
  }
}

class _PendingWidget<T> extends StatelessWidget {
  const _PendingWidget({
    super.key,
    required this.value,
    required this.builder,
  });

  final T? value;
  final Widget Function(T) builder;

  Widget _pending() => const LinearProgressIndicator(value: null);

  @override
  Widget build(BuildContext context) =>
      value == null ? _pending() : builder(value!);
}

class _Versions {
  final Version? deviceVersion;
  final Version? availableVersion;

  _Versions({
    required this.deviceVersion,
    required this.availableVersion,
  });

  bool get ready => deviceVersion != null && availableVersion != null;

  bool get hasUpdate => ready && availableVersion!.isBetterThan(deviceVersion!);

  bool get hasNoUpdate =>
      ready && !availableVersion!.isBetterThan(deviceVersion!);

  static _Versions empty() => _Versions(
        deviceVersion: null,
        availableVersion: null,
      );
}

class _VersionsLoader {
  _VersionsLoader({
    required this.deviceClient,
    required this.otaRepo,
  });

  final DeviceClient deviceClient;
  final OtaRepo otaRepo;
  final _controller = StreamController<_Versions>();
  _Versions _state = _Versions.empty();

  Stream<_Versions> load({bool beta = false}) {
    _controller.add(_state);
    deviceClient.otaService.readVersion().then(
          _onDeviceVersion,
          onError: (_) => _setError('device'),
        );
    otaRepo.readAvailableVersion(beta: beta).then(
          _onAvailableVersion,
          onError: (_) => _setError('repo'),
        );
    return _controller.stream;
  }

  void _onDeviceVersion(Version? value) => _setState(_Versions(
        deviceVersion: value,
        availableVersion: _state.availableVersion,
      ));

  void _onAvailableVersion(Version? value) => _setState(_Versions(
        deviceVersion: _state.deviceVersion,
        availableVersion: value,
      ));

  void _setState(_Versions value) {
    _state = value;
    _controller.add(value);
  }

  void _setError(String value) {
    _controller.addError(value);
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
  String? _flashErrorReason;
  OtaArtifact? _artifact;
  OtaWriter? _writer;
  DateTime? _flashStart;
  Duration? _flashElapsed;
  Duration? _flashRemaining;
  DateTime? _flashEta;

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

  String _stepText() {
    switch (_step) {
      case 0:
        return 'Download';

      case 1:
        return 'Flashing';

      default:
        return '?';
    }
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
    _otaProgressValue = complete.toDouble() / total.toDouble();
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
      _flashErrorReason = reason;
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
    _otaProgressValue = value.progress;

    final now = DateTime.timestamp();
    _flashStart ??= now;
    _flashElapsed = now.difference(_flashStart!);
    if (_flashElapsed!.inSeconds > 0 && value.progress > 0) {
      // eg: 50 seconds for 10% => 0.1 / 50 => 0.002
      final progressPerSecond =
          value.progress / (_flashElapsed!.inSeconds.toDouble());
      // eg (1.0 - 0.1) / 0.002 => 0.9 / 0.002
      final secondsLeft = (1.0 - value.progress) / progressPerSecond;
      _flashRemaining = Duration(seconds: secondsLeft.toInt());
      _flashEta =
          DateTime.timestamp().add(_flashRemaining!);
    }

    setState(() {});

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

  List<Widget> _content(BuildContext context) {
    if (_downloadError) {
      return [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text(
              'There was a problem downloading the update. Please try again later.'),
        ),
      ];
    }

    if (_flashError) {
      return [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text(
              'There was a problem updating the Adapter. Please unplug the Adapter, wait a few seconds, plug it back in and try again.'),
        ),
      ];
    }

    if (_flashComplete) {
      return [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text(
              'The update has been successful. The Adapter will restart in a moment.'),
        ),
      ];
    }

    return [
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(_stepText()),
      ),
      LinearProgressIndicator(
        value: _otaProgressValue,
      ),
      if (_flashRemaining != null)
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text('Time remaining: ${formatDuration(_flashRemaining)}'),
        ),
    ];
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _content(context),
        ),
      );
}
