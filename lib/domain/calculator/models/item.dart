import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../calculator.dart';

@immutable
class Item {
  final UniqueKey key;
  // final int index;
  final double price;
  final double quantity;
  final Unit unit;
  final Cost? costPerUnit;

  Item({
    UniqueKey? key,
    // required this.index,
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
    // int? index,
    double? price,
    double? quantity,
    Unit? unit,
  }) {
    return Item(
      key: key ?? this.key,
      // index: index ?? this.index,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  // @override
  // List<Object> get props => [price, quantity, unit];

  @override
  String toString() => '\n'
      'key: $key \n'
      'price: $price \n'
      'quantity: $quantity \n'
      'unit: $unit \n';
}
