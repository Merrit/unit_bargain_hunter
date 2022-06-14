import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../app/app.dart';
import '../../../app/widgets/widgets.dart';
import '../../../core/constants.dart';
import '../../../core/helpers/form_factor.dart';
import '../../../purchases/cubit/purchases_cubit.dart';
import '../../../purchases/pages/purchases_page.dart';
import '../../../settings/cubit/settings_cubit.dart';
import '../../calculator_cubit/calculator_cubit.dart';
import 'sheet_tile_list.dart';

/// Widget that on larger screens will hold the contents of the drawer, in
/// the form of a collapsible side panel.
class SidePanel extends StatefulWidget {
  const SidePanel({Key? key}) : super(key: key);

  @override
  State<SidePanel> createState() => _SidePanelState();
}

class _SidePanelState extends State<SidePanel> {
  final _closePanelButton = Opacity(
    opacity: 0.8,
    child: IconButton(
      onPressed: () => calcCubit.toggleShowSidePanel(),
      icon: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(pi),
        child: const Icon(Icons.exit_to_app),
      ),
    ),
  );

  final _addSheetButton = Opacity(
    opacity: 0.8,
    child: IconButton(
      icon: const Icon(Icons.add),
      onPressed: () => calcCubit.addSheet(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final Widget proButton = BlocBuilder<PurchasesCubit, PurchasesState>(
      builder: (context, state) {
        if (!state.installedFromPlayStore) return const SizedBox();

        if (state.proPurchased) {
          return const ListTile(
            title: Opacity(
              opacity: 0.6,
              child: Center(child: Text('Pro purchased')),
            ),
          );
        } else {
          return Center(
            child: TextButton(
              onPressed: () => Navigator.pushNamed(context, PurchasesPage.id),
              child: const Text('PRO'),
            ),
          );
        }
      },
    );

    final Widget panelBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!mediaQuery.isHandset) _closePanelButton,
            // So add button is on the right.
            if (mediaQuery.isHandset) const SizedBox(),
            _addSheetButton,
          ],
        ),
        const SheetTileList(),
        proButton,
        const UpdateButton(),
        const Center(child: ThemeSwitch()),
        ListTile(
          title: const Center(child: Text('About')),
          onTap: () => showDialog(
            context: context,
            builder: (context) => const CustomAboutDialog(),
          ),
        ),
      ],
    );

    if (mediaQuery.isHandset) return panelBody;

    return Container(
      color: Theme.of(context).cardColor,
      width: 180,
      child: panelBody,
    );
  }
}

class UpdateButton extends StatelessWidget {
  const UpdateButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return (state.showUpdateButton)
            ? IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('An update is available'),
                        content: Text(
                          'Current version: ${state.runningVersion}\n'
                          'Update version: ${state.updateVersion}\n'
                          '\n'
                          'Would you like to open the downloads page?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                          TextButton(
                            onPressed: () => appCubit.launchURL(websiteUrl),
                            child: const Text('Open'),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const FaIcon(
                  FontAwesomeIcons.arrowCircleUp,
                  color: Colors.greenAccent,
                ),
              )
            : const SizedBox();
      },
    );
  }
}

/// A switch or toggle between light and dark themes.
class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: Theme.of(context).brightness == Brightness.dark,
      activeColor: Colors.grey[700],
      activeThumbImage: const AssetImage(
        'assets/images/theme_switch/moon.png',
      ),
      inactiveThumbColor: Colors.yellow,
      inactiveThumbImage: const AssetImage(
        'assets/images/theme_switch/sun.png',
      ),
      onChanged: (isDarkMode) {
        final themeMode = (isDarkMode) ? ThemeMode.dark : ThemeMode.light;
        settingsCubit.updateThemeMode(themeMode);
      },
    );
  }
}
