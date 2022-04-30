part of 'calculator_cubit.dart';

class CalculatorState extends Equatable {
  /// Whether to show the side panel that on large
  /// displays that holds the drawer contents.
  final bool showSidePanel;

  final bool alwaysShowScrollbar;
  final Unit comareBy;
  final List<Item> items;

  /// Contains the cheapest items.
  /// Will only include multiple items if there was a tie.
  final List<Item> result;

  bool get resultExists => result.isNotEmpty;

  const CalculatorState({
    required this.showSidePanel,
    required this.alwaysShowScrollbar,
    required this.comareBy,
    required this.items,
    required this.result,
  });

  factory CalculatorState.initial() {
    return CalculatorState(
      showSidePanel: false,
      alwaysShowScrollbar: false,
      comareBy: UnitType.weight,
      items: [
        Item(price: 0.00, quantity: 0.00, unit: Unit.gram),
        Item(price: 0.00, quantity: 0.00, unit: Unit.gram),
      ],
      result: const <Item>[],
    );
  }

  CalculatorState copyWith({
    bool? showSidePanel,
    bool? alwaysShowScrollbar,
    Unit? comareBy,
    List<Item>? items,
    List<Item>? result,
  }) {
    return CalculatorState(
      showSidePanel: showSidePanel ?? this.showSidePanel,
      alwaysShowScrollbar: alwaysShowScrollbar ?? this.alwaysShowScrollbar,
      comareBy: comareBy ?? this.comareBy,
      items: items ?? this.items,
      result: result ?? this.result,
    );
  }

  @override
  List<Object> get props {
    return [
      showSidePanel,
      alwaysShowScrollbar,
      comareBy,
      items,
      result,
    ];
  }
}
