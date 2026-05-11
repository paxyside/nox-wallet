import 'package:flutter_test/flutter_test.dart';
import 'package:nox/core/utils/format.dart';

void main() {
  group('formatAmount', () {
    test('returns "0" for zero values', () {
      expect(formatAmount('0'), '0');
      expect(formatAmount('0.000000'), '0');
      expect(formatAmount('0.0'), '0');
    });

    test('strips trailing zeros for integer-valued floats', () {
      expect(formatAmount('1.000000'), '1');
      expect(formatAmount('120.00'), '120');
    });

    test('rounds to maxFrac fractional digits', () {
      expect(formatAmount('0.9945336635803351'), '0.994534');
      expect(formatAmount('0.123456789'), '0.123457');
    });

    test('honours custom maxFrac', () {
      expect(formatAmount('0.123456789', maxFrac: 2), '0.12');
      expect(formatAmount('1.50000', maxFrac: 2), '1.5');
    });

    test('returns original for non-numeric strings', () {
      expect(formatAmount('<0.000001'), '<0.000001');
      expect(formatAmount('Unknown'), 'Unknown');
      expect(formatAmount(''), '');
    });

    test('preserves negative sign', () {
      expect(formatAmount('-1.500000'), '-1.5');
    });
  });

  group('timeAgo', () {
    final now = DateTime(2026, 5, 6, 12);

    test('returns "just now" for < 1 minute', () {
      expect(timeAgo(now.subtract(const Duration(seconds: 5)), now: now), 'just now');
      expect(timeAgo(now.subtract(const Duration(seconds: 59)), now: now), 'just now');
    });

    test('returns "just now" for future timestamps (clock skew)', () {
      expect(timeAgo(now.add(const Duration(seconds: 30)), now: now), 'just now');
    });

    test('returns minutes for < 1 hour', () {
      expect(timeAgo(now.subtract(const Duration(minutes: 2)), now: now), '2m ago');
      expect(timeAgo(now.subtract(const Duration(minutes: 59)), now: now), '59m ago');
    });

    test('returns hours for < 1 day', () {
      expect(timeAgo(now.subtract(const Duration(hours: 1)), now: now), '1h ago');
      expect(timeAgo(now.subtract(const Duration(hours: 23)), now: now), '23h ago');
    });

    test('returns days for < 7 days', () {
      expect(timeAgo(now.subtract(const Duration(days: 1)), now: now), '1d ago');
      expect(timeAgo(now.subtract(const Duration(days: 6)), now: now), '6d ago');
    });

    test('returns formatted date for >= 7 days', () {
      final old = DateTime(2026, 4, 20);
      expect(timeAgo(old, now: now), 'Apr 20');
    });
  });
}
