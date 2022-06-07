import 'package:flutter/material.dart';

import 'styles.dart';

class AppTheme {
  final Brightness brightness;

  AppTheme({
    required this.brightness,
  });

  final CardTheme cardTheme = CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadii.gentlyRounded,
    ),
  );

  final InputDecorationTheme inputDecorationTheme = const InputDecorationTheme(
    border: OutlineInputBorder(),
    isDense: true,
  );

  ThemeData get themeData {
    return ThemeData(
      brightness: brightness,
      cardTheme: cardTheme,
      fontFamily: 'Montserrat',
      inputDecorationTheme: inputDecorationTheme,
    );
  }
}
