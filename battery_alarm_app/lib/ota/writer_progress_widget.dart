import 'package:battery_alarm_app/ota/eta_widget.dart';
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
  Widget build(BuildContext context) => Column(
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

class OtaWriteSuccessWidget extends StatelessWidget {
  const OtaWriteSuccessWidget({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(Texts.labelUpdateSuccess()),
      );
}

class OtaWriteErrorWidget extends StatelessWidget {
  const OtaWriteErrorWidget({super.key});

  @override
  Widget build(BuildContext context) => Text(Texts.labelUpdateFailed());
}
