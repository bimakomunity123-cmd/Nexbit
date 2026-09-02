import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/trading/domain/models/trading_pair.dart';

void main() {
  group('formatPrice', () {
    test('formats a whole IDR number with dot thousands separators', () {
      expect(formatPrice(1149869827, 0), '1.149.869.827');
    });

    test('formats small integers without a thousands separator', () {
      expect(formatPrice(500, 0), '500');
    });

    test('formats decimals with a comma', () {
      expect(formatPrice(1.085, 4), '1,0850');
    });

    test('formats a negative value with a leading minus', () {
      expect(formatPrice(-2650.4, 2), '-2.650,40');
    });

    test('formats zero', () {
      expect(formatPrice(0, 0), '0');
    });
  });

  group('parsePriceInput', () {
    test('round-trips whatever formatPrice produced, whole numbers', () {
      const value = 1149869827.0;
      expect(parsePriceInput(formatPrice(value, 0)), value);
    });

    test('round-trips whatever formatPrice produced, with decimals', () {
      const value = 2650.4;
      expect(parsePriceInput(formatPrice(value, 2)), closeTo(value, 0.001));
    });

    test('strips dot thousands separators before reading the comma decimal', () {
      expect(parsePriceInput('1.234.567,89'), closeTo(1234567.89, 0.001));
    });

    test('returns 0 for an empty or unparseable string', () {
      expect(parsePriceInput(''), 0);
      expect(parsePriceInput('not a number'), 0);
    });
  });
}
