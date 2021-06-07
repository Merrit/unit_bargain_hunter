import '../calculator.dart';

class CostValidator {
  const CostValidator();

  static Cost? validate({
    required double price,
    required double quantity,
    required Unit unit,
  }) {
    final priceExists = (price != 0.00);
    final quantityExists = (quantity != 0.00);
    if (!priceExists || !quantityExists) return null;
    final Unit baseUnit = unit.baseUnit;
    double costPerUnit;
    if (unit is Weight) {
      costPerUnit = _CostByWeightValidator(
        price: price,
        quantity: quantity,
        unit: unit,
      ).cost;
    } else {
      throw Exception('Unable to determine baseUnit:\n'
          '${baseUnit.runtimeType}');
    }
    return Cost(
      unit: baseUnit,
      value: costPerUnit,
    );
  }
}

class _CostByWeightValidator {
  final double price;
  final double quantity;
  final Unit unit;

  const _CostByWeightValidator({
    required this.price,
    required this.quantity,
    required this.unit,
  });

  double get cost {
    double convertedWeight;
    // Convert to grams as the base unit for comparisons.
    switch (unit.runtimeType) {
      case Gram:
        convertedWeight = quantity;
        break;
      case Kilogram:
        convertedWeight = quantity * 1000;
        break;
      case Ounce:
        convertedWeight = quantity * 28.35;
        break;
      case Pound:
        convertedWeight = quantity * 454;
        break;
      default:
        throw Exception('Error converting weight type');
    }
    final calculatedCost = price / convertedWeight;
    final roundedCost = double.parse(calculatedCost.toStringAsFixed(3));
    return roundedCost;
  }
}
