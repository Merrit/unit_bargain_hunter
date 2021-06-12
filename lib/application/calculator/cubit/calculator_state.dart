part of 'calculator_cubit.dart';

@immutable
class CalculatorState extends Equatable {
  final List<Item> items;

  /// Contains the cheapest items.
  /// Will only include multiple items if there was a tie.
  final List<Item> result;

  bool get resultExists => result.isNotEmpty;

  final Unit comareBy;

  const CalculatorState({
    required this.items,
    required this.result,
    required this.comareBy,
  });

  factory CalculatorState.initial() {
    return CalculatorState(
      items: [
        Item(price: 0.00, quantity: 0.00, unit: Unit.gram),
        Item(price: 0.00, quantity: 0.00, unit: Unit.gram),
      ],
      comareBy: UnitType.weight,
      result: const <Item>[],
    );
  }

  CalculatorState copyWith({
    List<Item>? items,
    List<Item>? result,
    Unit? comareBy,
  }) {
    return CalculatorState(
      items: items ?? this.items,
      result: result ?? this.result,
      comareBy: comareBy ?? this.comareBy,
    );
  }

  @override
  List<Object> get props => [items, result, comareBy];
}
