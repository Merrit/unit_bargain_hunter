import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:unit_bargain_hunter/application/calculator/cubit/calculator_cubit.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final preferredSize = Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hidden IconButton to maintain row's spacing.
          Focus(
            descendantsAreFocusable: false,
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.hot_tub,
                color: Colors.black.withOpacity(0),
              ),
            ),
          ),
          Spacer(),
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
          Spacer(),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text('This is dialog, \n'
                        'for to be showing help informations.'),
                  );
                },
              );
            },
            icon: Icon(Icons.help_outline),
          ),
        ],
      ),
    );
  }
}
