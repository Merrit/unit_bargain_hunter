import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../calculator.dart';
import '../models/models.dart';

part 'calculator_state.dart';

/// Globally accessible variable for the [CalculatorCubit].
///
/// There is only ever one cubit, so this eases access.
late CalculatorCubit calcCubit;

class CalculatorCubit extends Cubit<CalculatorState> {
  CalculatorCubit() : super(CalculatorState.initial()) {
    calcCubit = this;
  }

  /// Compare all items to find the best value.
  void compare() {
    emit(state.copyWith(result: [])); // Reset result.
    final result = const Calculator().compare(items: state.items);
    emit(state.copyWith(result: result));
  }

  /// The user has chosen a new compare unit; weight, volume, or item.
  void updateCompareBy(Unit unit) {
    emit(
      state.copyWith(
        comareBy: unit,
        items: [
          // Populate with 2 default items.
          Item(price: 0.00, quantity: 0.00, unit: unit.baseUnit),
          Item(price: 0.00, quantity: 0.00, unit: unit.baseUnit),
        ],
      ),
    );
  }

  void addItem() {
    final items = List<Item>.from(state.items);
    items.add(
      Item(
        price: 0.00,
        quantity: 0.00,
        unit: state.comareBy.baseUnit,
      ),
    );
    emit(state.copyWith(items: items, result: null));
  }

  void removeItem(String uuid) {
    final items = List<Item>.from(state.items);
    items.removeWhere((element) => element.uuid == uuid);
    emit(state.copyWith(items: items, result: null));
  }

  void updateItem({
    required Item item,
    String? price,
    String? quantity,
    Unit? unit,
  }) {
    double? validatedPrice;
    double? validatedQuantity;
    if (price != null) validatedPrice = double.tryParse(price);
    if (quantity != null) validatedQuantity = double.tryParse(quantity);
    final updatedItem = item.copyWith(
      price: validatedPrice,
      quantity: validatedQuantity,
      unit: unit,
    );
    final items = List<Item>.from(state.items);
    final index = items.indexWhere((element) => element.uuid == item.uuid);
    items.removeAt(index);
    items.insert(index, updatedItem);
    emit(state.copyWith(items: items));
  }

  /// Reset the calculator to initial values.
  void reset() {
    emit(state.copyWith(items: []));
    emit(CalculatorState.initial());
  }

  /// Reset the results if user changes values.
  void resetResult() {
    if (state.result.isEmpty) return;
    emit(state.copyWith(result: []));
  }

  void updateShowScrollbar(bool showScrollbar) {
    emit(state.copyWith(alwaysShowScrollbar: showScrollbar));
  }

  /// Toggle show/hide for the large screen side
  /// panel that holds the drawer contents.
  void toggleShowSidePanel() {
    emit(state.copyWith(showSidePanel: !state.showSidePanel));
  }
}
