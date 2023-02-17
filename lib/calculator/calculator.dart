import '../logs/logs.dart';
import 'models/models.dart';

class Calculator {
  const Calculator();

  /// Returns the item that is cheapest per unit.
  ///
  /// If more than one item ties, returns all tied items.
  List<Item> compare({required List<Item> items}) {
    if (items.length <= 1) return items;
    final baseUnit = items[0].unit.baseUnit;
    List<Cost> cheapestPrice;
    try {
      cheapestPrice = items
          .reduce((Item a, Item b) =>
              (a.costPerUnit[0].value < b.costPerUnit[0].value) ? a : b)
          .costPerUnit;
    } on RangeError {
      log.w('Issue doing compare. Was costPerUnit calculated?');
      return [];
    }
    final cheapestBaseUnit = cheapestPrice.singleWhere(
      (e) => e.unit == baseUnit,
    );
    return items.where(
      (item) {
        final itemBaseUnit = item.costPerUnit.singleWhere(
          (e) => e.unit == baseUnit,
        );
        return itemBaseUnit == cheapestBaseUnit;
      },
    ).toList();
  }
}
