import 'package:collection/collection.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:unit_bargain_hunter/domain/calculator/calculator.dart';

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
    final result = Calculator().compare(items: state.items);
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

  void removeItem(UniqueKey key) {
    final items = List<Item>.from(state.items);
    items.removeWhere((element) => element.key == key);
    emit(state.copyWith(items: items, result: null));
  }

  void updateItem({
    required UniqueKey key,
    String? price,
    String? quantity,
    Unit? unit,
  }) {
    if (state.resultExists) resetResult();
    double? validatedPrice;
    double? validatedQuantity;
    if (price != null) validatedPrice = double.tryParse(price);
    if (quantity != null) validatedQuantity = double.tryParse(quantity);
    final item = state.items.singleWhereOrNull((element) => element.key == key);
    if (item == null) return;
    final updatedItem = item.copyWith(
      price: validatedPrice,
      quantity: validatedQuantity,
      unit: unit,
    );
    final items = List<Item>.from(state.items);
    final index = items.indexWhere((element) => element.key == key);
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
  void resetResult() => emit(state.copyWith(result: []));

  Future<void> launchURL(String url) async {
    await canLaunch(url)
        ? await launch(url)
        : throw 'Could not launch url: $url';
  }

  void updateShowScrollbar(bool showScrollbar) {
    emit(state.copyWith(alwaysShowScrollbar: showScrollbar));
  }
}
