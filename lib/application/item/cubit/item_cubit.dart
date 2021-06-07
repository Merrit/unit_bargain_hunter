import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import 'package:unit_bargain_hunter/application/calculator/cubit/calculator_cubit.dart';
import 'package:unit_bargain_hunter/domain/calculator/calculator.dart';

part 'item_state.dart';

class ItemCubit extends Cubit<ItemState> {
  final CalculatorCubit _calculatorCubit;
  final int _itemIndex;

  ItemCubit(
    this._calculatorCubit,
    this._itemIndex,
  ) : super(ItemState(
          index: _itemIndex,
          item: _calculatorCubit.state.items[_itemIndex],
          costPer: '',
          shouldShowCloseButton: (_calculatorCubit.state.items.length >= 3),
          isCheapest: false,
        )) {
    _listenForItemUpdates();
  }

  void _listenForItemUpdates() {
    _calculatorCubit.stream.listen((event) {
      final item = event.items.singleWhereIndexedOrNull(
        (index, _) => index == _itemIndex,
      );
      if (item == null) return;
      final shouldShowCloseButton = (event.items.length >= 3);
      final resultExists = event.result.length > 0;
      final costPer = _checkCostPer(resultExists: resultExists, item: item);
      final isCheapest = event.result.contains(item);
      final costPerChanged = (state.costPer != costPer);
      final itemChanged = (item != state.item) || costPerChanged;
      final calcStateChanged =
          (shouldShowCloseButton != state.shouldShowCloseButton);
      if (itemChanged || calcStateChanged) {
        emit(state.copyWith(
          item: item,
          costPer: costPer,
          shouldShowCloseButton: shouldShowCloseButton,
          isCheapest: isCheapest,
        ));
      }
    });
  }

  String _checkCostPer({
    required bool resultExists,
    required Item item,
  }) {
    if ((item.costPerUnit == null) || !resultExists) return '';
    return '${item.costPerUnit?.value.toStringAsFixed(3)} per ${item.unit.baseUnit}';
  }
}
