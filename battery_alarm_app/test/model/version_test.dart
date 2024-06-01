import 'package:battery_alarm_app/model/version.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Version', () {
    final v123b4 = Version(
      major: 1,
      minor: 2,
      patch: 3,
      build: 4,
    );

    final v248b16 = Version(
      major: 2,
      minor: 4,
      patch: 8,
      build: 16,
    );

    group('operator ==', () {
      test('returns true when all components match', () {
        final match = Version(
          major: 1,
          minor: 2,
          patch: 3,
          build: 4,
        );

        expect(v123b4 == match, isTrue);

        final badMajor = Version(
          major: 10,
          minor: 2,
          patch: 3,
          build: 4,
        );

        expect(v123b4 == badMajor, isFalse);

        final badMinor = Version(
          major: 1,
          minor: 20,
          patch: 3,
          build: 4,
        );

        expect(v123b4 == badMinor, isFalse);

        final badPatch = Version(
          major: 1,
          minor: 2,
          patch: 30,
          build: 4,
        );

        expect(v123b4 == badPatch, isFalse);

        final badBuild = Version(
          major: 1,
          minor: 2,
          patch: 3,
          build: 40,
        );

        expect(v123b4 == badBuild, isFalse);
      });
    });

    group('parse', () {
      test('parse 1.2.3-build.4', () {
        expect(Version.parse('1.2.3-build.4'), equals(v123b4));
      });

      test('parse 1.2.3', () {
        expect(
            Version.parse('1.2.3'),
            equals(Version(
              major: 1,
              minor: 2,
              patch: 3,
              build: 0,
            )));
      });

      test('returns null for bad values', () {
        expect(Version.parse('1.2.a'), isNull);
      });
    });

    group('toString', () {
      test('returns all parts', () {
        expect(v248b16.toString(), equals('2.4.8-build.16'));
      });

      test('does not return build if it is 0', () {
        expect(
            Version(
              major: 3,
              minor: 5,
              patch: 8,
              build: 0,
            ).toString(),
            equals('3.5.8'));
      });
    });

    group('compare', () {
      test('returns 0 when both are the same', () {
        final same = Version(
          major: 2,
          minor: 4,
          patch: 8,
          build: 16,
        );

        expect(v248b16.compare(same), equals(0));
      });

      test('returns -1 when the other version is later', () {
        expect(
            v248b16.compare(Version(
              major: 3,
              minor: 0,
              patch: 0,
              build: 0,
            )),
            equals(-1));

        expect(
            v248b16.compare(Version(
              major: 2,
              minor: 5,
              patch: 0,
              build: 0,
            )),
            equals(-1));

        expect(
            v248b16.compare(Version(
              major: 2,
              minor: 4,
              patch: 9,
              build: 0,
            )),
            equals(-1));

        expect(
            v248b16.compare(Version(
              major: 2,
              minor: 4,
              patch: 8,
              build: 17,
            )),
            equals(-1));
      });

      test('returns 1 when this version is later', () {
        expect(
            v248b16.compare(Version(
              major: 1,
              minor: 100,
              patch: 100,
              build: 100,
            )),
            equals(1));

        expect(
            v248b16.compare(Version(
              major: 2,
              minor: 3,
              patch: 100,
              build: 100,
            )),
            equals(1));

        expect(
            v248b16.compare(Version(
              major: 2,
              minor: 4,
              patch: 7,
              build: 100,
            )),
            equals(1));

        expect(
            v248b16.compare(Version(
              major: 2,
              minor: 4,
              patch: 8,
              build: 15,
            )),
            equals(1));
      });
    });

    group('isBetterThan', () {
      test('returns true if this version is later than the other', () {
        expect(v248b16.isBetterThan(v123b4), isTrue);
      });

      test('returns false if the other version is later than this', () {
        expect(v123b4.isBetterThan(v248b16), isFalse);
      });

      test('returns false if the other version is the same as this', () {
        expect(
            v123b4.isBetterThan(Version(
              major: 1,
              minor: 2,
              patch: 3,
              build: 4,
            )),
            isFalse);
      });
    });
  });
}
