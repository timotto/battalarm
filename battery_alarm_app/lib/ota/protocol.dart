import 'package:battery_alarm_app/ota/model.dart';

class OtaDeviceStateP {
  OtaDeviceStateP._();

  static const idle = 0x11;
  static const error = 0x12;
  static const expect = 0x13;
  static const complete = 0x14;

  static OtaDeviceState? parse(int value) {
    switch (value) {
      case idle:
        return OtaDeviceState.idle;
      case error:
        return OtaDeviceState.error;
      case expect:
        return OtaDeviceState.expect;
      case complete:
        return OtaDeviceState.complete;
      default:
        return null;
    }
  }
}

class OtaUpdaterCommandP {
  OtaUpdaterCommandP._();

  static const begin = 0x01;
  static const abort = 0x02;
  static const send = 0x03;

  static int format(OtaUpdaterCommand value) {
    switch (value) {
      case OtaUpdaterCommand.begin:
        return begin;

      case OtaUpdaterCommand.abort:
        return abort;

      case OtaUpdaterCommand.send:
        return send;
    }
  }
}

class OtaDeviceErrorP {
  OtaDeviceErrorP._();

  static const none = 0x00;
  static const badState = 0x01;
  static const badArguments = 0x02;
  static const badCommand = 0x03;
  static const beginUpdate = 0x04;
  static const size = 0x05;
  static const checksum = 0x06;
  static const updateEnd = 0x07;
  static const sendTimeout = 0x08;

  static OtaDeviceError? parse(int value) {
    switch (value) {
      case none:
        return OtaDeviceError.none;
      case badState:
        return OtaDeviceError.badState;
      case badArguments:
        return OtaDeviceError.badArguments;
      case badCommand:
        return OtaDeviceError.badCommand;
      case beginUpdate:
        return OtaDeviceError.beginUpdate;
      case size:
        return OtaDeviceError.size;
      case checksum:
        return OtaDeviceError.checksum;
      case updateEnd:
        return OtaDeviceError.updateEnd;
      case sendTimeout:
        return OtaDeviceError.sendTimeout;
      default:
        return null;
    }
  }
}
