import 'package:collection/collection.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:unit_bargain_hunter/domain/calculator/calculator.dart';
import 'package:url_launcher/url_launcher.dart';

part 'calculator_state.dart';

late CalculatorCubit calcCubit;

class CalculatorCubit extends Cubit<CalculatorState> {
  CalculatorCubit() : super(CalculatorState.initial()) {
    calcCubit = this;
  }

  void compare() {
    emit(state.copyWith(result: [])); // Reset result.
    final result = Calculator().compare(items: state.items);
    emit(state.copyWith(result: result));
  }

  void addItem() {
    final items = List<Item>.from(state.items);
    items.add(
      Item(
        price: 0.00,
        quantity: 0.00,
        unit: Gram(),
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

  void reset() {
    emit(state.copyWith(items: []));
    emit(CalculatorState.initial());
  }

  Future<void> launchDonateURL(String url) async {
    await canLaunch(url)
        ? await launch(url)
        : throw 'Could not launch url: $url';
  }
}
