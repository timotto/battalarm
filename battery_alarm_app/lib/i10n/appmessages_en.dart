// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static m0(name) => "Do you want to use ${name} as base station?";

  static m1(max) => "This value is too high, at most ${max}.";

  static m2(min) => "This value is too low, at least ${min}.";

  @override
  final Map<String, dynamic> messages = _notInlinedMessages(_notInlinedMessages);

  static Map<String, dynamic> _notInlinedMessages(_) => {
      'aboutAppLegalese': MessageLookupByLibrary.simpleMessage('With this app you can configure the vehicle-is-in-the-garage-but-the-battery-is-not-getting-charged adapter.'),
    'aboutAppMenuItemTitle': MessageLookupByLibrary.simpleMessage('About this app'),
    'appTitle': MessageLookupByLibrary.simpleMessage('Battery alarm'),
    'beaconChangeDialogButtonNo': MessageLookupByLibrary.simpleMessage('No'),
    'beaconChangeDialogButtonYes': MessageLookupByLibrary.simpleMessage('Yes'),
    'beaconChangeDialogText': m0,
    'beaconChangeDialogTitle': MessageLookupByLibrary.simpleMessage('Change base station'),
    'beaconScanTitle': MessageLookupByLibrary.simpleMessage('Choose base station'),
    'buttonApplyValue': MessageLookupByLibrary.simpleMessage('Apply value'),
    'buttonOk': MessageLookupByLibrary.simpleMessage('OK'),
    'connected': MessageLookupByLibrary.simpleMessage('Connected'),
    'connecting': MessageLookupByLibrary.simpleMessage('Connecting...'),
    'connectionFailed': MessageLookupByLibrary.simpleMessage('Connection failed'),
    'deviceScannerError': MessageLookupByLibrary.simpleMessage('The connection was terminated'),
    'deviceScannerHint': MessageLookupByLibrary.simpleMessage('If the adapter is not found press the button on the adapter for about 5 seconds until there is a low pitched beep.'),
    'deviceScannerNoResults': MessageLookupByLibrary.simpleMessage('No adapter found'),
    'deviceScannerSearching': MessageLookupByLibrary.simpleMessage('Searching for Battalarm adapters...'),
    'disconnected': MessageLookupByLibrary.simpleMessage('Disconnected'),
    'disconnecting': MessageLookupByLibrary.simpleMessage('Disconnecting...'),
    'doubleEditDialogNotANumber': MessageLookupByLibrary.simpleMessage('This is not a number'),
    'doubleEditDialogToHigh': m1,
    'doubleEditDialogToLow': m2,
    'labelAutoTuneRssi': MessageLookupByLibrary.simpleMessage('Auto tune signal strength'),
    'labelBeacon': MessageLookupByLibrary.simpleMessage('Base station'),
    'labelBuzzerAlerts': MessageLookupByLibrary.simpleMessage('Acoustic notification for:'),
    'labelBuzzerBluetooth': MessageLookupByLibrary.simpleMessage('Bluetooth activity'),
    'labelBuzzerButton': MessageLookupByLibrary.simpleMessage('Button'),
    'labelBuzzerCharging': MessageLookupByLibrary.simpleMessage('Battery charger connected'),
    'labelBuzzerGarage': MessageLookupByLibrary.simpleMessage('Enter or leave garage'),
    'labelBuzzerHello': MessageLookupByLibrary.simpleMessage('Device powered on'),
    'labelChargingIsCharging': MessageLookupByLibrary.simpleMessage('is being charged'),
    'labelChargingIsNotCharging': MessageLookupByLibrary.simpleMessage('is not being charged'),
    'labelChargingTitle': MessageLookupByLibrary.simpleMessage('The battery'),
    'labelCurrentValue': MessageLookupByLibrary.simpleMessage('Current value'),
    'labelDelayAlert': MessageLookupByLibrary.simpleMessage('Alert delay'),
    'labelDelayWarn': MessageLookupByLibrary.simpleMessage('Warning delay'),
    'labelInGarageTile': MessageLookupByLibrary.simpleMessage('The vehicle is'),
    'labelInGarageTileInGarage': MessageLookupByLibrary.simpleMessage('in the garage'),
    'labelInGarageTileNotInGarage': MessageLookupByLibrary.simpleMessage('not in the garage'),
    'labelNoSignal': MessageLookupByLibrary.simpleMessage('No signal'),
    'labelRssi': MessageLookupByLibrary.simpleMessage('Base station signal strength in garage'),
    'labelRssiTile': MessageLookupByLibrary.simpleMessage('Base station signal strength'),
    'labelSnoozeTime': MessageLookupByLibrary.simpleMessage('Snooze time'),
    'labelVbatAlternatorThreshold': MessageLookupByLibrary.simpleMessage('Battery voltage with running engine'),
    'labelVbatChargeThreshold': MessageLookupByLibrary.simpleMessage('Battery charger end voltage'),
    'labelVbatDeltaThreshold': MessageLookupByLibrary.simpleMessage('Battery charger speed'),
    'labelVbatDeltaTile': MessageLookupByLibrary.simpleMessage('Charging speed'),
    'labelVbatLpF': MessageLookupByLibrary.simpleMessage('Battery voltage low pass factor'),
    'labelVbatTile': MessageLookupByLibrary.simpleMessage('Battery voltage'),
    'labelVbatTuneFactor': MessageLookupByLibrary.simpleMessage('Battery voltage fine tuning'),
    'menuItemExpertView': MessageLookupByLibrary.simpleMessage('Expert view'),
    'tabLabelHelp': MessageLookupByLibrary.simpleMessage('Help'),
    'tabLabelSettings': MessageLookupByLibrary.simpleMessage('Settings'),
    'tabLabelStatus': MessageLookupByLibrary.simpleMessage('Status')
  };
}
