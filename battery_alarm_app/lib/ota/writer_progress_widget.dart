import 'package:battery_alarm_app/ota/eta_widget.dart';
import 'package:battery_alarm_app/ota/protocol.dart';
import 'package:battery_alarm_app/ota/writer_service.dart';
import 'package:battery_alarm_app/text.dart';
import 'package:flutter/material.dart';

class WriterProgressWidget extends StatelessWidget {
  const WriterProgressWidget({
    super.key,
    required this.eta,
    required this.value,
  });

  final DateTime? eta;
  final OtaWriterProgress? value;

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
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(Texts.labelWritingUpdate()),
        ),
        LinearProgressIndicator(value: value?.progress),
        Padding(
          padding: const EdgeInsets.all(8),
          child: EtaWidget(eta: eta),
        ),
      ],
    );
  }
}

class _SuccessWidget extends StatelessWidget {
  const _SuccessWidget();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(Texts.labelUpdateSuccess()),
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
            Text(Texts.labelErrorCode(value)),
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
            Text(Texts.labelAdapterErrorCode(value.name)),
          ],
        ),
      );
}

class _OtaErrorWidget extends StatelessWidget {
  const _OtaErrorWidget();

  @override
  Widget build(BuildContext context) => Text(Texts.labelUpdateFailed());
}
