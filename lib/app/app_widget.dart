import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../calculator/calculator_page.dart';
import '../purchases/pages/purchase_successful_page.dart';
import '../purchases/pages/purchases_page.dart';
import '../settings/settings.dart';
import '../shortcuts/app_shortcuts.dart';

export 'cubit/app_cubit.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

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
