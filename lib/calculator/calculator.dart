import 'models/models.dart';

class Calculator {
  const Calculator();

  /// Returns the item that is cheapest per unit.
  ///
  /// If more than one item ties, returns all tied items.
  List<Item> compare({required List<Item> items, required double taxRate}) {
    final List<Item> cheapestItems = [];
    double cheapestCostPerUnit = double.infinity;

    for (var item in items) {
      double costPerUnit = item.costPerBaseUnit();
      if (!item.taxIncluded) {
        costPerUnit = costPerUnit * (1 + taxRate);
      }

      if (costPerUnit < cheapestCostPerUnit) {
        cheapestItems.clear();
        cheapestItems.add(item);
        cheapestCostPerUnit = costPerUnit;
      } else if (costPerUnit == cheapestCostPerUnit) {
        cheapestItems.add(item);
      }
    }

    return cheapestItems;
  }
}
