import 'package:equatable/equatable.dart';

// All of the unit types the app supports comparisons of.

abstract class Unit extends Equatable {
  const Unit();

  Unit get baseUnit;
  Unit get unitType;

  List<Unit> get subTypes => [const Weight(), const Volume(), const ItemUnit()];

  // Weight-based units.
  static Unit get milligram => Milligram();
  static Unit get gram => Gram();
  static Unit get kilogram => Kilogram();
  static Unit get ounce => Ounce();
  static Unit get pound => Pound();

  // Volume-based units.
  static Unit get millilitre => Millilitre();
  static Unit get litre => Litre();
  static Unit get fluidOunce => FluidOunce();
  static Unit get quart => Quart();

  // Item-based unit.
  static Unit get item => const ItemUnit();

  @override
  List<Object> get props => [];

  Map<String, dynamic> toMap() {
    return {
      'baseUnit': baseUnit.toString(),
      'unitType': unitType.toString(),
    };
  }

  factory Unit.fromMap(Map<String, dynamic> map) {
    switch (map['baseUnit'] as String) {
      case 'milligram':
        return Milligram();
      case 'gram':
        return Gram();
      case 'kilogram':
        return Kilogram();
      case 'ounce':
        return Ounce();
      case 'pound':
        return Pound();
      case 'millilitre':
        return Millilitre();
      case 'litre':
        return Litre();
      case 'fluid ounce':
        return FluidOunce();
      case 'quart':
        return Quart();
      case 'item':
        return const ItemUnit();
      default:
        throw Exception('Unable to parse Unit from map.');
    }
  }
}

abstract class UnitType {
  const UnitType();

  static List<Unit> get all =>
      [const Weight(), const Volume(), const ItemUnit()];
  static Unit get weight => const Weight();
  static Unit get volume => const Volume();
  static Unit get item => const ItemUnit();
}

/* --------------------------- Weight-based units --------------------------- */

class Weight extends Unit {
  const Weight();

  /// Other weights are converted to grams for comparisons.
  @override
  Unit get baseUnit => Gram();

  @override
  Unit get unitType => const Weight();

  @override
  List<Unit> get subTypes => [Gram(), Kilogram(), Ounce(), Pound()];

  @override
  String toString() => 'weight';
}

class Milligram extends Weight {
  @override
  String toString() => 'milligram';
}

class Gram extends Weight {
  @override
  String toString() => 'gram';
}

class Kilogram extends Weight {
  @override
  String toString() => 'kilogram';
}

class Ounce extends Weight {
  @override
  String toString() => 'ounce';
}

class Pound extends Weight {
  @override
  String toString() => 'pound';
}

/* --------------------------- Volume-based units --------------------------- */

class Volume extends Unit {
  const Volume();

  /// Other volumes are converted to millilitre for comparisons.
  @override
  Unit get baseUnit => Millilitre();

  @override
  Unit get unitType => const Volume();

  @override
  List<Unit> get subTypes => [Millilitre(), Litre(), FluidOunce(), Quart()];

  @override
  String toString() => 'volume';
}

class Millilitre extends Volume {
  @override
  String toString() => 'millilitre';
}

class Litre extends Volume {
  @override
  String toString() => 'litre';
}

class FluidOunce extends Volume {
  @override
  String toString() => 'fluid ounce';
}

class Quart extends Volume {
  @override
  String toString() => 'quart';
}

/* ----------------------------- Item-based unit ---------------------------- */

class ItemUnit extends Unit {
  const ItemUnit();

  @override
  Unit get baseUnit => const ItemUnit();

  @override
  Unit get unitType => const ItemUnit();

  @override
  List<Unit> get subTypes => [const ItemUnit()];

  @override
  String toString() => 'item';
}
