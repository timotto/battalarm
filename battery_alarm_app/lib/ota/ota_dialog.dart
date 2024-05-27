import 'package:battery_alarm_app/dev.dart';
import 'package:battery_alarm_app/ota/download_progress_widget.dart';
import 'package:battery_alarm_app/ota/ota_manager.dart';
import 'package:battery_alarm_app/ota/writer_progress_widget.dart';
import 'package:battery_alarm_app/text.dart';
import 'package:battery_alarm_app/util/smooth_eta.dart';
import 'package:flutter/material.dart';

class OtaDialog extends StatefulWidget {
  OtaDialog({super.key, required this.ota});

  final OtaManager ota;
  final _dev = DeveloperService();

  @override
  State<StatefulWidget> createState() => _OtaDialogState();

  static show(BuildContext context) async {
    final ota = OtaManager();
    await showDialog(context: context, builder: ((context) => OtaDialog(ota: ota)));
    ota.onDispose();
  }
}

class _OtaDialogState extends State<OtaDialog> {
  bool _beta = false;
  final _flashEta = SmoothEta();

  @override
  void initState() {
    super.initState();
    widget.ota.loadAvailableVersion(beta: _beta);
  }

  void _onCancel(BuildContext context) => Navigator.of(context).pop();

  void _onOk(BuildContext context) => Navigator.of(context).pop();

  void _onStartUpdate(BuildContext context) =>
      widget.ota.loadFirmware(beta: _beta);

  void _onSelectBeta(bool? value) {
    setState(() => _beta = value ?? false);
    widget.ota.loadAvailableVersion(beta: _beta);
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: widget.ota.stream,
        initialData: widget.ota.state,
        builder: (context, state) => AlertDialog(
          title: Text(Texts.otaDialogTitle()),
          icon: _icon(state.data),
          actions: _actions(state.data),
          content: _content(state.data),
        ),
      );

  Widget? _content(OtaManagerState? state) {
    switch (state?.step) {
      case OtaManagerStep.checking:
        return _contentWithBetaChooser([
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(Texts.labelSearchingUpdates()),
          ),
          const LinearProgressIndicator(value: null),
        ]);

      case OtaManagerStep.noUpdate:
        return _contentWithBetaChooser([
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(Texts.labelNoUpdateAvailable()),
          )
        ]);

      case OtaManagerStep.chooser:
        return _contentWithBetaChooser([
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(Texts.labelUpdateAvailable(
                state?.availableVersion?.toString() ?? '-')),
          ),
        ]);

      case OtaManagerStep.download:
        return DownloadProgressWidget(
          value: state?.loaderProgress?.progress,
          error: false,
        );

      case OtaManagerStep.writing:
        return WriterProgressWidget(
          eta: _flashEta.update(state?.writerProgress?.progress),
          value: state?.writerProgress,
        );

      case OtaManagerStep.success:
        return const OtaWriteSuccessWidget();

      case OtaManagerStep.error:
        print('ota-dialog::content::error reason=${state?.errorReason}');
        return const _ErrorWidget();

      case null:
        return null;
    }
  }

  Widget _contentWithBetaChooser(List<Widget> widgets) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget._dev.isDeveloper)
            Row(
              children: [
                Checkbox(
                  value: _beta,
                  onChanged: _onSelectBeta,
                ),
                Text(Texts.labelShowBetaVersion()),
              ],
            ),
          ...widgets,
        ],
      );

  Widget? _icon(OtaManagerState? state) {
    switch (state?.step) {
      case OtaManagerStep.error:
        return const Icon(Icons.error_outline);

      case null:
      default:
        return const Icon(Icons.info_outline);
    }
  }

  List<Widget>? _actions(OtaManagerState? state) {
    final List<Widget> result = [];

    switch (state?.step) {
      case null:
        break;

      case OtaManagerStep.checking:
      case OtaManagerStep.download:
      case OtaManagerStep.writing:
        result.add(TextButton(
            onPressed: () => _onCancel(context),
            child: Text(Texts.buttonCancel())));
        break;

      case OtaManagerStep.noUpdate:
      case OtaManagerStep.success:
      case OtaManagerStep.error:
        result.add(TextButton(
            onPressed: () => _onOk(context), child: Text(Texts.buttonOk())));
        break;

      case OtaManagerStep.chooser:
        result.add(TextButton(
          onPressed: () => _onStartUpdate(context),
          child: Text(Texts.buttonUpdateAdapter()),
        ));
        break;
    }

    return result;
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OtaWriteErrorWidget(),
          ],
        ),
      );
}
