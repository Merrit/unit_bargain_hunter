part of 'item_cubit.dart';

class ItemState extends Equatable {
  final int index;
  final Item item;
  final List<String> costPerUnits;
  final bool shouldShowCloseButton;
  final bool isCheapest;
  final bool resultExists;

  const ItemState({
    required this.index,
    required this.item,
    required this.costPerUnits,
    required this.shouldShowCloseButton,
    required this.isCheapest,
    required this.resultExists,
  });

  String get priceAsString => item.price.toStringAsFixed(2);

  String get quantityAsString => item.quantity.toStringAsFixed(2);

  @override
  List<Object> get props {
    return [
      index,
      item,
      costPerUnits,
      shouldShowCloseButton,
      isCheapest,
      resultExists,
    ];
  }

  ItemState copyWith({
    int? index,
    Item? item,
    List<String>? costPer,
    bool? shouldShowCloseButton,
    bool? isCheapest,
    bool? resultExists,
  }) {
    return ItemState(
      index: index ?? this.index,
      item: item ?? this.item,
      costPerUnits: costPer ?? this.costPerUnits,
      shouldShowCloseButton:
          shouldShowCloseButton ?? this.shouldShowCloseButton,
      isCheapest: isCheapest ?? this.isCheapest,
      resultExists: resultExists ?? this.resultExists,
    );
  }
}
