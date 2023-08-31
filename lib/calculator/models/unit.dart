import 'package:equatable/equatable.dart';

import '../../logs/logs.dart';

// All of the unit types the app supports comparisons of.
abstract class Unit extends Equatable {
  const Unit();

  Unit get baseUnit;
  Unit get unitType;

  List<Unit> get subTypes => [const Weight(), const Volume(), const ItemUnit()];

  /// A list of all the units that can be used for calculations.
  static List<Unit> get all => [
        ...const Weight().subTypes,
        ...const Volume().subTypes,
        const ItemUnit(),
      ];

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

  /// Accepts a String version, obtained via eg `Kilogram.toString()`.
  ///
  /// Accepts `Object` in order to accomodate the old Map values that were used.
  factory Unit.fromString(Object source) {
    // Handle old map values.
    if (source.runtimeType != String) source = 'g';

    switch (source as String) {
      case 'mg':
      case 'milligram':
        return Milligram();
      case 'g':
      case 'gram':
        return Gram();
      case 'kg':
      case 'kilogram':
        return Kilogram();
      case 'oz':
      case 'ounce':
        return Ounce();
      case 'lb':
      case 'pound':
        return Pound();
      case 'ml':
      case 'millilitre':
        return Millilitre();
      case 'l':
      case 'litre':
        return Litre();
      case 'fl oz':
      case 'fluid ounce':
        return FluidOunce();
      case 'qt':
      case 'quart':
        return Quart();
      case 'weight':
        return const Weight();
      case 'volume':
        return const Volume();
      case 'item':
        return const ItemUnit();
      default:
        log.w('Unable to parse Unit from map.');
        return Gram();
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
  List<Unit> get subTypes => [
        Milligram(),
        Gram(),
        Kilogram(),
        Ounce(),
        Pound(),
      ];

  @override
  String toString() => 'weight';
}

class Milligram extends Weight {
  @override
  String toString() => 'mg';
}

class Gram extends Weight {
  @override
  String toString() => 'g';
}

class Kilogram extends Weight {
  @override
  String toString() => 'kg';
}

class Ounce extends Weight {
  @override
  String toString() => 'oz';
}

class Pound extends Weight {
  @override
  String toString() => 'lb';
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
  String toString() => 'ml';
}

class Litre extends Volume {
  @override
  String toString() => 'l';
}

class FluidOunce extends Volume {
  @override
  String toString() => 'fl oz';
}

class Quart extends Volume {
  @override
  String toString() => 'qt';
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
