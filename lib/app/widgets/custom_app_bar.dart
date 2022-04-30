import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../app/app.dart';
import '../../calculator/calculator_cubit/calculator_cubit.dart';
import '../../core/constants.dart';
import '../../settings/cubit/settings_cubit.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final preferredSize = const Size.fromHeight(kToolbarHeight);

  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExcludeFocusTraversal(
      child: AppBar(
        title: Stack(
          children: [
            const UpdateButton(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Transform flips the icon to give us a restart icon.
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: IconButton(
                    onPressed: () => calcCubit.reset(),
                    icon: const Icon(
                      Icons.refresh,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () => calcCubit.compare(),
                    child: const Text('Compare'),
                  ),
                ),
                IconButton(
                  onPressed: () => calcCubit.addItem(),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const ThemeSwitch(),
          ],
        ),
      ),
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
    return Positioned(
      right: 0,
      child: Switch(
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
      ),
    );
  }
}