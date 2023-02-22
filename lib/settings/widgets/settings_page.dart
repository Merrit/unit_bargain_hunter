import 'package:badges/badges.dart' as badges;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpers/helpers.dart';

import '../../app/app_widget.dart';
import '../../authentication/authentication.dart';
import '../../calculator/calculator_cubit/calculator_cubit.dart';
import '../../core/constants.dart';
import '../../purchases/cubit/purchases_cubit.dart';
import '../../purchases/pages/purchases_page.dart';

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
          children: const [
            versionSection,
            syncSection,
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
                      AppCubit.instance.launchURL(websiteUrl);
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

class _EnableSyncTile extends StatelessWidget {
  const _EnableSyncTile();

  @override
  Widget build(BuildContext context) {
    bool proPurchased = context.select(
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
                    final success = await AuthenticationCubit.instance.signIn();
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
                    await AuthenticationCubit.instance.signOut();
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
                  AuthenticationCubit.instance.cancelSignIn();
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
                  AuthenticationCubit.instance.signOut();
                  calcCubit.resetSync();
                }
              : null,
        );
      },
    );
  }
}
