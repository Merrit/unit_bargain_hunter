part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  /// The ratio for how large the navigation area should be.
  final double navigationAreaRatio;

  final ThemeData theme;

  const SettingsState({
    required this.navigationAreaRatio,
    required this.theme,
  });

  @override
  List<Object> get props => [
        navigationAreaRatio,
        theme,
      ];

  SettingsState copyWith({
    double? navigationAreaRatio,
    ThemeData? theme,
  }) {
    return SettingsState(
      navigationAreaRatio: navigationAreaRatio ?? this.navigationAreaRatio,
      theme: theme ?? this.theme,
    );
  }
}
