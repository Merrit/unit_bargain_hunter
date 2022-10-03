import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'calculator/calculator_cubit/calculator_cubit.dart';
import 'logs/logs.dart';
import 'platform/platform.dart';
import 'purchases/cubit/purchases_cubit.dart';
import 'settings/cubit/settings_cubit.dart';
import 'setup/setup.dart';
import 'storage/storage_service.dart';
import 'window/window.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeLogger();
  _preloadEmojis();
  setup.init();

  // Wait for the storage service to initialize while showing the splash screen.
  // This allows us to be certain that settings are available right away,
  // and prevents unsightly things like the theme suddenly changing when loaded.
  final storageService = await StorageService.initialize();

  final purchasescubit = await PurchasesCubit.initialize();
  final calculatorcubit = await CalculatorCubit.initialize(
    purchasescubit,
    storageService,
  );
  final settingscubit = await SettingsCubit.initialize(storageService);

  if (Platform.isDesktop) await Window.initialize();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AppCubit()),
        BlocProvider.value(value: calculatorcubit),
        BlocProvider.value(value: purchasescubit),
        BlocProvider.value(value: settingscubit),
      ],
      child: const ProviderScope(
        child: App(),
      ),
    ),
  );
}

/// Prevents delay in displaying emojis on Web.
///
/// https://github.com/flutter/flutter/issues/42586#issuecomment-541870382
void _preloadEmojis() {
  ParagraphBuilder pb = ParagraphBuilder(ParagraphStyle(locale: window.locale));
  pb.addText('\ud83d\ude01'); // smiley face emoji
  pb.build().layout(const ParagraphConstraints(width: 100));
}
