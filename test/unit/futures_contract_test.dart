import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/futures/domain/models/futures_contract.dart';

void main() {
  group('formatUsdt', () {
    test('formats a whole number with comma thousands separators', () {
      expect(formatUsdt(70000, 2), '70,000.00');
    });

    test('formats a number under 1,000 without a thousands separator', () {
      expect(formatUsdt(500, 2), '500.00');
    });

    test('formats zero decimals when asked', () {
      expect(formatUsdt(70000, 0), '70,000');
    });

    test('formats a negative value with a leading minus', () {
      expect(formatUsdt(-1234.5, 2), '-1,234.50');
    });
  });
}
