import 'package:flutter_test/flutter_test.dart';
import 'package:unit_bargain_hunter/calculator/models/models.dart';

void main() {
  test('items are distinct', () {
    final item1 = Item(price: 0, quantity: 0, unit: Unit.gram);
    final item2 = Item(price: 0, quantity: 0, unit: Unit.gram);
    expect(item1 == item2, false);
  });

  test('copied item is distinct', () {
    final item = Item(price: 0, quantity: 0, unit: Unit.gram);
    final itemChanged = item.copyWith(price: 5.78);
    expect(item == itemChanged, false);
  });

  test('copied item has same key', () {
    final item = Item(price: 0, quantity: 0, unit: Unit.gram);
    final itemChanged = item.copyWith(quantity: 150);
    expect(item.uuid == itemChanged.uuid, true);
  });
}
