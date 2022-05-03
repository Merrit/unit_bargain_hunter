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

  /// The unit type that is being used for comparisons: weight, volume, etc.
  final Unit compareBy;

  Sheet({
    List<Item>? items,
    this.name = 'Unnamed Sheet',
    String? uuid,
    this.compareBy = const Weight(),
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
    Unit? compareBy,
  }) {
    return Sheet(
      items: items ?? this.items,
      name: name ?? this.name,
      uuid: uuid,
      compareBy: compareBy ?? this.compareBy,
    );
  }

  @override
  List<Object> get props => [items, name, uuid, compareBy];

  Sheet addItem() {
    final updatedItems = List<Item>.from(items)
      ..add(Item(
        price: 0.00,
        quantity: 0.00,
        unit: compareBy.baseUnit,
      ));

    return copyWith(items: updatedItems);
  }

  Sheet removeItem(String uuid) {
    final updatedItems = List<Item>.from(items)
      ..removeWhere((item) => item.uuid == uuid);

    return copyWith(items: updatedItems);
  }

  Sheet updateItem(Item item) {
    final originalItem = items //
        .where((element) => element.uuid == item.uuid)
        .first;
    final index = items.indexOf(originalItem);

    final updatedItems = List<Item>.from(items) //
      ..[index] = item;

    return copyWith(items: updatedItems);
  }

  Sheet updateCompareBy(Unit unit) {
    final updatedItems = items
        .map((item) => item.copyWith(unit: unit.baseUnit)) //
        .toList();

    return copyWith(compareBy: unit, items: updatedItems);
  }

  Sheet reset() {
    return copyWith(compareBy: const Weight(), items: _defaultItems());
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'items': items.map((x) => x.toMap()).toList(),
      'name': name,
      'compareBy': compareBy.toMap(),
    };
  }

  factory Sheet.fromMap(Map<String, dynamic> map) {
    return Sheet(
      uuid: map['uuid'],
      items: List<Item>.from(map['items']?.map((x) => Item.fromMap(x))),
      name: map['name'] ?? '',
      compareBy: Unit.fromMap(map['compareBy']).unitType,
    );
  }

  String toJson() => json.encode(toMap());

  factory Sheet.fromJson(String source) => Sheet.fromMap(json.decode(source));
}
