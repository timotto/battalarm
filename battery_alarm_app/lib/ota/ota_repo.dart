import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:battery_alarm_app/backend.dart';
import 'package:battery_alarm_app/ota/model.dart';
import 'package:battery_alarm_app/model/version.dart';
import 'package:crypto/crypto.dart';

class OtaRepo {
  Future<Version?> readAvailableVersion({bool beta = false}) async {
    final client = HttpClient();

    final req = await client.getUrl(Uri.parse(_versionUrl(beta: beta)));
    final res = await req.close();
    final value = await res.transform(utf8.decoder).join('');

    return Version.parse(value);
  }

  Future<Stream<OtaLoaderProgress>> loadFirmware({bool beta = false}) async {
    final client = HttpClient();
    final req = await client.getUrl(Uri.parse(_firmwareUrl(beta: beta)));

    final controller = StreamController<OtaLoaderProgress>(
      onCancel: () {
        req.abort();
      },
    );

    controller.add(OtaLoaderProgress(progress: null));
    req.close().then((res) async {
      try {
        final contentLength = res.contentLength;

        final List<int> data = [];
        await for (var block in res) {
          data.addAll(block);
          controller.add(OtaLoaderProgress(
            progress: data.length.toDouble() / contentLength.toDouble(),
          ));
        }

        controller.add(OtaLoaderProgress(progress: 1));
        final hash = sha256.convert(data);

        controller.add(OtaLoaderProgress(
          progress: 1,
          artifact: OtaArtifact(
            size: data.length,
            sha256: hash.bytes,
            data: data,
          ),
        ));
      } catch (e) {
        controller.addError(e);
      } finally {
        await controller.close();
      }
    });

    return controller.stream;
  }

  String _versionUrl({required bool beta}) =>
      '${otaRepoBaseUrl}firmware${beta ? '-beta' : ''}-version.txt';

  String _firmwareUrl({required bool beta}) =>
      '${otaRepoBaseUrl}firmware${beta ? '-beta' : ''}.bin';
}

class OtaLoaderProgress {
  final double? progress;
  final OtaArtifact? artifact;

  OtaLoaderProgress({
    required this.progress,
    this.artifact,
  });
}
