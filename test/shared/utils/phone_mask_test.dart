import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/shared/utils/phone_mask.dart';

void main() {
  group('maskPhone', () {
    test('masks a standard E.164 number to last 4 digits', () {
      expect(maskPhone('+256701234567'), '***4567');
    });

    test('masks a number with spaces', () {
      expect(maskPhone('+256 701 234 567'), '***4567');
    });

    test('returns *** for a number shorter than 4 digits', () {
      expect(maskPhone('12'), '***');
    });

    test('re-masking an already-masked string stays masked', () {
      expect(maskPhone('***1234'), '***1234');
    });

    test('handles a bare local number without a country code', () {
      expect(maskPhone('0701234567'), '***4567');
    });
  });
}
