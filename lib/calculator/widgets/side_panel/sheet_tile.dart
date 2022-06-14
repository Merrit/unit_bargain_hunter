import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/helpers/helpers.dart';
import '../../../purchases/cubit/purchases_cubit.dart';
import '../../../purchases/pages/purchases_page.dart';
import '../../calculator_cubit/calculator_cubit.dart';
import '../../models/models.dart';

class SheetTile extends StatefulWidget {
  final Sheet sheet;

  const SheetTile(
    this.sheet, {
    Key? key,
  }) : super(key: key);

  @override
  State<SheetTile> createState() => _SheetTileState();
}

class _SheetTileState extends State<SheetTile> {
  late final Sheet sheet;

  @override
  void initState() {
    sheet = widget.sheet;
    super.initState();
  }

  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        final int index = state.sheets.indexOf(sheet);
        final bool isActiveSheet = (sheet == state.activeSheet);
        final bool proPurchased = context //
            .watch<PurchasesCubit>()
            .state
            .proPurchased;
        final bool proFeaturesDisabled = !proPurchased && (index > 4);

        List<PopupMenuItem> contextMenuItems(Sheet sheet) {
          return [
            if (state.sheets.length > 1)
              PopupMenuItem(
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => _showConfirmRemovalDialog(context, sheet),
              ),
          ];
        }

        return Opacity(
          opacity: (proFeaturesDisabled) ? 0.4 : 1.0,
          child: Slidable(
            groupTag: '0',
            enabled: mediaQuery.isHandset,
            endActionPane: ActionPane(
              motion: const StretchMotion(),
              children: [
                SlidableAction(
                  label: 'Delete',
                  icon: Icons.delete_forever,
                  backgroundColor: Colors.red.shade600,
                  onPressed: (context) {
                    _showConfirmRemovalDialog(context, sheet);
                  },
                ),
              ],
            ),
            child: Builder(
              builder: (context) {
                return GestureDetector(
                  onSecondaryTapUp: (TapUpDetails details) {
                    showContextMenu(
                      context: context,
                      offset: details.globalPosition,
                      items: contextMenuItems(sheet),
                    );
                  },
                  child: MouseRegion(
                    onEnter: (_) => setState(() => isHovered = true),
                    onExit: (_) => setState(() => isHovered = false),
                    child: Material(
                      type: MaterialType.transparency,
                      child: Builder(builder: (context) {
                        final listTile = ListTile(
                          selected: isActiveSheet,
                          title: Text(
                            sheet.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            if (proFeaturesDisabled) {
                              Navigator.pushNamed(context, PurchasesPage.id);
                            } else {
                              calcCubit.selectSheet(sheet);

                              if (mediaQuery.isHandset) {
                                Navigator.pop(context);
                              }
                            }
                          },
                          trailing: isHovered
                              ? ReorderableDragStartListener(
                                  index: state.sheets.indexOf(sheet),
                                  child: const Icon(Icons.drag_handle),
                                )
                              : null,
                        );

                        if (mediaQuery.isHandset) {
                          return ReorderableDelayedDragStartListener(
                            index: state.sheets.indexOf(sheet),
                            child: listTile,
                          );
                        } else {
                          return listTile;
                        }
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// Confirm the user really wants to remove the sheet.
void _showConfirmRemovalDialog(BuildContext context, Sheet sheet) {
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
