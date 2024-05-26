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

  Future<OtaArtifact> loadFirmware({
    bool beta = false,
    void Function(int, int)? onProgress,
  }) async {
    final client = HttpClient();

    final req = await client.getUrl(Uri.parse(_firmwareUrl(beta: beta)));
    final res = await req.close();
    final contentLength = res.contentLength;

    final List<int> data = [];
    await for (var block in res) {
      data.addAll(block);
      if (onProgress != null) onProgress(data.length, contentLength);
    }

    final hash = sha256.convert(data);

    return OtaArtifact(
      size: data.length,
      sha256: hash.bytes,
      data: data,
    );
  }

  String _versionUrl({required bool beta}) =>
      '${otaRepoBaseUrl}firmware${beta ? '-beta' : ''}-version.txt';

  String _firmwareUrl({required bool beta}) =>
      '${otaRepoBaseUrl}firmware${beta ? '-beta' : ''}.bin';
}
