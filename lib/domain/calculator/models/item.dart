import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../calculator.dart';

@immutable
class Item extends Equatable {
  final int index;
  final double price;
  final double quantity;
  final Unit unit;
  final Cost? costPerUnit;

  Item({
    required this.index,
    required this.price,
    required this.quantity,
    required this.unit,
  }) : costPerUnit = CostValidator.validate(
          price: price,
          quantity: quantity,
          unit: unit,
        );

  Item copyWith({
    int? index,
    double? price,
    double? quantity,
    Unit? unit,
  }) {
    return Item(
      index: index ?? this.index,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  @override
  List<Object> get props => [price, quantity, unit];

  @override
  bool get stringify => true;
}
