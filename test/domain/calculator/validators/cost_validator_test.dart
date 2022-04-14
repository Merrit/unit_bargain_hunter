import 'package:flutter_test/flutter_test.dart';
import 'package:unit_bargain_hunter/calculator/models/models.dart';
import 'package:unit_bargain_hunter/calculator/validators/validators.dart';

void main() {
  group('Weight-based costs', () {
    test('Input of milligrams calculated correctly', () {
      final costs = CostValidator.validate(
        price: 14.97,
        quantity: 879,
        unit: Unit.milligram,
      );
      expect(costs, [
        Cost(unit: Unit.milligram, value: 0.01703071672354949),
        Cost(unit: Unit.gram, value: 17.03071672354949),
        Cost(unit: Unit.kilogram, value: 17030.71672354949),
        Cost(unit: Unit.ounce, value: 482.82081911262804),
        Cost(unit: Unit.pound, value: 7731.945392491468),
      ]);
    });
    test('Input of grams calculated correctly', () {
      final costs = CostValidator.validate(
        price: 14.97,
        quantity: 879,
        unit: Unit.gram,
      );
      expect(costs, [
        Cost(unit: Unit.milligram, value: 0.00001703071672354949),
        Cost(unit: Unit.gram, value: 0.01703071672354949),
        Cost(unit: Unit.kilogram, value: 17.03071672354949),
        Cost(unit: Unit.ounce, value: 0.48282081911262803),
        Cost(unit: Unit.pound, value: 7.731945392491467),
      ]);
    });

    test('Input of kilograms calculated correctly', () {
      final costs = CostValidator.validate(
        price: 14.97,
        quantity: 5,
        unit: Unit.kilogram,
      );
      expect(costs, [
        Cost(unit: Unit.milligram, value: 0.000002994),
        Cost(unit: Unit.gram, value: 0.002994),
        Cost(unit: Unit.kilogram, value: 2.994),
        Cost(unit: Unit.ounce, value: 0.08487990000000001),
        Cost(unit: Unit.pound, value: 1.3592760000000002),
      ]);
    });

    test('Input of ounces calculated correctly', () {
      final costs = CostValidator.validate(
        price: 14.97,
        quantity: 10,
        unit: Unit.ounce,
      );
      expect(costs, [
        Cost(unit: Unit.milligram, value: 0.000052804232804232805),
        Cost(unit: Unit.gram, value: 0.052804232804232805),
        Cost(unit: Unit.kilogram, value: 52.80423280423281),
        Cost(unit: Unit.ounce, value: 1.497),
        Cost(unit: Unit.pound, value: 23.973121693121694),
      ]);
    });

    test('Input of pounds calculated correctly', () {
      final costs = CostValidator.validate(
        price: 14.97,
        quantity: 20,
        unit: Unit.pound,
      );
      expect(costs, [
        Cost(unit: Unit.milligram, value: 0.0000016486784140969163),
        Cost(unit: Unit.gram, value: 0.0016486784140969165),
        Cost(unit: Unit.kilogram, value: 1.6486784140969164),
        Cost(unit: Unit.ounce, value: 0.04674003303964758),
        Cost(unit: Unit.pound, value: 0.7485),
      ]);
    });
  });

  group('Volume-based costs', () {
    test('Input of millilitres calculated correctly', () {
      final costs = CostValidator.validate(
        price: 14.97,
        quantity: 450,
        unit: Unit.millilitre,
      );
      expect(costs, [
        Cost(unit: Unit.millilitre, value: 0.03326666666666667),
        Cost(unit: Unit.litre, value: 33.266666666666666),
        Cost(unit: Unit.fluidOunce, value: 0.9838284000000002),
        Cost(unit: Unit.quart, value: 31.470266666666667),
      ]);
    });

    test('Input of litres calculated correctly', () {
      final costs = CostValidator.validate(
        price: 14.97,
        quantity: 4,
        unit: Unit.litre,
      );
      expect(costs, [
        Cost(unit: Unit.millilitre, value: 0.0037425),
        Cost(unit: Unit.litre, value: 3.7425),
        Cost(unit: Unit.fluidOunce, value: 0.11068069500000002),
        Cost(unit: Unit.quart, value: 3.5404050000000002),
      ]);
    });

    test('Input of fluid ounces calculated correctly', () {
      final costs = CostValidator.validate(
        price: 14.97,
        quantity: 30,
        unit: Unit.fluidOunce,
      );
      expect(costs, [
        Cost(unit: Unit.millilitre, value: 0.016872928924054915),
        Cost(unit: Unit.litre, value: 16.872928924054914),
        Cost(unit: Unit.fluidOunce, value: 0.499),
        Cost(unit: Unit.quart, value: 15.961790762155948),
      ]);
    });

    test('Input of quarts calculated correctly', () {
      final costs = CostValidator.validate(
        price: 14.97,
        quantity: 8,
        unit: Unit.quart,
      );
      expect(costs, [
        Cost(unit: Unit.millilitre, value: 0.0019780655391120508),
        Cost(unit: Unit.litre, value: 1.978065539112051),
        Cost(unit: Unit.fluidOunce, value: 0.05849931025369979),
        Cost(unit: Unit.quart, value: 1.87125),
      ]);
    });
  });

  group('Item-based costs', () {
    test('Input of items calculated correctly', () {
      final costs = CostValidator.validate(
        price: 14.97,
        quantity: 20,
        unit: Unit.item,
      );
      expect(costs, [
        Cost(unit: Unit.item, value: 0.7485),
      ]);
    });
  });
}
