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

  static m0(name) => "Möchtest du ${name} als Basisstation verwenden?";

  static m1(max) => "Die Eingabe ist zu hoch, höchstens ${max}.";

  static m2(min) => "Die Eingabe ist zu niedrig, mindestens ${min}.";

  static m3(code) => "Adapter Fehler Code: ${code}";

  static m4(version) => "Adapter Version: ${version}";

  static m5(version) => "Adapter Version: ${version}";

  static m6(code) => "Fehler Code: ${code}";

  static m7(version) => "Adapter Software Version ${version} ist verfügbar!";

  @override
  final Map<String, dynamic> messages = _notInlinedMessages(_notInlinedMessages);

  static Map<String, dynamic> _notInlinedMessages(_) => {
      'aboutAppLegalese': MessageLookupByLibrary.simpleMessage('Mit dieser App kannst du den Fahrzeug-in-der-Garage-aber-Batterie-wird-nicht-geladen-Alarm-Adapter einstellen.'),
    'aboutAppMenuItemTitle': MessageLookupByLibrary.simpleMessage('Über die App'),
    'appTitle': MessageLookupByLibrary.simpleMessage('Batterie Alarm'),
    'beaconChangeDialogButtonNo': MessageLookupByLibrary.simpleMessage('Nein'),
    'beaconChangeDialogButtonYes': MessageLookupByLibrary.simpleMessage('Ja'),
    'beaconChangeDialogText': m0,
    'beaconChangeDialogTitle': MessageLookupByLibrary.simpleMessage('Basisstation wechseln'),
    'beaconScanTitle': MessageLookupByLibrary.simpleMessage('Basisstation wählen'),
    'buttonApplyValue': MessageLookupByLibrary.simpleMessage('Wert übernehmen'),
    'buttonCancel': MessageLookupByLibrary.simpleMessage('Abbrechen'),
    'buttonOk': MessageLookupByLibrary.simpleMessage('OK'),
    'buttonUpdateAdapter': MessageLookupByLibrary.simpleMessage('Adapter aktualisieren'),
    'connected': MessageLookupByLibrary.simpleMessage('Verbunden'),
    'connecting': MessageLookupByLibrary.simpleMessage('Verbinde...'),
    'connectionFailed': MessageLookupByLibrary.simpleMessage('Verbindung Fehlgeschlagen'),
    'deviceScannerError': MessageLookupByLibrary.simpleMessage('Die Verbindung wurde unterbrochen.'),
    'deviceScannerHint': MessageLookupByLibrary.simpleMessage('Wenn der Adapter nicht gefunden wird, dann halte den Knopf am Adapter für ca. 5 Sekunden lang gedrückt, bis ein tiefer Piepton kommt.'),
    'deviceScannerNoResults': MessageLookupByLibrary.simpleMessage('Keine Adapter gefunden'),
    'deviceScannerSearching': MessageLookupByLibrary.simpleMessage('Suche nach Battalarm Adaptern...'),
    'disconnected': MessageLookupByLibrary.simpleMessage('Getrennt'),
    'disconnecting': MessageLookupByLibrary.simpleMessage('Trennen...'),
    'doubleEditDialogNotANumber': MessageLookupByLibrary.simpleMessage('Das ist keine Zahl 🤦'),
    'doubleEditDialogToHigh': m1,
    'doubleEditDialogToLow': m2,
    'labelAdapterErrorCode': m3,
    'labelAdapterVersion': m4,
    'labelAutoTuneRssi': MessageLookupByLibrary.simpleMessage('Signalstärke automatisch anpassen'),
    'labelBeacon': MessageLookupByLibrary.simpleMessage('Basisstation'),
    'labelBuzzerAlerts': MessageLookupByLibrary.simpleMessage('Akkustische Benachrichtigung bei:'),
    'labelBuzzerBluetooth': MessageLookupByLibrary.simpleMessage('Bluetooth Aktivität'),
    'labelBuzzerButton': MessageLookupByLibrary.simpleMessage('Knopf am Gerät'),
    'labelBuzzerCharging': MessageLookupByLibrary.simpleMessage('Batterieladegerät angeschlossen'),
    'labelBuzzerGarage': MessageLookupByLibrary.simpleMessage('Garage betreten oder verlassen'),
    'labelBuzzerHello': MessageLookupByLibrary.simpleMessage('Begrüßung'),
    'labelChargingIsCharging': MessageLookupByLibrary.simpleMessage('wird geladen'),
    'labelChargingIsNotCharging': MessageLookupByLibrary.simpleMessage('wird nicht geladen'),
    'labelChargingTitle': MessageLookupByLibrary.simpleMessage('Die Batterie'),
    'labelCurrentAdapterVersion': m5,
    'labelCurrentValue': MessageLookupByLibrary.simpleMessage('Aktueller Wert'),
    'labelDelayAlert': MessageLookupByLibrary.simpleMessage('Verzögerung bis zum Alarm'),
    'labelDelayWarn': MessageLookupByLibrary.simpleMessage('Verzögerung bis zur Warnung'),
    'labelDownloadUpdateError': MessageLookupByLibrary.simpleMessage('Es gab ein Problem beim Herunterladen des Updates. Probiere es später bitte nochmal.'),
    'labelDownloadingUpdate': MessageLookupByLibrary.simpleMessage('Update wird heruntergeladen...'),
    'labelErrorCode': m6,
    'labelInGarageTile': MessageLookupByLibrary.simpleMessage('Das Fahrzeug befindet sich'),
    'labelInGarageTileInGarage': MessageLookupByLibrary.simpleMessage('in der Garage'),
    'labelInGarageTileNotInGarage': MessageLookupByLibrary.simpleMessage('nicht in der Garage'),
    'labelNoSignal': MessageLookupByLibrary.simpleMessage('Kein Empfang'),
    'labelNoUpdateAvailable': MessageLookupByLibrary.simpleMessage('Es ist kein Update verfügbar.'),
    'labelRssi': MessageLookupByLibrary.simpleMessage('Basisstation Signalstärke in Garage'),
    'labelRssiTile': MessageLookupByLibrary.simpleMessage('Signalstärke Basisstation'),
    'labelSearchingUpdates': MessageLookupByLibrary.simpleMessage('Suche nach verfügbaren updates...'),
    'labelShowBetaVersion': MessageLookupByLibrary.simpleMessage('Zeige Beta Versionen'),
    'labelSnoozeTime': MessageLookupByLibrary.simpleMessage('Snooze time'),
    'labelUpdateAvailable': m7,
    'labelUpdateCheckFailed': MessageLookupByLibrary.simpleMessage('Es gab ein Problem prüfen auf verfügbare Updates. Überprüfe deine Internetverbindung und probiere es noch einmal.'),
    'labelUpdateDownloadFailed': MessageLookupByLibrary.simpleMessage('Es gab ein Problem herunterladen des Updates. Überprüfe deine Internetverbindung und probiere es noch einmal.'),
    'labelUpdateFailed': MessageLookupByLibrary.simpleMessage('Es gab ein Problem beim aktualisieren des Adapters. Trenne ihn bitte vom Strom, warte einen Moment, stecke ihn dann wieder ein und probiere es noch einmal.'),
    'labelUpdateSuccess': MessageLookupByLibrary.simpleMessage('Das Update des Adapters war erfolgreich. Er wird in kürze neu starten.'),
    'labelVbatAlternatorThreshold': MessageLookupByLibrary.simpleMessage('Batteriespannung bei laufendem Motor'),
    'labelVbatChargeThreshold': MessageLookupByLibrary.simpleMessage('Batterieladegerät Endspannung'),
    'labelVbatDeltaThreshold': MessageLookupByLibrary.simpleMessage('Batterieladegerät Geschwindigkeit'),
    'labelVbatDeltaTile': MessageLookupByLibrary.simpleMessage('Ladungsveränderung'),
    'labelVbatLpF': MessageLookupByLibrary.simpleMessage('Batteriespannung Tiefpass Faktor'),
    'labelVbatTile': MessageLookupByLibrary.simpleMessage('Batteriespannung'),
    'labelVbatTuneFactor': MessageLookupByLibrary.simpleMessage('Batteriespannung Feinjustierung'),
    'labelWritingUpdate': MessageLookupByLibrary.simpleMessage('Sende das Update an den Adapter...'),
    'menuItemExpertView': MessageLookupByLibrary.simpleMessage('Experten Ansicht'),
    'menuItemUpdateAdapterFirmware': MessageLookupByLibrary.simpleMessage('Adapter Update'),
    'otaDialogTitle': MessageLookupByLibrary.simpleMessage('Firmware Update'),
    'tabLabelHelp': MessageLookupByLibrary.simpleMessage('Hilfe'),
    'tabLabelSettings': MessageLookupByLibrary.simpleMessage('Einstellungen'),
    'tabLabelStatus': MessageLookupByLibrary.simpleMessage('Status')
  };
}
