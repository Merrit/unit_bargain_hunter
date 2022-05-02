part of 'calculator_cubit.dart';

class CalculatorState extends Equatable {
  /// Whether to show the side panel that on large
  /// displays that holds the drawer contents.
  final bool showSidePanel;

  final bool alwaysShowScrollbar;
  final Unit comareBy;

  /// A list of sheets.
  ///
  /// Each [Sheet] contains a list of related [Item] objects for calculation.
  final List<Sheet> sheets;

  /// The UUID of the active [Sheet].
  final String activeSheetId;

  /// The active [Sheet], that is displayed in the [CalculatorView].
  final Sheet activeSheet;

  final List<Item> items;

  /// Contains the cheapest items.
  /// Will only include multiple items if there was a tie.
  final List<Item> result;

  bool get resultExists => result.isNotEmpty;

  const CalculatorState({
    required this.showSidePanel,
    required this.alwaysShowScrollbar,
    required this.comareBy,
    required this.sheets,
    required this.activeSheetId,
    required this.activeSheet,
    required this.items,
    required this.result,
  });

  CalculatorState copyWith({
    bool? showSidePanel,
    bool? alwaysShowScrollbar,
    Unit? comareBy,
    List<Sheet>? sheets,
    String? activeSheetId,
    Sheet? activeSheet,
    List<Item>? items,
    List<Item>? result,
  }) {
    return CalculatorState(
      showSidePanel: showSidePanel ?? this.showSidePanel,
      alwaysShowScrollbar: alwaysShowScrollbar ?? this.alwaysShowScrollbar,
      comareBy: comareBy ?? this.comareBy,
      sheets: sheets ?? this.sheets,
      activeSheetId: activeSheetId ?? this.activeSheetId,
      activeSheet: activeSheet ?? this.activeSheet,
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
      sheets,
      activeSheetId,
      activeSheet,
      items,
      result,
    ];
  }
}
