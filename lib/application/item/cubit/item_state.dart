part of 'item_cubit.dart';

class ItemState extends Equatable {
  final int index;
  final Item item;
  final String costPer;
  final bool shouldShowCloseButton;

  const ItemState({
    required this.index,
    required this.item,
    required this.costPer,
    required this.shouldShowCloseButton,
  });

  @override
  List<Object> get props => [index, item, costPer, shouldShowCloseButton];

  ItemState copyWith({
    int? index,
    Item? item,
    String? costPer,
    bool? shouldShowCloseButton,
  }) {
    return ItemState(
      index: index ?? this.index,
      item: item ?? this.item,
      costPer: costPer ?? this.costPer,
      shouldShowCloseButton:
          shouldShowCloseButton ?? this.shouldShowCloseButton,
    );
  }
}
