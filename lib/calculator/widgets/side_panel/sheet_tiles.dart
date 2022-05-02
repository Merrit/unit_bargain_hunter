import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/helpers/helpers.dart';
import '../../calculator_cubit/calculator_cubit.dart';
import '../../models/models.dart';

/// The scrolling list of tiles in the drawer for each calculator sheet.
class SheetTiles extends StatelessWidget {
  const SheetTiles({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Confirm the user really wants to remove the sheet.
    void showConfirmRemovalDialog(Sheet sheet) {
      Future.delayed(
        const Duration(seconds: 0),
        () => showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: const Text('Remove sheet?'),
              actions: [
                TextButton(
                  onPressed: () {
                    calcCubit.removeSheet(sheet);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'REMOVE',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CLOSE'),
                ),
              ],
            );
          },
        ),
      );
    }

    return Expanded(
      child: BlocBuilder<CalculatorCubit, CalculatorState>(
        builder: (context, state) {
          List<PopupMenuItem> contextMenuItems(Sheet sheet) {
            return [
              const PopupMenuItem(child: Text('data')),
              if (state.sheets.length > 1)
                PopupMenuItem(
                  child: const Text(
                    'Remove',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => showConfirmRemovalDialog(sheet),
                ),
            ];
          }

          return ListView(
            children: state.sheets
                .map((sheet) => GestureDetector(
                      onTap: () => calcCubit.selectSheet(sheet),
                      onSecondaryTapUp: (TapUpDetails details) {
                        showContextMenu(
                          context: context,
                          offset: details.globalPosition,
                          items: contextMenuItems(sheet),
                        );
                      },
                      onLongPressEnd: (LongPressEndDetails details) {
                        showContextMenu(
                          context: context,
                          offset: details.globalPosition,
                          items: contextMenuItems(sheet),
                        );
                      },
                      child: ListTile(
                        title: Center(child: Text(sheet.name)),
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
