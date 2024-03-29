import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../calculator/models/models.dart';
import '../../storage/storage_service.dart';
import '../../theme/app_theme.dart';

part 'settings_state.dart';
part 'settings_cubit.freezed.dart';

/// Controls the state of the settings for the app.
class SettingsCubit extends Cubit<SettingsState> {
  final StorageService _storageService;

  SettingsCubit(this._storageService, {required SettingsState initialState})
      : super(initialState);

  static Future<SettingsCubit> initialize(
    StorageService storageService,
  ) async {
    final List<dynamic>? savedEnabledUnitStrings =
        await storageService.getValue('enabledUnits');

    final List<Unit> enabledUnits;
    if (savedEnabledUnitStrings == null) {
      enabledUnits = Unit.all;
    } else {
      enabledUnits = savedEnabledUnitStrings //
          .map((dynamic unit) => Unit.fromString(unit))
          .toList();
    }

    final bool showCostPerHundred =
        await storageService.getValue('showCostPerHundred') ?? true;

    return SettingsCubit(
      storageService,
      initialState: SettingsState(
        enabledUnits: enabledUnits,
        navigationAreaRatio:
            await storageService.getValue('navigationAreaRatio') ?? 0.25,
        showCostPerHundred: showCostPerHundred,
        taxRate: await storageService.getValue('taxRate') ?? 0.0,
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

    final Brightness systemBrightness = WidgetsBinding //
        .instance
        .platformDispatcher
        .platformBrightness;

    switch (savedThemePreference) {
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.light':
        return ThemeMode.light;
      case null:
      default:
        return (systemBrightness == Brightness.dark)
            ? ThemeMode.dark
            : ThemeMode.light;
    }
  }

  /// Toggle whether to show the cost per hundred grams or millilitres.
  Future<void> toggleCostPerHundred() async {
    emit(state.copyWith(showCostPerHundred: !state.showCostPerHundred));
    await _storageService.saveValue(
      key: 'showCostPerHundred',
      value: state.showCostPerHundred,
    );
  }

  /// Toggle the enabled state of the given [unit].
  Future<void> toggleUnit(Unit unit) async {
    final List<Unit> enabledUnits = [...state.enabledUnits];

    if (enabledUnits.contains(unit)) {
      enabledUnits.remove(unit);
    } else {
      enabledUnits.add(unit);
    }

    emit(state.copyWith(enabledUnits: enabledUnits));

    final List<String> enabledUnitsStrings = enabledUnits //
        .map((Unit unit) => unit.toString())
        .toList();

    await _storageService.saveValue(
      key: 'enabledUnits',
      value: enabledUnitsStrings,
    );
  }

  Future<void> updateNavigationAreaRatio(double value) async {
    emit(state.copyWith(navigationAreaRatio: value));
    await _storageService.saveValue(key: 'navigationAreaRatio', value: value);
  }

  Future<void> updateTaxRate(double value) async {
    emit(state.copyWith(taxRate: value));
    await _storageService.saveValue(key: 'taxRate', value: value);
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
