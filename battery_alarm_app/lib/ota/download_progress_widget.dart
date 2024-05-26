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
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Downloading update...'),
          ),
          LinearProgressIndicator(value: value),
        ],
      );

  Widget _onError() => const Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          'There was a problem downloading the update. Please try again later.',
        ),
      );

  @override
  Widget build(BuildContext context) => error ? _onError() : _onProgress();
}
