part of 'calculator_cubit.dart';

@freezed
class CalculatorState with _$CalculatorState {
  const factory CalculatorState({
    /// A list of sheets.
    ///
    /// Each [Sheet] contains a list of related [Item] objects for calculation.
    required List<Sheet> sheets,

    /// The UUID of the active [Sheet].
    String? activeSheetId,

    /// The active [Sheet], that is displayed in the [CalculatorView].
    Sheet? activeSheet,

    /// Contains the cheapest items.
    /// Will only include multiple items if there was a tie.
    required List<Item> result,

    /// When the user data was last synced to the cloud.
    DateTime? lastSync,

    /// Whether a sync is in progress.
    required bool syncing,
  }) = _CalculatorState;

  /// Private unnamed constructor required for getters to work with Freezed.
  // ignore: unused_element
  const CalculatorState._();

  bool get resultExists => result.isNotEmpty;
}
