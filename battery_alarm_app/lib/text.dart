import 'package:intl/intl.dart';

class Texts {
  Texts._();

  static const helpPageTexts = [
    'Mit dieser App kannst du den Fahrzeug-in-der-Garage-aber-Batterie-wird-nicht-geladen-Alarm-Adapter einstellen.',
    'Damit der Adapter zuverlässig erkennt, dass das Fahrzeug in der Garage steht, sollte die Signalstärke der Basisstation innerhalb der Garage stärker sein als vor der Garage. Daher sollte die Basisstation besser nicht in der Nähe vom Garagentor montiert werden.',
    'Mit der Experten Ansicht lassen sich die Messwerte des Adapters feinjustieren. Das ist hilfreich, wenn du dir einen Adapter selber gebaut hast.',
    'Den Source Code vom Adapter, sowie alle weiteren Informationen um dir selber einen zu bauen, findest du unter https://github.com/timotto/battalarm',
  ];

  static String appTitle() => Intl.message(
        'Batterie Alarm',
        name: 'appTitle',
      );

  static String beaconScanTitle() => Intl.message(
        'Basisstation wählen',
        name: 'beaconScanTitle',
      );

  static String aboutAppMenuItemTitle() => Intl.message(
        'Über die App',
        name: 'aboutAppMenuItemTitle',
      );

  static String aboutAppLegalese() => Intl.message(
        'Mit dieser App kannst du den Fahrzeug-in-der-Garage-aber-Batterie-wird-nicht-geladen-Alarm-Adapter einstellen.',
        name: 'aboutAppLegalese',
      );

  static String connectionFailed() => Intl.message(
        'Verbindung Fehlgeschlagen',
        name: 'connectionFailed',
        desc: 'Alert the user of a failed connection',
      );

  static String connecting() => Intl.message(
        'Verbinde...',
        name: 'connecting',
        desc: 'Notify the user of a connection being established',
        args: [],
      );

  static String connected() => Intl.message(
        'Verbunden',
        name: 'connected',
        desc: 'Notify the user of an established connection',
        args: [],
      );

  static String disconnecting() => Intl.message(
        'Trennen...',
        name: 'disconnecting',
        desc: 'Notify the user of the connection being disconnected',
        args: [],
      );

  static String disconnected() => Intl.message(
        'Getrennt',
        name: 'disconnected',
        desc: 'Notify the user of the disconnected connection',
        args: [],
      );

  static String labelDelayWarn() => Intl.message(
        'Verzögerung bis zur Warnung',
        name: 'labelDelayWarn',
        desc: 'Label for the property "delay until warning"',
      );

  static String labelDelayAlert() => Intl.message(
        'Verzögerung bis zum Alarm',
        name: 'labelDelayAlert',
        desc: 'Label for the property "delay until alert"',
      );

  static String labelSnoozeTime() => Intl.message(
        'Snooze time',
        name: 'labelSnoozeTime',
        desc: 'Lable for the property "snooze time',
      );

  static String labelRssi() => Intl.message(
        'Basisstation Signalstärke in Garage',
        name: 'labelRssi',
        desc: 'Label for the property "current signal strength"',
      );

  static String labelNoSignal() => Intl.message(
        'Kein Empfang',
        name: 'labelNoSignal',
        desc: 'Displayed instead of a value when there is no signal.',
      );

  static String labelAutoTuneRssi() => Intl.message(
        'Signalstärke automatisch anpassen',
        name: 'labelAutoTuneRssi',
        desc: 'Label for the property "auto adjust signal strength threshold"',
      );

  static String labelVbatChargeThreshold() => Intl.message(
        'Batterieladegerät Endspannung',
        name: 'labelVbatChargeThreshold',
        desc:
            'Label for the property "vbat threshold indicating active charging"',
      );

  static String labelVbatAlternatorThreshold() => Intl.message(
        'Batteriespannung bei laufendem Motor',
        name: 'labelVbatAlternatorThreshold',
        desc:
            'Label for the property "vbat alternator threshold indicating running engine"',
      );

  static String labelVbatDeltaThreshold() => Intl.message(
        'Batterieladegerät Geschwindigkeit',
        name: 'labelVbatDeltaThreshold',
        desc:
            'Label for the property "vbat delta threshold indicating charging"',
      );

  static String labelVbatTuneFactor() => Intl.message(
        'Batteriespannung Feinjustierung',
        name: 'labelVbatTuneFactor',
        desc: 'Label for the property "vbat fine adjustment"',
      );

  static String labelVbatLpF() => Intl.message(
        'Batteriespannung Tiefpass Faktor',
        name: 'labelVbatLpF',
        desc: 'Label for the property "vbat low pass filter"',
      );

  static String labelBuzzerAlerts() => Intl.message(
        'Akkustische Benachrichtigung bei:',
        name: 'labelBuzzerAlerts',
        desc: 'Label for the property "accoustic notifications"',
      );

