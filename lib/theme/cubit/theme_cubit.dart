import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../settings/settings.dart';
import '../theme.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
      : super(
          ThemeState(
            brightness: Settings.instance.isDarkTheme
                ? Brightness.dark
                : Brightness.light,
          ),
        );

  /// Toggle between light theme and dark theme.
  void toggleTheme({required bool isDark}) {
    final brightness = (isDark) ? Brightness.dark : Brightness.light;
    Settings.instance.isDarkTheme = isDark;
    emit(state.copyWith(brightness: brightness));
  }
}
