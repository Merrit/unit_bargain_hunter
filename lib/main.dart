import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import 'application/app/cubit/app_cubit.dart';
import 'application/calculator/cubit/calculator_cubit.dart';
import 'application/theme/cubit/theme_cubit.dart';
import 'infrastructure/platform/platform.dart';
import 'infrastructure/preferences/preferences.dart';
import 'presentation/app_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await init();

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
      child: const AppWidget(),
    ),
  );
}

Future<void> init() async {
  await Preferences.instance.initialize();
  if (Platform.isDesktop) {
    const window = Window();
    window.setWindowTitle('Unit Bargain Hunter');
    await window.setWindowFrame(width: 635, height: 650);
  }
}
