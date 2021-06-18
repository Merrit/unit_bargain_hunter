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
          costPerUnits: [],
          shouldShowCloseButton: (_calculatorCubit.state.items.length >= 3),
          isCheapest: false,
          resultExists: false,
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
      final resultExists = event.result.isNotEmpty;
      final costPer = _checkCostPer(resultExists: resultExists, item: item);
      final isCheapest = event.result.contains(item);
      final costPerChanged = (state.costPerUnits.length != costPer.length);
      final itemChanged = (item != state.item) || costPerChanged;
      final calcStateChanged =
          (shouldShowCloseButton != state.shouldShowCloseButton);
      if (itemChanged || calcStateChanged) {
        emit(state.copyWith(
          item: item,
          costPerUnits: costPer,
          shouldShowCloseButton: shouldShowCloseButton,
          isCheapest: isCheapest,
          resultExists: resultExists,
        ));
      }
    });
  }

  /// Return blank strings if result hasn't yet been calculated,
  /// otherwise return strings with each unit's calculation.
  List<String> _checkCostPer({
    required bool resultExists,
    required Item item,
  }) {
    if ((item.costPerUnit.isEmpty) || !resultExists) return [];
    final results = <String>[];
    item.costPerUnit.forEach((Cost cost) {
      String stringValue = cost.value.toStringAsFixed(3);
      // Calculated value too small to show within 3 decimal points.
      if (stringValue == '0.000') stringValue = '--.--';
      if (stringValue.endsWith('0')) {
        // Only show 2 decimal places when ending with a 0, for example:
        // 77.50 instead of 77.500
        final lastIndex = stringValue.length - 1;
        stringValue = stringValue.substring(0, lastIndex);
      }
      results.add('\$$stringValue per ${cost.unit}');
    });
    return results;
  }
}
