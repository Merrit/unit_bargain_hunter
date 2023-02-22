import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';

import '../../storage/storage_service.dart';
import '../../theme/app_theme.dart';

part 'settings_state.dart';

/// Convenient global access to the SettingsCubit.
///
/// There is only ever 1 instance of this cubit, and having this variable
/// means not having to do `context.read<SettingsCubit>()` to access it every
/// time, as well as making it available without a BuildContext.
late SettingsCubit settingsCubit;

/// Controls the state of the settings for the app.
class SettingsCubit extends Cubit<SettingsState> {
  final StorageService _storageService;

  SettingsCubit(this._storageService, {required SettingsState initialState})
      : super(initialState) {
    settingsCubit = this;
  }

  static Future<SettingsCubit> initialize(
    StorageService storageService,
  ) async {
    return SettingsCubit(
      storageService,
      initialState: SettingsState(
        navigationAreaRatio:
            await storageService.getValue('navigationAreaRatio') ?? 0.25,
        theme: await _getTheme(),
      ),
    );
  }

  /// Returns the [ThemeData] based on the user's choice of desired [ThemeMode].
  static Future<ThemeData> _getTheme() async {
    final themeMode = await _getThemeMode();
    switch (themeMode) {
      case ThemeMode.light:
        return AppTheme.light;
      case ThemeMode.dark:
      default:
        return AppTheme.dark;
    }
  }

  /// Returns the [ThemeMode] based on the user's choice of desired [ThemeMode].
  ///
  /// If the user has not made a choice, the system's theme is used.
  static Future<ThemeMode> _getThemeMode() async {
    final String? savedThemePreference =
        await StorageService.instance?.getValue(
      'ThemeMode',
    );

    switch (savedThemePreference) {
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.light':
        return ThemeMode.light;
      case null:
      default:
        return (SystemTheme.isDarkMode) ? ThemeMode.dark : ThemeMode.light;
    }
  }

  Future<void> updateNavigationAreaRatio(double value) async {
    emit(state.copyWith(navigationAreaRatio: value));
    await _storageService.saveValue(key: 'navigationAreaRatio', value: value);
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    final newTheme = (newThemeMode == ThemeMode.light) //
        ? AppTheme.light
        : AppTheme.dark;

    emit(state.copyWith(theme: newTheme));

    await _storageService.saveValue(
      key: 'ThemeMode',
      value: newThemeMode.toString(),
    );
  }
}
