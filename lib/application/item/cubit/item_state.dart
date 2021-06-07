part of 'item_cubit.dart';

class ItemState extends Equatable {
  final int index;
  final Item item;
  final String costPer;
  final bool shouldShowCloseButton;
  final bool isCheapest;

  const ItemState({
    required this.index,
    required this.item,
    required this.costPer,
    required this.shouldShowCloseButton,
    required this.isCheapest,
  });

  @override
  List<Object> get props {
    return [
      index,
      item,
      costPer,
      shouldShowCloseButton,
      isCheapest,
    ];
  }

  ItemState copyWith({
    int? index,
    Item? item,
    String? costPer,
    bool? shouldShowCloseButton,
    bool? isCheapest,
  }) {
    return ItemState(
      index: index ?? this.index,
      item: item ?? this.item,
      costPer: costPer ?? this.costPer,
      shouldShowCloseButton:
          shouldShowCloseButton ?? this.shouldShowCloseButton,
      isCheapest: isCheapest ?? this.isCheapest,
    );
  }
}
