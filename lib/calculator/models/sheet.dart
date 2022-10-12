import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import 'models.dart';

/// A sheet containing [Item] objects to be calculated.
class Sheet extends Equatable {
  /// If not provided the index defaults to `-1` to indicated this sheet has
  /// not yet been properly assigned an order and must be dealt with.
  final int index;

  final List<Item> items;
  final String name;

  /// A unique identifier for this specific sheet.
  final String uuid;

  /// The unit type that is being used for comparisons: weight, volume, etc.
  final Unit compareBy;

  /// (Optional) Additional details. Eg: brand name, type, color, etc.
  final String? subtitle;

  Sheet({
    List<Item>? items,
    String? uuid,
    this.index = -1,
    this.name = 'Unnamed Sheet',
    this.compareBy = const Weight(),
    String? subtitle,
  })  : items = items ?? _defaultItems(),
        uuid = uuid ?? const Uuid().v1(),
        subtitle = (subtitle == '') ? null : subtitle;

  /// The [Item] objects included by default in a new sheet.
  static List<Item> _defaultItems() {
    return [
      Item(price: 0.00, quantity: 0.00, unit: Unit.gram),
      Item(price: 0.00, quantity: 0.00, unit: Unit.gram),
    ];
  }

  Sheet copyWith({
    int? index,
    List<Item>? items,
    String? name,
    String? uuid,
    Unit? compareBy,
    String? subtitle,
  }) {
    return Sheet(
      index: index ?? this.index,
      items: items ?? this.items,
      name: name ?? this.name,
      uuid: uuid ?? this.uuid,
      compareBy: compareBy ?? this.compareBy,
      subtitle: subtitle ?? this.subtitle,
    );
  }

  @override
  List<Object?> get props {
    return [
      index,
      items,
      name,
      uuid,
      compareBy,
      subtitle,
    ];
  }

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

  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'items': items.map((x) => x.toMap()).toList(),
      'name': name,
      'uuid': uuid,
      'compareBy': compareBy.toString(),
      'subtitle': subtitle,
    };
  }

  factory Sheet.fromMap(Map<String, dynamic> map) {
    return Sheet(
      index: map['index']?.toInt() ?? -1,
      items: List<Item>.from(map['items']?.map((x) => Item.fromMap(x))),
      name: map['name'] ?? '',
      uuid: map['uuid'] ?? '',
      compareBy: Unit.fromString(map['compareBy']).unitType,
      subtitle: map['subtitle'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Sheet.fromJson(String source) => Sheet.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Sheet(index: $index, items: $items, name: $name, uuid: $uuid, compareBy: $compareBy, subtitle: $subtitle)';
  }
}
