export 'models/models.dart';
export 'validators/validators.dart';

import 'models/models.dart';

class Calculator {
  const Calculator();

  /// Returns the item that is cheapest per unit.
  ///
  /// If more than one item ties, returns all tied items.
  List<Item> compare({required List<Item> items}) {
    if (items.length <= 1) return items;
    final cheapestPrice = items
        .reduce(
            (a, b) => (a.costPerUnit[0].value < b.costPerUnit[0].value) ? a : b)
        .costPerUnit;
    return items.where((item) => item.costPerUnit == cheapestPrice).toList();
  }
}
