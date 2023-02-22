import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpers/helpers.dart';

import '../../../app/app_widget.dart';
import '../../../app/widgets/widgets.dart';
import '../../../purchases/cubit/purchases_cubit.dart';
import '../../../purchases/pages/purchases_page.dart';
import '../../../settings/settings.dart';
import '../../calculator_cubit/calculator_cubit.dart';
import 'sheet_tile_list.dart';

/// Holds the contents of the drawer for large displays, in the form of a
/// navigation bar.
class SidePanel extends StatefulWidget {
  const SidePanel({Key? key}) : super(key: key);

  @override
  State<SidePanel> createState() => _SidePanelState();
}

class _SidePanelState extends State<SidePanel> {
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
            // So `add` button is on the right.
            const SizedBox(),
            _addSheetButton,
          ],
        ),
        const SheetTileList(),
        proButton,
        const Center(child: ThemeSwitch()),
        const _SettingsTile(),
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

class _SettingsTile extends StatelessWidget {
  const _SettingsTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return ListTile(
          title: Center(
            child: badges.Badge(
              showBadge: state.showUpdateButton,
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Colors.lightBlue,
              ),
              child: const Text('Settings'),
            ),
          ),
          onTap: () => Navigator.pushNamed(context, SettingsPage.id),
        );
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
