import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:unit_bargain_hunter/infrastructure/preferences/preferences.dart';
import 'package:unit_bargain_hunter/presentation/styles.dart';

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

  void toggleTheme({required bool isDark}) {
    final brightness = (isDark) ? Brightness.dark : Brightness.light;
    Preferences.instance.isDarkTheme = isDark;
    emit(state.copyWith(brightness: brightness));
  }
}
