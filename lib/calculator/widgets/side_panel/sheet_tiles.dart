import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/helpers/helpers.dart';
import '../../calculator_cubit/calculator_cubit.dart';
import '../../models/models.dart';

/// The scrolling list of tiles in the drawer for each calculator sheet.
class SheetTiles extends StatefulWidget {
  const SheetTiles({Key? key}) : super(key: key);

  @override
  State<SheetTiles> createState() => _SheetTilesState();
}

class _SheetTilesState extends State<SheetTiles> {
  Sheet? hoveredSheet;

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
              content: Text('Remove sheet "${sheet.name}?"'),
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

          Color? _getContainerColor(Sheet sheet) {
            if (sheet == state.activeSheet) {
              return Colors.grey.withOpacity(0.2);
            }

            if (sheet == hoveredSheet) {
              return Colors.grey.withOpacity(0.1);
            }

            return null;
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            children: state.sheets
                .map((Sheet sheet) => MouseRegion(
                      onEnter: (_) => setState(() => hoveredSheet = sheet),
                      onExit: (_) => setState(() => hoveredSheet = null),
                      child: GestureDetector(
                        onTap: () {
                          calcCubit.selectSheet(sheet);

                          if (isHandset(context)) Navigator.pop(context);
                        },
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
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getContainerColor(sheet),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Center(child: Text(sheet.name)),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
