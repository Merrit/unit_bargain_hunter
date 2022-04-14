import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'calculator/calculator_cubit/calculator_cubit.dart';
import 'infrastructure/preferences/preferences.dart';
import 'logs/logs.dart';
import 'platform/platform.dart';
import 'theme/cubit/theme_cubit.dart';
import 'window/window.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeLogger();

  await Preferences.instance.initialize();

  if (Platform.isDesktop) await Window.initialize();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AppCubit(),
        ),
        BlocProvider(
          create: (context) => ThemeCubit(),
        ),
        BlocProvider(
          create: (context) => CalculatorCubit(),
        ),
      ],
      child: const App(),
    ),
  );
}
