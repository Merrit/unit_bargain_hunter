import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../validators/validators.dart';
import 'models.dart';

class Item extends Equatable {
  /// A unique identifier for this specific item.
  final String uuid; // Helps keep track of the item in the widget tree.

  final double price;
  final double quantity;
  final Unit unit;

  /// A name or label the user can optionally give the item.
  final String name;

  /// Cost per gram, milligram, kilogram, etc.
  final List<Cost> costPerUnit;

  Item({
    String? uuid,
    required this.price,
    required this.quantity,
    required this.unit,
    this.name = 'Item',
  })  : uuid = uuid ?? const Uuid().v1(),
        costPerUnit = CostValidator.validate(
          price: price,
          quantity: quantity,
          unit: unit,
        );

  Item copyWith({
    String? uuid,
    double? price,
    double? quantity,
    Unit? unit,
    String? name,
  }) {
    final newName = _validateName(name);

    return Item(
      uuid: uuid ?? this.uuid,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      name: newName ?? this.name,
    );
  }

  @override
  String toString() => '\n'
      'uuid: $uuid \n'
      'price: $price \n'
      'quantity: $quantity \n'
      'unit: $unit \n'
      'name: $name \n';

  @override
  List<Object?> get props {
    return [
      uuid,
      price,
      quantity,
      unit,
      costPerUnit,
      name,
    ];
  }

  String? _validateName(String? name) {
    if (name == null) return null;
    if (name == '') return null;
    return name;
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'price': price,
      'quantity': quantity,
      'unit': unit.toMap(),
      'name': name,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      uuid: map['uuid'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      quantity: map['quantity']?.toDouble() ?? 0.0,
      unit: Unit.fromMap(map['unit']),
      name: map['name'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Item.fromJson(String source) => Item.fromMap(json.decode(source));
}
