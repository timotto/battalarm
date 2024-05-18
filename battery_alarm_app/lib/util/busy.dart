import 'dart:async';

abstract class BusySource {
  Stream<bool> get stream;
  bool get value;
}

abstract class BusyRunner {
  Future<T> run<T>(Future<T> Function() fn);
}

class Busy implements BusySource, BusyRunner {
  final StreamController<bool> _controller = StreamController.broadcast();
  bool _state = false;
  int _count = 0;

  @override
  Stream<bool> get stream => _controller.stream;

  @override
  bool get value => _state;

  @override
  Future<T> run<T>(Future<T> Function() fn) async {
    _count++;
    _compute();
    try {
      final result = await fn();
      return result;
    } finally {
      _count--;
      _compute();
    }
  }

  void _compute() {
    _setState(_count > 0);
  }

  void _setState(bool value) {
    _state = value;
    _controller.add(_state);
  }
}
