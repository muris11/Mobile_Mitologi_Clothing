import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/models/money.dart';

void main() {
  group('Money Tests', () {
    test('creates Money with default currency', () {
      final money = Money(amount: 100000);

      expect(money.amount, 100000);
      expect(money.currencyCode, 'IDR'); // default
      expect(money.currencySymbol, null); // default
    });

    test('creates Money with all fields', () {
      final money = Money(
        amount: 50000,
        currencyCode: 'USD',
        currencySymbol: r'$',
      );

      expect(money.amount, 50000);
      expect(money.currencyCode, 'USD');
      expect(money.currencySymbol, r'$');
    });

    test('creates Money with zero amount', () {
      final money = Money(amount: 0);

      expect(money.amount, 0);
    });

    test('creates Money with negative amount', () {
      final money = Money(amount: -10000);

      expect(money.amount, -10000);
    });

    group('fromJson Tests', () {
      test('parses from num (int)', () {
        final money = Money.fromJson(100000);

        expect(money.amount, 100000);
        expect(money.currencyCode, 'IDR'); // default
      });

      test('parses from num (double)', () {
        final money = Money.fromJson(100000.50);

        expect(money.amount, 100000.50);
      });

      test('parses from Map with complete data', () {
        final json = {
          'amount': 250000,
          'currency_code': 'IDR',
          'currency_symbol': 'Rp',
        };

        final money = Money.fromJson(json);

        expect(money.amount, 250000);
        expect(money.currencyCode, 'IDR');
        expect(money.currencySymbol, 'Rp');
      });

      test('parses from Map with default currency_code', () {
        final json = {
          'amount': 100000,
        };

        final money = Money.fromJson(json);

        expect(money.amount, 100000);
        expect(money.currencyCode, 'IDR');
        expect(money.currencySymbol, null);
      });

      test('parses from Map with null currency_symbol', () {
        final json = {
          'amount': 100000,
          'currency_code': 'USD',
          'currency_symbol': null,
        };

        final money = Money.fromJson(json);

        expect(money.amount, 100000);
        expect(money.currencyCode, 'USD');
        expect(money.currencySymbol, null);
      });

      test('returns zero Money for null', () {
        final money = Money.fromJson(null);

        expect(money.amount, 0);
        expect(money.currencyCode, 'IDR');
      });

      test('returns zero Money for invalid type', () {
        final money = Money.fromJson('invalid');

        expect(money.amount, 0);
        expect(money.currencyCode, 'IDR');
      });

      test('parses zero amount', () {
        final money = Money.fromJson(0);

        expect(money.amount, 0);
      });

      test('parses negative amount', () {
        final money = Money.fromJson(-50000);

        expect(money.amount, -50000);
      });
    });

    group('toJson Tests', () {
      test('converts to JSON correctly', () {
        final money = Money(
          amount: 100000,
          currencyCode: 'IDR',
          currencySymbol: 'Rp',
        );

        final json = money.toJson();

        expect(json['amount'], 100000);
        expect(json['currency_code'], 'IDR');
        expect(json['currency_symbol'], 'Rp');
      });

      test('converts Money with null symbol to JSON', () {
        final money = Money(amount: 50000);

        final json = money.toJson();

        expect(json['amount'], 50000);
        expect(json['currency_code'], 'IDR');
        expect(json['currency_symbol'], null);
      });
    });

    group('formatted Tests', () {
      test('formats IDR with default symbol', () {
        final money = Money(amount: 100000);

        expect(money.formatted, 'Rp 100.000');
      });

      test('formats with custom symbol', () {
        final money = Money(
          amount: 50,
          currencyCode: 'USD',
          currencySymbol: r'$',
        );

        expect(money.formatted, r'$ 50');
      });

      test('formats zero amount', () {
        final money = Money(amount: 0);

        expect(money.formatted, 'Rp 0');
      });

      test('formats large amount with thousand separators', () {
        final money = Money(amount: 1250000);

        expect(money.formatted, 'Rp 1.250.000');
      });

      test('formats millions correctly', () {
        final money = Money(amount: 5000000);

        expect(money.formatted, 'Rp 5.000.000');
      });

      test('formats billions correctly', () {
        final money = Money(amount: 1500000000);

        expect(money.formatted, 'Rp 1.500.000.000');
      });

      test('formats with rounding', () {
        final money = Money(amount: 100000.50);

        expect(money.formatted, 'Rp 100.001'); // rounded
      });

      test('formats negative amount', () {
        final money = Money(amount: -50000);

        expect(money.formatted, 'Rp -50.000');
      });
    });

    group('toString Tests', () {
      test('toString returns formatted value', () {
        final money = Money(amount: 100000);

        expect(money.toString(), 'Rp 100.000');
      });

      test('toString matches formatted getter', () {
        final money = Money(amount: 250000);

        expect(money.toString(), money.formatted);
      });
    });
  });
}
