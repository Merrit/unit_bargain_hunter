import 'package:flutter_test/flutter_test.dart';
import 'package:unit_bargain_hunter/calculator/calculator.dart';
import 'package:unit_bargain_hunter/calculator/models/models.dart';

void main() {
  group('Calculator:', () {
    test('compare() returns the cheapest item', () {
      final item1 = Item(
        details: 'Item 1',
        price: 1.00,
        unit: Unit.ounce,
        quantity: 1,
      );

      final item2 = Item(
        details: 'Item 2',
        price: 2.00,
        unit: Unit.ounce,
        quantity: 1,
      );

      final items = [item1, item2];
      final result = const Calculator().compare(items: items);
      expect(result, [item1]);
    });

    test('compare() returns all cheapest items', () {
      final item1 = Item(
        details: 'Item 1',
        price: 1.00,
        unit: Unit.ounce,
        quantity: 1,
      );

      final item2 = Item(
        details: 'Item 2',
        price: 1.00,
        unit: Unit.ounce,
        quantity: 1,
      );

      final item3 = Item(
        details: 'Item 3',
        price: 2.00,
        unit: Unit.ounce,
        quantity: 1,
      );

      final items = [item1, item2, item3];
      final result = const Calculator().compare(items: items);
      expect(result, [item1, item2]);
    });
  });
}
