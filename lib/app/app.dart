import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../calculator/calculator_page.dart';
import '../settings/cubit/settings_cubit.dart';
import '../shortcuts/app_shortcuts.dart';
import '../theme/app_theme.dart';

export 'app_version.dart';
export 'cubit/app_cubit.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        /// Returns the [Brightness] based on the
        /// user's choice of desired [ThemeMode].
        Brightness brightness() {
          switch (state.themeMode) {
            case ThemeMode.dark:
              return Brightness.dark;
            case ThemeMode.light:
              return Brightness.light;
            case ThemeMode.system:
              return MediaQuery.of(context).platformBrightness;
          }
        }

        return MaterialApp(
          title: 'Unit Bargain Hunter',
          debugShowCheckedModeBanner: false,
          theme: AppTheme(brightness: brightness()).themeData,
          home: AppShortcuts(child: CalculatorPage()),
        );
      },
    );
  }
}
