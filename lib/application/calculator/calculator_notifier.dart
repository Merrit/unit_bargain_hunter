// import 'package:equatable/equatable.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter/foundation.dart';
// import 'package:unit_bargain_hunter/application/providers.dart';
// import 'package:unit_bargain_hunter/domain/calculator/calculator.dart';

// part 'calculator_state.dart';

// class CalculatorNotifier extends StateNotifier<CalculatorState> {
//   CalculatorNotifier() : super(CalculatorState.initial()) {
//     calculatorNotifier = this;
//   }

//   void compare() {
//     final result = Calculator().compare(items: state.items);
//     state = state.copyWith(
//       result: 'Cheapest: Item ${state.items.indexOf(result.cheapest) + 1}',
//     );
//   }

//   void addItem() {
//     final items = List<Item>.from(state.items);
//     items.add(Item(price: 0.00, quantity: 0.00, unit: Gram()));
//     state = state.copyWith(items: items);
//   }

//   void removeItem(int index) {
//     final items = List<Item>.from(state.items);
//     items.removeAt(index);
//     state = state.copyWith(items: items);
//   }

//   void updateItem({
//     required int index,
//     String? price,
//     String? quantity,
//     Unit? unit,
//   }) {
//     double? validatedPrice;
//     double? validatedQuantity;
//     if (price != null) validatedPrice = double.tryParse(price);
//     if (quantity != null) validatedQuantity = double.tryParse(quantity);
//     // if (validatedPrice == null && validatedQuantity == null) // Emit error.

//     final updatedItem = state.items[index].copyWith(
//       price: validatedPrice,
//       quantity: validatedQuantity,
//       unit: unit,
//     );
//     final items = List<Item>.from(state.items);
//     items.removeAt(index);
//     items.insert(index, updatedItem);
//     state = state.copyWith(items: items);
//   }
// }
