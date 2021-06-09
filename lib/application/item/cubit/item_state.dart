part of 'item_cubit.dart';

class ItemState extends Equatable {
  final int index;
  final Item item;
  final List<String> costPerUnits;
  final bool shouldShowCloseButton;
  final bool isCheapest;

  const ItemState({
    required this.index,
    required this.item,
    required this.costPerUnits,
    required this.shouldShowCloseButton,
    required this.isCheapest,
  });

  @override
  List<Object> get props {
    return [
      index,
      item,
      costPerUnits,
      shouldShowCloseButton,
      isCheapest,
    ];
  }

  ItemState copyWith({
    int? index,
    Item? item,
    List<String>? costPer,
    bool? shouldShowCloseButton,
    bool? isCheapest,
  }) {
    return ItemState(
      index: index ?? this.index,
      item: item ?? this.item,
      costPerUnits: costPer ?? this.costPerUnits,
      shouldShowCloseButton:
          shouldShowCloseButton ?? this.shouldShowCloseButton,
      isCheapest: isCheapest ?? this.isCheapest,
    );
  }
}
