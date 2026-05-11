import 'package:flutter_test/flutter_test.dart';
import 'package:nox/core/utils/formatters.dart';

void main() {
  group('parseUsd', () {
    test('strips dollar sign and commas', () {
      expect(parseUsd(r'$1,234.56'), 1234.56);
    });

    test('handles negative values', () {
      expect(parseUsd(r'-$0.5'), -0.5);
    });

    test('returns 0 on empty string', () {
      expect(parseUsd(''), 0);
    });

    test('returns 0 on garbage', () {
      expect(parseUsd('abc'), 0);
    });

    test('handles plain number', () {
      expect(parseUsd('42.42'), 42.42);
    });
  });

  group('parseAmount', () {
    test('strips non-digit non-dot chars', () {
      expect(parseAmount('1,234.56 ETH'), 1234.56);
    });

    test('returns 0 on garbage', () {
      expect(parseAmount('not a number'), 0);
    });
  });

  group('formatEth', () {
    test('trims trailing zeros to one decimal', () {
      expect(formatEth('1.500000'), '1.5');
    });

    test('keeps integer with .0 suffix', () {
      expect(formatEth('5'), '5.0');
    });

    test('preserves significant decimals', () {
      expect(formatEth('0.000123'), '0.000123');
    });

    test('returns input unchanged on parse failure', () {
      expect(formatEth('xyz'), 'xyz');
    });
  });

  group('formatAmountCompact', () {
    test('rounds to 4 decimals for >= 1', () {
      expect(formatAmountCompact('12.34567'), '12.3457');
    });

    test('rounds to 6 decimals for 0.0001..1', () {
      expect(formatAmountCompact('0.000419624520260639'), '0.00042');
    });

    test('rounds to 8 decimals for very small values', () {
      expect(formatAmountCompact('0.00000012345'), '0.00000012');
    });

    test('drops trailing zeros and trailing dot', () {
      expect(formatAmountCompact('1.5000'), '1.5');
      expect(formatAmountCompact('100.0000'), '100');
    });

    test('zero returns "0"', () {
      expect(formatAmountCompact('0'), '0');
    });

    test('parse failure returns input unchanged', () {
      expect(formatAmountCompact('abc'), 'abc');
    });
  });

  group('formatTokenAmount', () {
    test('returns empty string for zero', () {
      expect(formatTokenAmount(0), '');
    });

    test('trims trailing zeros and trailing dot', () {
      expect(formatTokenAmount(1.5), '1.5');
    });

    test('handles tiny values with up to 8 decimals', () {
      expect(formatTokenAmount(0.00000015), '0.00000015');
    });
  });

  group('formatUsd', () {
    test('uses k suffix for >= 1000', () {
      expect(formatUsd(1500), r'$1.5k');
    });

    test('two decimals for >=1', () {
      // toStringAsFixed rounds half-up: 12.345 -> 12.35
      expect(formatUsd(12.34), r'$12.34');
    });

    test('four decimals for <1', () {
      expect(formatUsd(0.1234), r'$0.1234');
    });
  });

  group('formatPercent', () {
    test('formats fraction as percent with one decimal', () {
      expect(formatPercent(0.1234), '12.3%');
    });

    test('handles zero', () {
      expect(formatPercent(0), '0.0%');
    });
  });

  group('shortAddress', () {
    test('truncates long address', () {
      expect(
        shortAddress('0x1234567890abcdef1234567890abcdef12345678'),
        '0x1234…5678',
      );
    });

    test('returns original if shorter than head+tail', () {
      expect(shortAddress('0x1234'), '0x1234');
    });

    test('respects custom head and tail', () {
      expect(
        shortAddress(
          '0xabcdefghijklmnop',
          head: 4,
          tail: 4,
        ),
        '0xab…mnop',
      );
    });
  });
}
