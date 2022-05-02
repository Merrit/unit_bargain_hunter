import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'calculator/calculator_cubit/calculator_cubit.dart';
import 'logs/logs.dart';
import 'platform/platform.dart';
import 'settings/cubit/settings_cubit.dart';
import 'settings/settings_service.dart';
import 'storage/storage_service.dart';
import 'window/window.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeLogger();

  // Wait for the storage service to initialize while showing the splash screen.
  // This allows us to be certain that settings are available right away,
  // and prevents unsightly things like the theme suddenly changing when loaded.
  final storageService = await StorageService.initialize();
  final settingsService = SettingsService(storageService);

  final _calculatorCubit = await CalculatorCubit.initialize(storageService);
  final _settingsCubit = await SettingsCubit.initialize(settingsService);

  if (Platform.isDesktop) await Window.initialize();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AppCubit()),
        BlocProvider.value(value: _calculatorCubit),
        BlocProvider.value(value: _settingsCubit),
      ],
      child: const ProviderScope(
        child: App(),
      ),
    ),
  );
}
