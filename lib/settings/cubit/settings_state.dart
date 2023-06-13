part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  /// The ratio for how large the navigation area should be.
  final double navigationAreaRatio;

  /// The tax rate to use for calculations.
  final double taxRate;

  final ThemeData theme;

  const SettingsState({
    required this.navigationAreaRatio,
    required this.taxRate,
    required this.theme,
  });

  @override
  List<Object> get props => [
        navigationAreaRatio,
        taxRate,
        theme,
      ];

  SettingsState copyWith({
    double? navigationAreaRatio,
    double? taxRate,
    ThemeData? theme,
  }) {
    return SettingsState(
      navigationAreaRatio: navigationAreaRatio ?? this.navigationAreaRatio,
      taxRate: taxRate ?? this.taxRate,
      theme: theme ?? this.theme,
    );
  }
}
