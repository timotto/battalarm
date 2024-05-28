class OtaArtifact {
  final int size;
  final List<int> sha256;
  final List<int> data;

  OtaArtifact({
    required this.size,
    required this.sha256,
    required this.data,
  });
}

class OtaWriterProgress {
  OtaWriterProgress({
    required this.progress,
    required this.done,
    this.error,
    this.deviceError,
  });

  final double progress;
  final bool done;
  final String? error;
  final OtaDeviceError? deviceError;

  static OtaWriterProgress empty() => OtaWriterProgress(
    progress: 0,
    done: false,
  );

  static OtaWriterProgress success() => OtaWriterProgress(
    progress: 1,
    done: true,
  );

  static OtaWriterProgress sending(double value) => OtaWriterProgress(
    progress: value > 1
        ? 1
        : value < 0
        ? 0
        : value,
    done: false,
  );

  static OtaWriterProgress failed(String value) => OtaWriterProgress(
    progress: 0,
    done: true,
    error: value,
  );

  static OtaWriterProgress deviceFailed(OtaDeviceError value) =>
      OtaWriterProgress(
        progress: 0,
        done: true,
        error: 'device',
        deviceError: value,
      );
}

enum OtaDeviceState {
  idle,
  error,
  expect,
  complete,
}

enum OtaUpdaterCommand {
  begin,
  abort,
  send,
}

enum OtaDeviceError {
  none,
  badState,
  badArguments,
  badCommand,
  beginUpdate,
  size,
  checksum,
  updateEnd,
  sendTimeout,
}
