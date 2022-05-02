import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import 'models.dart';

/// A sheet containing [Item] objects to be calculated.
class Sheet extends Equatable {
  final List<Item> items;
  final String name;

  /// A unique identifier for this specific sheet.
  final String uuid;

  Sheet({
    List<Item>? items,
    this.name = 'Unnamed Sheet',
    String? uuid,
  })  : items = items ?? _defaultItems(),
        uuid = uuid ?? const Uuid().v1();

  /// The [Item] objects included by default in a new sheet.
  static List<Item> _defaultItems() {
    return [
      Item(price: 0.00, quantity: 0.00, unit: Unit.gram),
      Item(price: 0.00, quantity: 0.00, unit: Unit.gram),
    ];
  }

  Sheet copyWith({
    List<Item>? items,
    String? name,
    String? uuid,
  }) {
    return Sheet(
      items: items ?? this.items,
      name: name ?? this.name,
      uuid: uuid ?? this.uuid,
    );
  }

  @override
  List<Object> get props => [items, name, uuid];

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((x) => x.toMap()).toList(),
      'name': name,
    };
  }

  factory Sheet.fromMap(Map<String, dynamic> map) {
    return Sheet(
      items: List<Item>.from(map['items']?.map((x) => Item.fromMap(x))),
      name: map['name'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Sheet.fromJson(String source) => Sheet.fromMap(json.decode(source));
}
