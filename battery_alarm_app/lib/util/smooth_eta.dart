class SmoothEta {
  SmoothEta({double lpf = 0.9}) : _lpf = lpf;

  final double _lpf;

  DateTime? _started;
  DateTime? _result;

  double _progressPerMs = 0;
  bool _first = true;

  DateTime? update(double? progress) {
    if (progress == null) return _result;

    final now = DateTime.timestamp();
    _started ??= now;

    final elapsedMs = now.difference(_started!).inMilliseconds.toDouble();
    if (elapsedMs < 5000) return _result;

    final progressPerMs = progress / elapsedMs;
    if (_first) {
      _first = false;
      _progressPerMs = progressPerMs;
    } else {
      _progressPerMs = (_lpf * _progressPerMs) + ((1.0 - _lpf) * progressPerMs);
    }

    final totalMs = 1.0 / _progressPerMs;
    _result = _started!.add(Duration(milliseconds: totalMs.toInt()));

    return _result;
  }
}
