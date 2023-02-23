import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:window_manager/window_manager.dart';

import '../calculator/calculator_cubit/calculator_cubit.dart';
import '../calculator/calculator_page.dart';
import '../logs/logs.dart';
import '../purchases/pages/purchase_successful_page.dart';
import '../purchases/pages/purchases_page.dart';
import '../settings/settings.dart';
import '../shortcuts/app_shortcuts.dart';

export 'cubit/app_cubit.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> with WindowListener {
  @override
  void initState() {
    super.initState();
    WindowManager.instance.addListener(this);
  }

  @override
  void dispose() {
    WindowManager.instance.removeListener(this);
    super.dispose();
  }

  /// Whether the application is currently exiting.
  ///
  /// This is used to prevent the application from running the exit logic
  /// multiple times while the window is closing.
  bool _exitingApp = false;

  /// Called when the window is closed.
  ///
  /// This is only called on desktop platforms.
  ///
  /// On desktop platforms, the window is hidden and the data is synced
  /// before the application is exited.
  @override
  Future<void> onWindowClose() async {
    if (_exitingApp) return;
    _exitingApp = true;
    log.v('Caught window close event. Hiding window and syncing data.');
    await windowManager.hide();
    await calcCubit.syncData();
    log.v('Sync complete. Exiting application.');
    await windowManager.destroy();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'Unit Bargain Hunter',
          debugShowCheckedModeBanner: false,
          theme: state.theme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routes: {
            CalculatorPage.id: (context) => CalculatorPage(),
            PurchasesPage.id: (context) => const PurchasesPage(),
            PurchaseSuccessfulPage.id: (context) =>
                const PurchaseSuccessfulPage(),
            SettingsPage.id: (context) => const SettingsPage(),
          },
          home: AppShortcuts(child: CalculatorPage()),
        );
      },
    );
  }
}
