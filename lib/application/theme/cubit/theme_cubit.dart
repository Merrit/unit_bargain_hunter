import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../infrastructure/preferences/preferences.dart';
import '../../../presentation/styles.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
      : super(
          ThemeState(
            brightness: Preferences.instance.isDarkTheme
                ? Brightness.dark
                : Brightness.light,
          ),
        );

  /// Toggle between light theme and dark theme.
  void toggleTheme({required bool isDark}) {
    final brightness = (isDark) ? Brightness.dark : Brightness.light;
    Preferences.instance.isDarkTheme = isDark;
    emit(state.copyWith(brightness: brightness));
  }
}
