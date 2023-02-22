import 'package:flutter/material.dart';

/// Contains the app's theme data.
abstract class AppTheme {
  /// Primary app color.
  static const primaryColor = Color.fromRGBO(0, 179, 255, 1);

  /// Dark app theme.
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: primaryColor,
  );

  /// Light app theme.
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: primaryColor,
  );
}
