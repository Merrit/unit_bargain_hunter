import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../storage/storage_service.dart';

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
        themeMode: await _getThemeMode(storageService),
      ),
    );
  }

  static Future<ThemeMode> _getThemeMode(StorageService storageService) async {
    final ThemeMode themeMode;
    final theme = await storageService.getValue('ThemeMode') as String?;
    switch (theme) {
      case 'ThemeMode.dark':
        themeMode = ThemeMode.dark;
        break;
      case 'ThemeMode.light':
        themeMode = ThemeMode.light;
        break;
      default:
        if (kIsWeb) {
          themeMode = ThemeMode.system;
        } else {
          themeMode = ThemeMode.dark;
        }
    }
    return themeMode;
  }

  Future<void> updateNavigationAreaRatio(double value) async {
    emit(state.copyWith(navigationAreaRatio: value));
    await _storageService.saveValue(key: 'navigationAreaRatio', value: value);
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == state.themeMode) return;

    emit(state.copyWith(themeMode: newThemeMode));

    await _storageService.saveValue(
      key: 'ThemeMode',
      value: newThemeMode.toString(),
    );
  }
}
