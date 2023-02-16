part of 'calculator_cubit.dart';

class CalculatorState extends Equatable {
  /// A list of sheets.
  ///
  /// Each [Sheet] contains a list of related [Item] objects for calculation.
  final List<Sheet> sheets;

  /// The UUID of the active [Sheet].
  final String? activeSheetId;

  /// The active [Sheet], that is displayed in the [CalculatorView].
  final Sheet? activeSheet;

  /// Contains the cheapest items.
  /// Will only include multiple items if there was a tie.
  final List<Item> result;

  /// When the user data was last synced to the cloud.
  final DateTime? lastSync;

  /// Whether a sync is in progress.
  final bool syncing;

  bool get resultExists => result.isNotEmpty;

  const CalculatorState({
    required this.sheets,
    this.activeSheetId,
    this.activeSheet,
    required this.result,
    this.lastSync,
    this.syncing = false,
  });

  CalculatorState copyWith({
    bool? showSidePanel,
    List<Sheet>? sheets,
    String? activeSheetId,
    Sheet? activeSheet,
    List<Item>? result,
    DateTime? lastSync,
    bool? clearLastSync,
    bool? syncing,
  }) {
    return CalculatorState(
      sheets: sheets ?? this.sheets,
      activeSheetId: activeSheetId ?? this.activeSheetId,
      activeSheet: activeSheet ?? this.activeSheet,
      result: result ?? this.result,
      lastSync: clearLastSync == true ? null : lastSync ?? this.lastSync,
      syncing: syncing ?? this.syncing,
    );
  }

  @override
  List<Object?> get props {
    return [
      sheets,
      activeSheetId,
      activeSheet,
      result,
      lastSync,
      syncing,
    ];
  }
}
