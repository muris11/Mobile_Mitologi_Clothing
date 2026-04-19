import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/models/shipping_rate.dart';

void main() {
  group('ShippingRate Tests', () {
    test('creates ShippingRate with default values', () {
      final rate = ShippingRate(
        cost: 15000,
        method: 'JNE Regular',
      );

      expect(rate.cost, 15000);
      expect(rate.method, 'JNE Regular');
      expect(rate.estimatedDays, null);
      expect(rate.available, true);
    });

    test('creates ShippingRate with all values', () {
      final rate = ShippingRate(
        cost: 25000,
        method: 'JNE YES',
        estimatedDays: '1-2 hari',
        available: true,
      );

      expect(rate.cost, 25000);
      expect(rate.method, 'JNE YES');
      expect(rate.estimatedDays, '1-2 hari');
      expect(rate.available, true);
    });

    test('creates unavailable ShippingRate', () {
      final rate = ShippingRate(
        cost: 0,
        method: 'Not Available',
        available: false,
      );

      expect(rate.available, false);
    });

    group('fromJson Tests', () {
      test('parses complete JSON correctly', () {
        final json = {
          'cost': 15000,
          'method': 'JNE Regular',
          'estimated_days': '2-3 hari',
          'available': true,
        };

        final rate = ShippingRate.fromJson(json);

        expect(rate.cost, 15000);
        expect(rate.method, 'JNE Regular');
        expect(rate.estimatedDays, '2-3 hari');
        expect(rate.available, true);
      });

      test('parses JSON with null values using defaults', () {
        final json = {
          'cost': null,
          'method': null,
          'estimated_days': null,
          'available': null,
        };

        final rate = ShippingRate.fromJson(json);

        expect(rate.cost, 0.0);
        expect(rate.method, 'Standard');
        expect(rate.estimatedDays, null);
        expect(rate.available, true);
      });

      test('parses JSON with integer cost', () {
        final json = {
          'cost': 15000,
        };

        final rate = ShippingRate.fromJson(json);

        expect(rate.cost, 15000.0);
        expect(rate.method, 'Standard');
      });

      test('parses JSON with double cost', () {
        final json = {
          'cost': 15000.50,
        };

        final rate = ShippingRate.fromJson(json);

        expect(rate.cost, 15000.50);
      });

      test('handles empty JSON with all defaults', () {
        final json = <String, dynamic>{};

        final rate = ShippingRate.fromJson(json);

        expect(rate.cost, 0.0);
        expect(rate.method, 'Standard');
        expect(rate.estimatedDays, null);
        expect(rate.available, true);
      });

      test('parses JSON with false available', () {
        final json = {
          'cost': 0,
          'method': 'Not Available',
          'available': false,
        };

        final rate = ShippingRate.fromJson(json);

        expect(rate.available, false);
      });
    });

    group('formattedCost Tests', () {
      test('formats cost correctly with Rp symbol', () {
        final rate = ShippingRate(
          cost: 15000,
          method: 'Test',
        );

        expect(rate.formattedCost, 'Rp 15.000');
      });

      test('formats large cost with thousand separators', () {
        final rate = ShippingRate(
          cost: 1250000,
          method: 'Test',
        );

        expect(rate.formattedCost, 'Rp 1.250.000');
      });

      test('formats zero cost', () {
        final rate = ShippingRate(
          cost: 0,
          method: 'Free',
        );

        expect(rate.formattedCost, 'Rp 0');
      });

      test('formats decimal cost without decimal places', () {
        final rate = ShippingRate(
          cost: 15000.75,
          method: 'Test',
        );

        expect(rate.formattedCost, 'Rp 15.001'); // rounded
      });

      test('formats millions correctly', () {
        final rate = ShippingRate(
          cost: 5000000,
          method: 'Test',
        );

        expect(rate.formattedCost, 'Rp 5.000.000');
      });
    });
  });
}
