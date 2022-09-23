part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  /// The ratio for how large the navigation area should be.
  final double navigationAreaRatio;

  /// The currently loaded [ThemeMode].
  final ThemeMode themeMode;

  const SettingsState({
    required this.navigationAreaRatio,
    required this.themeMode,
  });

  @override
  List<Object> get props => [
        navigationAreaRatio,
        themeMode,
      ];

  SettingsState copyWith({
    double? navigationAreaRatio,
    ThemeMode? themeMode,
  }) {
    return SettingsState(
      navigationAreaRatio: navigationAreaRatio ?? this.navigationAreaRatio,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
