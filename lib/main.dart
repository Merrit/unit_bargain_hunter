import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unit_bargain_hunter/application/calculator/cubit/calculator_cubit.dart';
import 'package:unit_bargain_hunter/application/theme/cubit/theme_cubit.dart';
import 'package:unit_bargain_hunter/infrastructure/platform_repository/platform_repository.dart';
import 'package:unit_bargain_hunter/infrastructure/preferences/preferences.dart';

import 'presentation/app_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ThemeCubit(),
        ),
        BlocProvider(
          create: (context) => CalculatorCubit(),
        ),
      ],
      child: AppWidget(),
    ),
  );
}

Future<void> init() async {
  await Preferences.instance.initialize();
  if (PlatformRepository.isDesktop) {
    final window = Window();
    window.setWindowTitle('Unit Bargain Hunter');
    await window.setWindowFrame(width: 635, height: 650);
  }
}
