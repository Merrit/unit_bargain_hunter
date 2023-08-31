part of 'settings_cubit.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    /// The units that should be shown on cards after a calculation.
    required List<Unit> enabledUnits,

    /// The ratio for how large the navigation area should be.
    required double navigationAreaRatio,

    /// Whether to show the cost per hundred grams or millilitres.
    required bool showCostPerHundred,

    /// The tax rate to use for calculations.
    required double taxRate,
    required ThemeData theme,
  }) = _SettingsState;
}