  static String labelBuzzerGarage() => Intl.message(
        'Garage betreten oder verlassen',
        name: 'labelBuzzerGarage',
      );

  static String labelBuzzerCharging() => Intl.message(
        'Batterieladegerät angeschlossen',
        name: 'labelBuzzerCharging',
      );

  static String labelBuzzerHello() => Intl.message(
        'Begrüßung',
        name: 'labelBuzzerHello',
      );

  static String labelBuzzerButton() => Intl.message(
        'Knopf am Gerät',
        name: 'labelBuzzerButton',
      );

  static String labelBuzzerBluetooth() => Intl.message(
        'Bluetooth Aktivität',
        name: 'labelBuzzerBluetooth',
      );

  static String menuItemExpertView() => Intl.message(
        'Experten Ansicht',
        name: 'menuItemExpertView',
      );

  static String tabLabelStatus() => Intl.message(
        'Status',
        name: 'tabLabelStatus',
      );

  static String tabLabelSettings() => Intl.message(
        'Einstellungen',
        name: 'tabLabelSettings',
      );

  static String tabLabelHelp() => Intl.message(
        'Hilfe',
        name: 'tabLabelHelp',
      );

  static String deviceScannerHint() => Intl.message(
        'Wenn der Adapter nicht gefunden wird, dann halte den Knopf am Adapter für ca. 5 Sekunden lang gedrückt, bis ein tiefer Piepton kommt.',
        name: 'deviceScannerHint',
      );

  static String deviceScannerSearching() => Intl.message(
        'Suche nach Battalarm Adaptern...',
        name: 'deviceScannerSearching',
      );

  static String deviceScannerNoResults() => Intl.message(
        'Keine Adapter gefunden',
        name: 'deviceScannerNoResults',
      );

  static String deviceScannerError() => Intl.message(
        'Die Verbindung wurde unterbrochen.',
        name: 'deviceScannerError',
      );

  static String labelBeacon() => Intl.message(
        'Basisstation',
        name: 'labelBeacon',
      );

  static String labelChargingTitle() => Intl.message(
        'Die Batterie',
        name: 'labelChargingTitle',
      );

  static String labelChargingIsCharging() => Intl.message(
        'wird geladen',
        name: 'labelChargingIsCharging',
      );

  static String labelChargingIsNotCharging() => Intl.message(
        'wird nicht geladen',
        name: 'labelChargingIsNotCharging',
      );

  static String buttonOk() => Intl.message(
        'OK',
        name: 'buttonOk',
      );

  static String buttonApplyValue() => Intl.message(
        'Wert übernehmen',
        name: 'buttonApplyValue',
      );

  static String labelCurrentValue() => Intl.message(
        'Aktueller Wert',
        name: 'labelCurrentValue',
      );

  static String doubleEditDialogNotANumber() => Intl.message(
        'Das ist keine Zahl 🤦',
        name: 'doubleEditDialogNotANumber',
      );

  static String doubleEditDialogToLow(String min) => Intl.message(
        'Die Eingabe ist zu niedrig, mindestens $min.',
        name: 'doubleEditDialogToLow',
        args: [min],
      );

  static String doubleEditDialogToHigh(String max) => Intl.message(
        'Die Eingabe ist zu hoch, höchstens $max.',
        name: 'doubleEditDialogToHigh',
        args: [max],
      );

  static String labelInGarageTile() => Intl.message(
        'Das Fahrzeug befindet sich',
        name: 'labelInGarageTile',
      );

  static String labelInGarageTileInGarage() => Intl.message(
        'in der Garage',
        name: 'labelInGarageTileInGarage',
      );

  static String labelInGarageTileNotInGarage() => Intl.message(
        'nicht in der Garage',
        name: 'labelInGarageTileNotInGarage',
      );

  static String labelRssiTile() => Intl.message(
        'Signalstärke Basisstation',
        name: 'labelRssiTile',
      );

  static String labelVbatDeltaTile() => Intl.message(
        'Ladungsveränderung',
        name: 'labelVbatDeltaTile',
      );

  static String labelVbatTile() => Intl.message(
        'Batteriespannung',
        name: 'labelVbatTile',
      );

  static String beaconChangeDialogTitle() => Intl.message(
        'Basisstation wechseln',
        name: 'beaconChangeDialogTitle',
      );

  static String beaconChangeDialogText(String name) => Intl.message(
        'Möchtest du $name als Basisstation verwenden?',
        name: 'beaconChangeDialogText',
        args: [name],
      );

  static String beaconChangeDialogButtonYes() => Intl.message(
        'Ja',
        name: 'beaconChangeDialogButtonYes',
      );

  static String beaconChangeDialogButtonNo() => Intl.message(
        'Nein',
        name: 'beaconChangeDialogButtonNo',
      );
}
