part of 'calculator_cubit.dart';

class CalculatorState extends Equatable {
  /// Whether the user is currently editing the sheet name.
  final bool editingSheetName;

  /// Whether to show the side panel that on large
  /// displays that holds the drawer contents.
  final bool showSidePanel;

  final bool alwaysShowScrollbar;

  /// A list of sheets.
  ///
  /// Each [Sheet] contains a list of related [Item] objects for calculation.
  final List<Sheet> sheets;

  /// The UUID of the active [Sheet].
  final String activeSheetId;

  /// The active [Sheet], that is displayed in the [CalculatorView].
  final Sheet activeSheet;

  /// Contains the cheapest items.
  /// Will only include multiple items if there was a tie.
  final List<Item> result;

  bool get resultExists => result.isNotEmpty;

  const CalculatorState({
    required this.editingSheetName,
    required this.showSidePanel,
    required this.alwaysShowScrollbar,
    required this.sheets,
    required this.activeSheetId,
    required this.activeSheet,
    required this.result,
  });

  CalculatorState copyWith({
    bool? editingSheetName,
    bool? showSidePanel,
    bool? alwaysShowScrollbar,
    List<Sheet>? sheets,
    String? activeSheetId,
    Sheet? activeSheet,
    List<Item>? result,
  }) {
    return CalculatorState(
      editingSheetName: editingSheetName ?? this.editingSheetName,
      showSidePanel: showSidePanel ?? this.showSidePanel,
      alwaysShowScrollbar: alwaysShowScrollbar ?? this.alwaysShowScrollbar,
      sheets: sheets ?? this.sheets,
      activeSheetId: activeSheetId ?? this.activeSheetId,
      activeSheet: activeSheet ?? this.activeSheet,
      result: result ?? this.result,
    );
  }

  @override
  List<Object> get props {
    return [
      editingSheetName,
      showSidePanel,
      alwaysShowScrollbar,
      sheets,
      activeSheetId,
      activeSheet,
      result,
    ];
  }
}
