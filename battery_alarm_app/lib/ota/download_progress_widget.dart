import 'package:battery_alarm_app/text.dart';
import 'package:flutter/material.dart';

class DownloadProgressWidget extends StatelessWidget {
  const DownloadProgressWidget({
    super.key,
    required this.value,
    required this.error,
  });

  final double? value;
  final bool error;

  Widget _onProgress() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(Texts.labelDownloadingUpdate()),
          ),
          LinearProgressIndicator(value: value),
        ],
      );

  Widget _onError() => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(Texts.labelDownloadUpdateError()),
      );

  @override
  Widget build(BuildContext context) => error ? _onError() : _onProgress();
}
