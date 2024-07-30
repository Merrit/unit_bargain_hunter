import '../models/models.dart';

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
    } else if (unit is Volume) {
      results = _CostByVolumeValidator(
        price: price,
        quantity: quantity,
        unit: unit,
      ).calculateCosts();
    } else if (unit is ItemUnit) {
      results = _CostByItemValidator(
        price: price,
        quantity: quantity,
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

  final double _weightInGrams;

  // Convert to grams as the base unit for comparisons.
  static double _getUnitAsGrams(Unit unit, double quantity) {
    switch (unit.runtimeType) {
      case const (Milligram):
        return quantity / 1000;
      case const (Gram):
        return quantity;
      case const (Kilogram):
        return quantity * 1000;
      case const (Ounce):
        return quantity * 28.35;
      case const (Pound):
        return quantity * 454;
      default:
        throw Exception('Error converting weight type');
    }
  }

  List<Cost> calculateCosts() {
    final List<Cost> results = [];
    results.add(_costByMilligram);
    results.add(_costByGram);
    results.add(_costByKilogram);
    results.add(_costByOunce);
    results.add(_costByPound);
    return results;
  }

  Cost get _costByMilligram {
    final weightInMilligrams = _weightInGrams * 1000;
    final cost = _calculateUnitCost(price, weightInMilligrams);
    return Cost(unit: Unit.milligram, value: cost);
  }

  Cost get _costByGram {
    final cost = _calculateUnitCost(price, _weightInGrams);
    return Cost(unit: Unit.gram, value: cost);
  }

  Cost get _costByKilogram {
    final weightInKilos = _weightInGrams / 1000;
    final cost = _calculateUnitCost(price, weightInKilos);
    return Cost(unit: Unit.kilogram, value: cost);
  }

  Cost get _costByOunce {
    final weightInOunces = _weightInGrams / 28.35;
    final cost = _calculateUnitCost(price, weightInOunces);
    return Cost(unit: Unit.ounce, value: cost);
  }

  Cost get _costByPound {
    final weightInPounds = _weightInGrams / 454;
    final cost = _calculateUnitCost(price, weightInPounds);
    return Cost(unit: Unit.pound, value: cost);
  }
}

class _CostByVolumeValidator {
  final double price;
  final double quantity;
  final Unit unit;

  _CostByVolumeValidator({
    required this.price,
    required this.quantity,
    required this.unit,
  }) : _volumeInMillilitres = _getUnitAsMilliletres(unit, quantity);

  final double _volumeInMillilitres;

  // Convert to Millilitres as the base unit for comparisons.
  static double _getUnitAsMilliletres(Unit unit, double quantity) {
    switch (unit.runtimeType) {
      case const (Millilitre):
        return quantity;
      case const (Litre):
        return quantity * 1000;
      case const (FluidOunce):
        return quantity * 29.574;
      case const (Quart):
        return quantity * 946;
      default:
        throw Exception('Error converting volume type');
    }
  }

  List<Cost> calculateCosts() {
    final List<Cost> results = [];
    results.add(_costByMillilitre);
    results.add(_costByLitre);
    results.add(_costByFluidOunce);
    results.add(_costByQuart);
    return results;
  }

  Cost get _costByMillilitre {
    final cost = _calculateUnitCost(price, _volumeInMillilitres);
    return Cost(unit: Unit.millilitre, value: cost);
  }

  Cost get _costByLitre {
    final volumeInLitres = _volumeInMillilitres / 1000;
    final cost = _calculateUnitCost(price, volumeInLitres);
    return Cost(unit: Unit.litre, value: cost);
  }

  Cost get _costByFluidOunce {
    final volumeInFluidOunces = _volumeInMillilitres / 29.574;
    final cost = _calculateUnitCost(price, volumeInFluidOunces);
    return Cost(unit: Unit.fluidOunce, value: cost);
  }

  Cost get _costByQuart {
    final volumeInQuarts = _volumeInMillilitres / 946;
    final cost = _calculateUnitCost(price, volumeInQuarts);
    return Cost(unit: Unit.quart, value: cost);
  }
}

class _CostByItemValidator {
  final double price;
  final double quantity;

  _CostByItemValidator({
    required this.price,
    required this.quantity,
  });

  List<Cost> calculateCosts() {
    final List<Cost> results = [];
    results.add(_costByItem);
    return results;
  }

  Cost get _costByItem {
    final cost = _calculateUnitCost(price, quantity);
    return Cost(unit: Unit.item, value: cost);
  }
}

double _calculateUnitCost(double price, double quantity) => price / quantity;
