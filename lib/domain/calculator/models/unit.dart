import 'package:equatable/equatable.dart';

abstract class Unit extends Equatable {
  const Unit();

  Unit get baseUnit;
  List<Unit> get subTypes;
  Unit get unitType;

  // Weight-based units.
  static Unit get gram => Gram();
  static Unit get kilogram => Kilogram();
  static Unit get ounce => Ounce();
  static Unit get pound => Pound();

  @override
  List<Object> get props => [];
}

abstract class UnitType {
  const UnitType();

  static List<Unit> get all => [Weight()];
  static Unit get weight => Weight();
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
