import 'dart:math';

import 'package:battery_alarm_app/model/config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BuzzerAlertsMap', () {
    group('parse', () {
      test('parses null into null', () {
        expect(BuzzerAlerts.parse(null), isNull);
      });

      test('returns a map with all the buzzer values for any given number', () {
        final rnd = Random();
        for (int i = 0; i < 100; i++) {
          final givenNumber = rnd.nextInt(1 << 31);
          final result = BuzzerAlerts.parse(givenNumber);
          expect(result, isNotNull);
          for (var value in BuzzerAlerts.values) {
            expect(result![value], isNotNull, reason: '$value');
          }
        }
      });

      test('parses 0 into an all-false map', () {
        final result = BuzzerAlerts.parse(0);
        expect(result, isNotNull);
        for (var value in BuzzerAlerts.values) {
          expect(result![value], isFalse);
        }
      });

      test('parses 21 into garage,hello,bluetooth', () {
        final result = BuzzerAlerts.parse(21);
        expect(result, isNotNull);
        for(var value in BuzzerAlerts.values) {
          switch (value) {
            case BuzzerAlerts.garage:
            case BuzzerAlerts.hello:
            case BuzzerAlerts.bluetooth:
              expect(result![value], isTrue, reason: '$value');
              break;
            default:
              expect(result![value], isFalse, reason: '$value');
          }
        }
      });
    });
    
    group('format', (){
      test('formats null into null', (){
        expect(BuzzerAlerts.format(null), isNull);
      });

      test('formats an empty map into 0', (){
        expect(BuzzerAlerts.format(<BuzzerAlerts,bool>{}), equals(0));
      });

      test('formats an all false map into 0', (){
        final givenMap = <BuzzerAlerts,bool>{};
        for(var value in BuzzerAlerts.values) {
          givenMap[value] = false;
        }
        expect(BuzzerAlerts.format(givenMap), equals(0));
      });

      test('formats garage,hello,bluetooth into 21', (){
        final givenMap = <BuzzerAlerts,bool>{
          BuzzerAlerts.garage: true,
          BuzzerAlerts.hello: true,
          BuzzerAlerts.bluetooth: true,
        };

        expect(BuzzerAlerts.format(givenMap), equals(21));
      });
    });
  });
}
