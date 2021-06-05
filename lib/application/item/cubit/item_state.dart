part of 'item_cubit.dart';

@immutable
class ItemState extends Equatable {
  final Item item;

  ItemState({
    required this.item,
  });

  ItemState copyWith({
    int? index,
    Item? item,
  }) {
    return ItemState(
      item: item ?? this.item,
    );
  }

  @override
  List<Object> get props => [item];
}
