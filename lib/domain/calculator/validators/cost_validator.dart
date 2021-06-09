import '../calculator.dart';

class CostValidator {
  const CostValidator();

  static List<Cost> validate({
    required double price,
    required double quantity,
    required Unit unit,
  }) {
    final priceExists = (price != 0.00);
    final quantityExists = (quantity != 0.00);
    if (!priceExists || !quantityExists) return [];
    List<Cost> results;
    if (unit is Weight) {
      results = _CostByWeightValidator(
        price: price,
        quantity: quantity,
        unit: unit,
      ).calculateCosts();
    } else {
      throw Exception('Unknown unit type');
    }
    return results;
  }
}

class _CostByWeightValidator {
  final double price;
  final double quantity;
  final Unit unit;

  _CostByWeightValidator({
    required this.price,
    required this.quantity,
    required this.unit,
  }) : _weightInGrams = _getUnitAsGrams(unit, quantity);

  double _weightInGrams;

  // Convert to grams as the base unit for comparisons.
  static double _getUnitAsGrams(Unit unit, double quantity) {
    switch (unit.runtimeType) {
      case Gram:
        return quantity;
      case Kilogram:
        return quantity * 1000;
      case Ounce:
        return quantity * 28.35;
      case Pound:
        return quantity * 454;
      default:
        throw Exception('Error converting weight type');
    }
  }

  List<Cost> calculateCosts() {
    final List<Cost> results = [];
    results.add(_costByGram);
    results.add(_costByKilogram);
    results.add(_costByOunce);
    results.add(_costByPound);
    return results;
  }

  Cost get _costByGram {
    final cost = _calculateUnitCost(_weightInGrams);
    return Cost(unit: Unit.gram, value: cost);
  }

  Cost get _costByKilogram {
    final weightInKilos = _weightInGrams / 1000;
    final cost = _calculateUnitCost(weightInKilos);
    return Cost(unit: Unit.kilogram, value: cost);
  }

  Cost get _costByOunce {
    final weightInOunces = _weightInGrams / 28.35;
    final cost = _calculateUnitCost(weightInOunces);
    return Cost(unit: Unit.ounce, value: cost);
  }

  Cost get _costByPound {
    final weightInPounds = _weightInGrams / 454;
    final cost = _calculateUnitCost(weightInPounds);
    return Cost(unit: Unit.pound, value: cost);
  }

  double _calculateUnitCost(double weight) {
    final calculatedCost = price / weight;
    final roundedCost = double.parse(calculatedCost.toStringAsFixed(3));
    return roundedCost;
  }
}
