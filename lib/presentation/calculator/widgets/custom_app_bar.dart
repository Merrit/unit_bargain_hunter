import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unit_bargain_hunter/application/calculator/cubit/calculator_cubit.dart';
import 'package:unit_bargain_hunter/application/theme/cubit/theme_cubit.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final preferredSize = Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Transform flips the icon to give us a restart icon.
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: IconButton(
                  onPressed: () => calcCubit.reset(),
                  icon: Icon(
                    Icons.refresh,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () => calcCubit.compare(),
                  child: Text('Compare'),
                ),
              ),
              IconButton(
                onPressed: () => calcCubit.addItem(),
                icon: Icon(Icons.add),
              ),
            ],
          ),
          ThemeSwitch(),
        ],
      ),
    );
  }
}

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return Switch(
            value: state.isDarkTheme,
            activeColor: Colors.grey[700],
            activeThumbImage: AssetImage(
              'assets/images/theme_switch/moon.png',
            ),
            inactiveThumbColor: Colors.yellow,
            inactiveThumbImage: AssetImage(
              'assets/images/theme_switch/sun.png',
            ),
            onChanged: (value) {
              context.read<ThemeCubit>().toggleTheme(isDark: value);
            },
          );
        },
      ),
    );
  }
}
