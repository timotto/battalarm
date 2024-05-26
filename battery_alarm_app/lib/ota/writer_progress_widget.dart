import 'package:battery_alarm_app/ota/eta_widget.dart';
import 'package:battery_alarm_app/ota/protocol.dart';
import 'package:battery_alarm_app/ota/writer_service.dart';
import 'package:flutter/material.dart';

class WriterProgressWidget extends StatelessWidget {
  const WriterProgressWidget({
    super.key,
    required this.started,
    required this.value,
  });

  final DateTime? started;
  final OtaWriterProgress? value;

  Duration? _eta() {
    if (value == null || started == null) return null;

    final now = DateTime.timestamp();
    final elapsed = now.difference(started!).inSeconds.toDouble();

    if (elapsed < 1) return null;

    final progressPerSecond = value!.progress / elapsed;
    final secondsRemaining = (1.0 - value!.progress) / progressPerSecond;
    return Duration(seconds: secondsRemaining.toInt());
  }

  @override
  Widget build(BuildContext context) {
    if (value?.deviceError != null) {
      return _DeviceErrorWidget(value: value!.deviceError!);
    }

    if (value?.error != null) {
      return _GeneralErrorWidget(value: value!.error!);
    }

    if (value?.done ?? false) {
      return const _SuccessWidget();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text('Writing update to Adapter...'),
        ),
        LinearProgressIndicator(value: value?.progress),
        Padding(
          padding: const EdgeInsets.all(8),
          child: EtaWidget(value: _eta()),
        ),
      ],
    );
  }
}

class _SuccessWidget extends StatelessWidget {
  const _SuccessWidget();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(8),
        child: Text(
            'The update has been successful. The Adapter will restart in a moment.'),
      );
}

class _GeneralErrorWidget extends StatelessWidget {
  const _GeneralErrorWidget({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _OtaErrorWidget(),
            Text('Error code: $value'),
          ],
        ),
      );
}

class _DeviceErrorWidget extends StatelessWidget {
  const _DeviceErrorWidget({required this.value});

  final OtaDeviceError value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _OtaErrorWidget(),
            Text('Adapter error code: $value'),
          ],
        ),
      );
}

class _OtaErrorWidget extends StatelessWidget {
  const _OtaErrorWidget();

  @override
  Widget build(BuildContext context) => const Text(
      'There was a problem updating the Adapter. Please unplug the Adapter, wait a few seconds, plug it back in and try again.');
}
