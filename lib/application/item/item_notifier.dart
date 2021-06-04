// import 'package:equatable/equatable.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:unit_bargain_hunter/application/calculator/calculator_notifier.dart';
// import 'package:unit_bargain_hunter/application/providers.dart';
// import 'package:unit_bargain_hunter/domain/calculator/calculator.dart';

// part 'item_state.dart';

// class ItemNotifier extends StateNotifier<ItemState> {
//   // final StateNotifierProvider<CalculatorNotifier, CalculatorState>
//   //     _calculatorState;

//   ItemNotifier({
//     required int index,
//     required Item item,
//     // required StateNotifierProvider<CalculatorNotifier, CalculatorState>
//     //     calculatorState,
//   }) :
//         // _calculatorState = calculatorState,
//         super(
//           ItemState(
//             index: index,
//             item: item,
//           ),
//         ) {
//     // itemNotifier = this;
//     priceController.text = item.price.toStringAsFixed(2);
//     quantityController.text = item.quantity.toStringAsFixed(2);
//   }

//   final priceController = TextEditingController();
//   final quantityController = TextEditingController();
// }
