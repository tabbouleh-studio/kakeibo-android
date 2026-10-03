import 'package:flutter_test/flutter_test.dart';
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
}
