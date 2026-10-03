import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/models/currency.dart';
import 'package:kakeibo/util/money.dart';

void main() {
  group('formatFils', () {
    test('formats three decimals with symbol', () {
      expect(formatFils(12750), 'KD 12.750');
      expect(formatFils(500), 'KD 0.500');
      expect(formatFils(0), 'KD 0.000');
      expect(formatFils(5), 'KD 0.005');
    });

    test('groups thousands', () {
      expect(formatFils(1234500), 'KD 1,234.500');
      expect(formatFils(1000000000), 'KD 1,000,000.000');
    });

    test('negative amounts', () {
      expect(formatFils(-12750), '-KD 12.750');
    });

    test('without symbol and for input fields', () {
      expect(formatFils(1234500, withSymbol: false), '1,234.500');
      expect(filsToInput(1234500), '1234.500');
    });
  });

  group('parseFils', () {
    test('accepts common forms', () {
      expect(parseFils('12.750'), 12750);
      expect(parseFils('12.75'), 12750);
      expect(parseFils('12.7'), 12700);
      expect(parseFils('12'), 12000);
      expect(parseFils('12.'), 12000);
      expect(parseFils('.5'), 500);
      expect(parseFils('0.005'), 5);
      expect(parseFils(' 1,234.5 '), 1234500);
      expect(parseFils('KD 3.250'), 3250);
      expect(parseFils('kd3'), 3000);
    });

    test('accepts Arabic-Indic digits', () {
      expect(parseFils('١٢٫٧٥٠'), 12750);
      expect(parseFils('۳'), 3000);
    });

    test('rejects invalid input', () {
      expect(parseFils(''), isNull);
      expect(parseFils('.'), isNull);
      expect(parseFils('abc'), isNull);
      expect(parseFils('-5'), isNull);
      expect(parseFils('1.2345'), isNull);
      expect(parseFils('1.2.3'), isNull);
      expect(parseFils('1234567890'), isNull);
    });

    test('round-trips with formatFils', () {
      for (final fils in [0, 5, 500, 12750, 1234500, 999999999999]) {
        expect(parseFils(formatFils(fils)), fils);
      }
    });
  });

  group('applyAmountKey', () {
    String type(List<String> keys) => keys.fold('', applyAmountKey);

    test('builds typical amounts', () {
      expect(type(['.', '5']), '0.5');
      expect(type(['1', '2', '.', '7', '5']), '12.75');
    });

    test('limits to three decimals and one point', () {
      expect(type(['1', '.', '2', '3', '4', '5']), '1.234');
      expect(type(['1', '.', '.', '2']), '1.2');
    });

    test('drops leading zeros', () {
      expect(type(['0', '0', '7']), '7');
      expect(type(['0', '.', '5']), '0.5');
    });

    test('backspace and length limit', () {
      expect(type(['1', '2', backspaceKey]), '1');
      expect(type([backspaceKey]), '');
      expect(type(List.filled(12, '9')), '999999999');
    });
  });

  group('other currencies', () {
    final usd = Currency.byCode('USD');
    final jpy = Currency.byCode('JPY');
    final bhd = Currency.byCode('BHD');

    test('format with the currency symbol and decimals', () {
      expect(formatFils(12750, currency: usd), '\$ 12.75');
      expect(formatFils(12755, currency: usd), '\$ 12.76'); // rounds half up
      expect(formatFils(1234500, currency: usd), '\$ 1,234.50');
      expect(formatFils(1250000, currency: jpy), '¥ 1,250');
      expect(formatFils(12750, currency: bhd), 'BD 12.750');
      expect(formatFils(-12750, currency: usd), '-\$ 12.75');
      expect(formatFils(-4, currency: usd), '\$ 0.00');
      expect(filsToInput(1234500, currency: usd), '1234.50');
    });

    test('parse respects the allowed decimals', () {
      expect(parseFils('12.75', currency: usd), 12750);
      expect(parseFils('\$12.75', currency: usd), 12750);
      expect(parseFils('USD 3', currency: usd), 3000);
      expect(parseFils('12.755', currency: usd), isNull);
      expect(parseFils('1250', currency: jpy), 1250000);
      expect(parseFils('12.5', currency: jpy), isNull);
      expect(parseFils('12.', currency: jpy), isNull);
    });

    test('keypad follows the decimals', () {
      String type(List<String> keys, int decimals) =>
          keys.fold('', (t, k) => applyAmountKey(t, k, decimals: decimals));
      expect(type(['1', '.', '2', '3', '4'], 2), '1.23');
      expect(type(['1', '.', '2'], 0), '12');
    });

    test('example amounts', () {
      expect(exampleAmount(Currency.kwd), '12.750');
      expect(exampleAmount(usd), '12.50');
      expect(exampleAmount(jpy), '1250');
      for (final c in [Currency.kwd, usd, jpy]) {
        expect(parseFils(exampleAmount(c), currency: c), isNotNull);
      }
    });

    test('currency table is sane', () {
      final codes = [for (final c in Currency.all) c.code];
      expect(codes.toSet().length, codes.length);
      expect(Currency.all.every((c) => const {0, 2, 3}.contains(c.decimals)), isTrue);
      expect(Currency.byCode('nope'), Currency.kwd);
    });
  });
}
