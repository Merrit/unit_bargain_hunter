import 'package:equatable/equatable.dart';

abstract class Unit extends Equatable {
  const Unit();

  Unit get baseUnit;
  Unit get unitType;

  List<Unit> get subTypes => [Weight(), Volume(), ItemUnit()];

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
  static Unit get item => ItemUnit();

  @override
  List<Object> get props => [];
}

abstract class UnitType {
  const UnitType();

  static List<Unit> get all => [Weight(), Volume(), ItemUnit()];
  static Unit get weight => Weight();
  static Unit get volume => Volume();
  static Unit get item => ItemUnit();
}

/* --------------------------- Weight-based units --------------------------- */

class Weight extends Unit {
  const Weight();

  /// Other weights are converted to grams for comparisons.
  Unit get baseUnit => Gram();

  Unit get unitType => Weight();

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
  Unit get baseUnit => Millilitre();

  Unit get unitType => Volume();

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

  Unit get baseUnit => ItemUnit();

  Unit get unitType => ItemUnit();

  List<Unit> get subTypes => [ItemUnit()];

  @override
  String toString() => 'item';
}
