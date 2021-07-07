import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../calculator.dart';

@immutable
class Item extends Equatable {
  final UniqueKey key; // Helps keep track of the item in the widget tree.
  final double price;
  final double quantity;
  final Unit unit;

  /// Cost per gram, milligram, kilogram, etc.
  final List<Cost> costPerUnit;

  Item({
    UniqueKey? key,
    required this.price,
    required this.quantity,
    required this.unit,
  })  : key = key ?? UniqueKey(),
        costPerUnit = CostValidator.validate(
          price: price,
          quantity: quantity,
          unit: unit,
        );

  Item copyWith({
    UniqueKey? key,
    double? price,
    double? quantity,
    Unit? unit,
  }) {
    return Item(
      key: key ?? this.key,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  @override
  String toString() => '\n'
      'key: $key \n'
      'price: $price \n'
      'quantity: $quantity \n'
      'unit: $unit \n';

  @override
  List<Object?> get props {
    return [
      key,
      price,
      quantity,
      unit,
      costPerUnit,
    ];
  }
}
