import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpers/helpers.dart';
import 'package:http/http.dart' as http;

import 'app/app_widget.dart';
import 'authentication/authentication.dart';
import 'calculator/calculator_cubit/calculator_cubit.dart';
import 'logs/logs.dart';
import 'platform/platform.dart';
import 'purchases/cubit/purchases_cubit.dart';
import 'settings/cubit/settings_cubit.dart';
import 'setup/setup.dart';
import 'storage/storage_service.dart';
import 'updates/updates.dart';
import 'window/window.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final verbose = args.contains('--verbose');
  await LoggingManager.initialize(verbose: verbose);

  // Handle platform errors not caught by Flutter.
  PlatformDispatcher.instance.onError = (error, stack) {
    log.e('Uncaught platform error', error: error, stackTrace: stack);
    return true;
  };

  _preloadEmojis();
  setup.init();

  // Wait for the storage service to initialize while showing the splash screen.
  // This allows us to be certain that settings are available right away,
  // and prevents unsightly things like the theme suddenly changing when loaded.
  final storageService = await StorageService.initialize();

  final googleAuth = GoogleAuth();
  final authenticationCubit = await AuthenticationCubit.initialize(
    googleAuth: googleAuth,
    storageService: storageService,
  );

  final appCubit = AppCubit(
    releaseNotesService: ReleaseNotesService(
      client: http.Client(),
      repository: 'merrit/unit_bargain_hunter',
    ),
    updateService: UpdateService(),
  );

  final purchasescubit = await PurchasesCubit.initialize();

  final calculatorcubit = await CalculatorCubit.initialize(
    appCubit,
    authenticationCubit,
    purchasescubit,
    storageService,
  );

  final settingscubit = await SettingsCubit.initialize(storageService);

  if (Platform.isDesktop) await Window.initialize();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: appCubit),
        BlocProvider.value(value: authenticationCubit),
        BlocProvider.value(value: calculatorcubit),
        BlocProvider.value(value: purchasescubit),
        BlocProvider.value(value: settingscubit),
      ],
      child: const ProviderScope(
        child: AppWidget(),
      ),
    ),
  );
}

/// Prevents delay in displaying emojis on Web.
///
/// https://github.com/flutter/flutter/issues/42586#issuecomment-541870382
void _preloadEmojis() {
  final ParagraphBuilder pb = ParagraphBuilder(ParagraphStyle());
  pb.addText('\ud83d\ude01'); // smiley face emoji
  pb.build().layout(const ParagraphConstraints(width: 100));
}
