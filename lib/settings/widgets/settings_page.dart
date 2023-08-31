import 'package:badges/badges.dart' as badges;
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpers/helpers.dart';

import '../../app/app_widget.dart';
import '../../authentication/authentication.dart';
import '../../calculator/calculator_cubit/calculator_cubit.dart';
import '../../calculator/models/models.dart';
import '../../core/constants.dart';
import '../../purchases/cubit/purchases_cubit.dart';
import '../../purchases/pages/purchases_page.dart';
import '../../theme/theme.dart';
import '../settings.dart';

class SettingsPage extends StatelessWidget {
  static const String id = '/settings';

  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const SafeArea(
        child: SettingsView(),
      ),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double horizontalPadding = 0;
        if (constraints.maxWidth > 600) {
          horizontalPadding = (constraints.maxWidth - 600) / 2;
        }

        const versionSection = _SectionCard(
          title: 'Version',
          children: [
            _CurrentVersionTile(),
            _UpdateTile(),
          ],
        );

        const appearanceSection = _SectionCard(
          title: 'Appearance',
          children: [
            _ThemeTile(),
            _UnitFilterTile(),
          ],
        );

        final taxSection = _SectionCard(
          title: AppLocalizations.of(context)!.tax,
          children: const [
            _TaxTile(),
          ],
        );

        const syncSection = _SectionCard(
          title: 'Sync',
          children: [
            // Warning that sync is experimental
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Sync is experimental and may not work as expected. '
                'Please report any issues you encounter.',
                style: TextStyle(color: Colors.red),
              ),
            ),
            _EnableSyncTile(),
            _SyncNowTile(),
            _SignOutTile(),
          ],
        );

        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 16,
          ),
          children: [
            appearanceSection,
            taxSection,
            syncSection,
            versionSection,
          ],
        );
      },
    );
  }
}

/// A card with a title and a list of tiles related to that section.
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    Key? key,
    required this.title,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

/// A tile that shows the current theme, and a switch to toggle between
/// light and dark mode.
class _ThemeTile extends StatelessWidget {
  const _ThemeTile();

  @override
  Widget build(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>();

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SwitchListTile(
          value: state.theme == AppTheme.dark,
          title: const Text('Dark mode'),
          secondary: const Icon(Icons.brightness_4),
          onChanged: (bool value) {
            settingsCubit
                .updateThemeMode(value ? ThemeMode.dark : ThemeMode.light);
          },
        );
      },
    );
  }
}

/// A tile that when clicked will show a dialog to change which units are
/// displayed after a calculation.
class _UnitFilterTile extends StatelessWidget {
  const _UnitFilterTile();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return ListTile(
      title: const Text('Unit filter'),
      leading: const Icon(Icons.filter_list),
      onTap: () {
        if (mediaQuery.isHandset) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: const Text('Unit filter'),
                ),
                body: const SafeArea(
                  child: _UnitFilterSettings(),
                ),
              ),
            ),
          );
          return;
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Unit filter'),
              content: const _UnitFilterSettings(),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

/// A dialog that allows the user to change which units are displayed after
/// a calculation.
class _UnitFilterSettings extends StatefulWidget {
  const _UnitFilterSettings();

  @override
  _UnitFilterSettingsState createState() => _UnitFilterSettingsState();
}

class _UnitFilterSettingsState extends State<_UnitFilterSettings> {
  late SettingsCubit settingsCubit;

  @override
  void initState() {
    super.initState();

    settingsCubit = context.read<SettingsCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final List<CheckboxListTile> unitCheckboxWidgets = [
          CheckboxListTile(
            value: state.showCostPerHundred,
            title: const Align(
              alignment: Alignment.centerRight,
              child: Text('Cost per 100 g or ml'),
            ),
            onChanged: (bool? value) {
              if (value == null) return;

              settingsCubit.toggleCostPerHundred();
            },
          ),
          ...Unit.all.map(
            (unit) {
              return CheckboxListTile(
                value: state.enabledUnits.contains(unit),
                title: Align(
                  alignment: Alignment.centerRight,
                  child: Text(unit.toString()),
                ),
                onChanged: (bool? value) {
                  if (value == null) return;

                  settingsCubit.toggleUnit(unit);
                },
              );
            },
          ).toList()
        ];

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enabled units appear (if appropriate) after a calculation',
              ),
              const SizedBox(height: 16),
              ...unitCheckboxWidgets,
            ],
          ),
        );
      },
    );
  }
}

/// A tile that shows the current tax rate, and a button to change it.
class _TaxTile extends StatelessWidget {
  const _TaxTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return ListTile(
          title: Row(
            children: [
              Text(AppLocalizations.of(context)!.taxRate),
              const SizedBox(width: 8),
              Tooltip(
                message: AppLocalizations.of(context)!.taxRateTooltip,
                child: const Icon(Icons.info_outline),
              ),
            ],
          ),
          trailing: Text(
            '${state.taxRate}%',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: const Icon(Icons.attach_money),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const _TaxDialog(),
            );
          },
        );
      },
    );
  }
}

/// A dialog that allows the user to change the tax rate.
class _TaxDialog extends StatefulWidget {
  const _TaxDialog();

  @override
  _TaxDialogState createState() => _TaxDialogState();
}

class _TaxDialogState extends State<_TaxDialog> {
  late TextEditingController _controller;
  late SettingsCubit settingsCubit;

