// part of 'calculator_notifier.dart';

// @immutable
// class CalculatorState extends Equatable {
//   final List<Item> items;
//   final String? result;
//   final Unit comareBy;

//   const CalculatorState({
//     required this.items,
//     required this.result,
//     required this.comareBy,
//   });

//   factory CalculatorState.initial() {
//     return CalculatorState(
//       items: [
//         Item(price: 0.00, quantity: 0.00, unit: Unit.gram),
//         Item(price: 0.00, quantity: 0.00, unit: Unit.gram),
//       ],
//       comareBy: UnitType.weight,
//       result: null,
//     );
//   }

//   CalculatorState copyWith({
//     List<Item>? items,
//     String? result,
//     Unit? comareBy,
//   }) {
//     return CalculatorState(
//       items: items ?? this.items,
//       result: result ?? this.result,
//       comareBy: comareBy ?? this.comareBy,
//     );
//   }

//   @override
//   List<Object> get props => [items];
// }
