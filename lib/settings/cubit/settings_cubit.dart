import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../settings_service.dart';

part 'settings_state.dart';

/// Convenient global access to the SettingsCubit.
///
/// There is only ever 1 instance of this cubit, and having this variable
/// means not having to do `context.read<SettingsCubit>()` to access it every
/// time, as well as making it available without a BuildContext.
late SettingsCubit settingsCubit;

/// Controls the state of the settings for the app.
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsService _settingsService;

  SettingsCubit(this._settingsService, {required SettingsState initialState})
      : super(initialState) {
    settingsCubit = this;
  }

  static Future<SettingsCubit> initialize(
    SettingsService settingsService,
  ) async {
    final ThemeMode themeMode = await settingsService.themeMode();

    return SettingsCubit(
      settingsService,
      initialState: SettingsState(themeMode: themeMode),
    );
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == state.themeMode) return;

    emit(state.copyWith(themeMode: newThemeMode));

    await _settingsService.updateThemeMode(newThemeMode);
  }
}