  @override
  void initState() {
    super.initState();

    settingsCubit = context.read<SettingsCubit>();

    _controller = TextEditingController(
      text: settingsCubit.state.taxRate.toString(),
    );

    // Select the text in the text field.
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tax rate'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Tax rate',
          hintText: '0',
        ),
        onSubmitted: (_) => _updateTaxRate(context),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => _updateTaxRate(context),
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _updateTaxRate(BuildContext context) {
    final double? taxRate = double.tryParse(_controller.text);
    if (taxRate != null) {
      settingsCubit.updateTaxRate(taxRate);
    }
    Navigator.of(context).pop();
  }
}

class _EnableSyncTile extends StatelessWidget {
  const _EnableSyncTile();

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthenticationCubit>();
    final calcCubit = context.read<CalculatorCubit>();

    final bool proPurchased = context.select(
      (PurchasesCubit cubit) => cubit.state.proPurchased,
    );

    return BlocListener<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) {
        if (state.waitingForUserToSignIn) {
          showSigningInDialog(context);
        }
      },
      child: BlocBuilder<CalculatorCubit, CalculatorState>(
        builder: (context, calculatorState) {
          return BlocBuilder<AuthenticationCubit, AuthenticationState>(
            builder: (context, authState) {
              return SwitchListTile(
                value: authState.signedIn,
                title: const Text('Sync'),
                secondary: const Icon(Icons.sync),
                subtitle: const Text('Sync your data with Google Drive'),
                onChanged: (bool value) async {
                  // If the user hasn't purchased pro, show a prompt to do so.
                  if (!proPurchased) {
                    _showPurchasePrompt(context);
                    return;
                  }

                  if (value) {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final success = await authCubit.signIn();
                    if (success) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Signed in successfully'),
                        ),
                      );

                      await calcCubit.syncData();
                    } else {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Sign in failed'),
                        ),
                      );
                    }
                  } else {
                    await authCubit.signOut();
                    calcCubit.resetSync();
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Shows a prompt to purchase the pro version.
  void _showPurchasePrompt(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please purchase the pro version to use sync'),
        action: SnackBarAction(
          label: 'Purchase',
          onPressed: () => Navigator.pushNamed(context, PurchasesPage.id),
        ),
      ),
    );
  }

  void showSigningInDialog(BuildContext context) {
    final authCubit = context.read<AuthenticationCubit>();

    final bool isMobile = defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;

    final String instructions = isMobile
        ? 'Please use the dialog that opened in the app to sign in'
        : 'Please use the opened browser to sign in';

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return BlocListener<AuthenticationCubit, AuthenticationState>(
          listener: (context, state) {
            if (!state.waitingForUserToSignIn) {
              Navigator.of(context).pop();
            }
          },
          child: AlertDialog(
            title: const Text('Sign in'),
            content: Text(instructions),
            actions: [
              TextButton(
                onPressed: () {
                  authCubit.cancelSignIn();
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SyncNowTile extends StatelessWidget {
  const _SyncNowTile();

  @override
  Widget build(BuildContext context) {
    final calcCubit = context.read<CalculatorCubit>();

    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, authState) {
        if (!authState.signedIn) {
          return const SizedBox.shrink();
        }

        return BlocBuilder<CalculatorCubit, CalculatorState>(
          builder: (context, calculatorState) {
            return ListTile(
              title: const Text('Sync now'),
              subtitle: Text(
                'Last synced: ${calculatorState.lastSync?.getDateTimeString() ?? 'Never'}',
              ),
              leading: const Icon(Icons.sync),
              onTap: authState.signedIn
                  ? () {
                      calcCubit.syncData();
                    }
                  : null,
            );
          },
        );
      },
    );
  }
}

class _SignOutTile extends StatelessWidget {
  const _SignOutTile();

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthenticationCubit>();
    final calcCubit = context.read<CalculatorCubit>();

    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, authState) {
        if (!authState.signedIn) {
          return const SizedBox.shrink();
        }

        return ListTile(
          title: const Text('Sign out'),
          leading: const Icon(Icons.logout),
          onTap: authState.signedIn
              ? () {
                  authCubit.signOut();
                  calcCubit.resetSync();
                }
              : null,
        );
      },
    );
  }
}

/// A tile that shows the current version of the app.
class _CurrentVersionTile extends StatelessWidget {
  const _CurrentVersionTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return ListTile(
          title: Text('Current version: ${state.runningVersion}'),
        );
      },
    );
  }
}

/// A tile that shows the latest version of the app, and a button to
/// open the download url in the browser (only on desktop).
///
/// If an update is available, a badge is shown on the tile to match the
/// badge on the Settings button in the side bar.
class _UpdateTile extends StatelessWidget {
  const _UpdateTile();

  @override
  Widget build(BuildContext context) {
    final appCubit = context.read<AppCubit>();

    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        kIsWeb) {
      return const SizedBox();
    }

    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        if (state.updateAvailable) {
          return ListTile(
            title: badges.Badge(
              showBadge: state.showUpdateButton,
              position: badges.BadgePosition.topStart(),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Colors.lightBlue,
              ),
              child: Text('Update available: ${state.updateVersion}'),
            ),
            trailing: kIsWeb
                ? null
                : IconButton(
                    icon: const Icon(Icons.open_in_browser),
                    onPressed: () {
                      appCubit.launchURL(websiteUrl);
                    },
                  ),
          );
        } else {
          return const ListTile(
            title: Text('Up to date'),
          );
        }
      },
    );
  }
}
