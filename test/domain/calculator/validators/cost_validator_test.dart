import 'package:flutter_test/flutter_test.dart';
import 'package:unit_bargain_hunter/domain/calculator/calculator.dart';

void main() {
  group('Weight-based costs', () {
    test('Price per gram calculated correctly', () {
      final result = CostValidator.validate(
        price: 14.97,
        quantity: 879,
        unit: Gram(),
      );
      expect(result, Cost(unit: Gram(), costPer: 0.017));
    });

    test('Price per kilogram calculated correctly', () {
      final result = CostValidator.validate(
        price: 14.97,
        quantity: 5,
        unit: Kilogram(),
      );
      expect(result, Cost(unit: Gram(), costPer: 0.003));
    });

    test('Price per ounce calculated correctly', () {
      final result = CostValidator.validate(
        price: 14.97,
        quantity: 10,
        unit: Ounce(),
      );
      expect(result, Cost(unit: Gram(), costPer: 0.053));
    });

    test('Price per pound calculated correctly', () {
      final result = CostValidator.validate(
        price: 14.97,
        quantity: 10,
        unit: Pound(),
      );
      expect(result, Cost(unit: Gram(), costPer: 0.003));
    });
  });
}
