import 'package:flutter/material.dart';
import 'package:unit_bargain_hunter/presentation/styles.dart';

abstract class AppTheme {
  static ThemeData get dark => ThemeData.dark().copyWith(
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadii.gentlyRounded,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.lightBlueAccent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          isDense: true,
        ),
      );
}
