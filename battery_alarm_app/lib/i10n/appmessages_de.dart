// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
// messages from the main program should be duplicated here with the same
// function name.
// @dart=2.12
// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

typedef String? MessageIfAbsent(
    String? messageStr, List<Object>? args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'de';

  static m0(max) => "Die Eingabe ist zu hoch, höchstens ${max}.";

  static m1(min) => "Die Eingabe ist zu niedrig, mindestens ${min}.";

  @override
  final Map<String, dynamic> messages = _notInlinedMessages(_notInlinedMessages);

  static Map<String, dynamic> _notInlinedMessages(_) => {
      'connected': MessageLookupByLibrary.simpleMessage('Verbunden'),
    'connecting': MessageLookupByLibrary.simpleMessage('Verbinde...'),
    'connectionFailed': MessageLookupByLibrary.simpleMessage('Verbindung Fehlgeschlagen'),
    'deviceScannerError': MessageLookupByLibrary.simpleMessage('Die Verbindung wurde unterbrochen.'),
    'deviceScannerHint': MessageLookupByLibrary.simpleMessage('Wenn der Adapter nicht gefunden wird, dann halte den Knopf am Adapter für ca. 5 Sekunden lang gedrückt, bis ein tiefer Piepton kommt.'),
    'deviceScannerNoResults': MessageLookupByLibrary.simpleMessage('Keine Adapter gefunden'),
    'deviceScannerSearching': MessageLookupByLibrary.simpleMessage('Suche nach Battalarm Adaptern...'),
    'disconnected': MessageLookupByLibrary.simpleMessage('Getrennt'),
    'disconnecting': MessageLookupByLibrary.simpleMessage('Trennen...'),
    'doubleEditDialogToHigh': m0,
    'doubleEditDialogToLow': m1,
    'labelAutoTuneRssi': MessageLookupByLibrary.simpleMessage('Signalstärke automatisch anpassen'),
    'labelBuzzerAlerts': MessageLookupByLibrary.simpleMessage('Akkustische Benachrichtigung bei:'),
    'labelBuzzerBluetooth': MessageLookupByLibrary.simpleMessage('Bluetooth Aktivität'),
    'labelBuzzerButton': MessageLookupByLibrary.simpleMessage('Knopf am Gerät'),
    'labelBuzzerCharging': MessageLookupByLibrary.simpleMessage('Batterieladegerät angeschlossen'),
    'labelBuzzerGarage': MessageLookupByLibrary.simpleMessage('Garage betreten oder verlassen'),
    'labelBuzzerHello': MessageLookupByLibrary.simpleMessage('Begrüßung'),
    'labelDelayAlert': MessageLookupByLibrary.simpleMessage('Verzögerung bis zum Alarm'),
    'labelDelayWarn': MessageLookupByLibrary.simpleMessage('Verzögerung bis zur Warnung'),
    'labelNoSignal': MessageLookupByLibrary.simpleMessage('Kein Empfang'),
    'labelRssi': MessageLookupByLibrary.simpleMessage('Basisstation Signalstärke in Garage'),
    'labelSnoozeTime': MessageLookupByLibrary.simpleMessage('Snooze time'),
    'labelVbatChargeThreshold': MessageLookupByLibrary.simpleMessage('Batterieladegerät Endspannung'),
    'labelVbatDeltaThreshold': MessageLookupByLibrary.simpleMessage('Batterieladegerät Geschwindigkeit'),
    'labelVbatLpF': MessageLookupByLibrary.simpleMessage('Batteriespannung Tiefpass Faktor'),
    'labelVbatTuneFactor': MessageLookupByLibrary.simpleMessage('Batteriespannung Feinjustierung'),
    'menuItemExpertView': MessageLookupByLibrary.simpleMessage('Experten Ansicht'),
    'tabLabelHelp': MessageLookupByLibrary.simpleMessage('Hilfe'),
    'tabLabelSettings': MessageLookupByLibrary.simpleMessage('Einstellungen'),
    'tabLabelStatus': MessageLookupByLibrary.simpleMessage('Status')
  };
}
