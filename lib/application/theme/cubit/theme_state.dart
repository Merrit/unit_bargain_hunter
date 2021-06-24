part of 'theme_cubit.dart';

@immutable
class ThemeState extends Equatable {
  final Brightness brightness;

  ThemeState({
    required this.brightness,
  });

  final CardTheme cardTheme = CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadii.gentlyRounded,
    ),
  );

  final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    border: OutlineInputBorder(),
    isDense: true,
  );

  bool get isDarkTheme => (brightness == Brightness.dark);

  ThemeData get themeData {
    return ThemeData(
      brightness: brightness,
      cardTheme: cardTheme,
      inputDecorationTheme: inputDecorationTheme,
    );
  }

  ThemeState copyWith({
    Brightness? brightness,
  }) {
    return ThemeState(
      brightness: brightness ?? this.brightness,
    );
  }

  @override
  List<Object> get props => [brightness];
}
