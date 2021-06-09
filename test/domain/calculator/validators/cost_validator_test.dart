import 'package:flutter_test/flutter_test.dart';
import 'package:unit_bargain_hunter/domain/calculator/calculator.dart';

void main() {
  group('Weight-based costs', () {
    test('Input of grams calculated correctly', () {
      final costs = CostValidator.validate(
        price: 14.97,
        quantity: 879,
        unit: Unit.gram,
      );
      expect(costs, [
        Cost(unit: Unit.gram, value: 0.017),
        Cost(unit: Unit.kilogram, value: 17.031),
        Cost(unit: Unit.ounce, value: 0.483),
        Cost(unit: Unit.pound, value: 7.732),
      ]);
    });

    test('Input of kilograms calculated correctly', () {
      final costs = CostValidator.validate(
        price: 14.97,
        quantity: 5,
        unit: Unit.kilogram,
      );
      expect(costs, [
        Cost(unit: Unit.gram, value: 0.003),
        Cost(unit: Unit.kilogram, value: 2.994),
        Cost(unit: Unit.ounce, value: 0.085),
        Cost(unit: Unit.pound, value: 1.359),
      ]);
    });

    test('Input of ounces calculated correctly', () {
      final costs = CostValidator.validate(
        price: 14.97,
        quantity: 10,
        unit: Unit.ounce,
      );
      expect(costs, [
        Cost(unit: Unit.gram, value: 0.053),
        Cost(unit: Unit.kilogram, value: 52.804),
        Cost(unit: Unit.ounce, value: 1.497),
        Cost(unit: Unit.pound, value: 23.973),
      ]);
    });

    test('Input of pounds calculated correctly', () {
      final costs = CostValidator.validate(
        price: 14.97,
        quantity: 20,
        unit: Unit.pound,
      );
      expect(costs, [
        Cost(unit: Unit.gram, value: 0.002),
        Cost(unit: Unit.kilogram, value: 1.649),
        Cost(unit: Unit.ounce, value: 0.047),
        Cost(unit: Unit.pound, value: 0.749),
      ]);
    });
  });
}
