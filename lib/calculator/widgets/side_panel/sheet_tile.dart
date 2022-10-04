import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpers/helpers.dart';

import '../../../purchases/cubit/purchases_cubit.dart';
import '../../../purchases/pages/purchases_page.dart';
import '../../calculator_cubit/calculator_cubit.dart';
import '../../models/models.dart';

/// A reference to the current sheet for each [SheetTile], via `Riverpod`.
///
/// Accessing this means not having to pass the [Sheet] to child widgets.
final _currentSheet = Provider<Sheet>((ref) => throw UnimplementedError());

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

    return ProviderScope(
      overrides: [
        _currentSheet.overrideWithValue(sheet),
      ],
      child: BlocBuilder<CalculatorCubit, CalculatorState>(
        builder: (context, state) {
          final int index = state.sheets.indexOf(sheet);
          final bool isActiveSheet = (sheet == state.activeSheet);
          final bool proPurchased = context //
              .watch<PurchasesCubit>()
              .state
              .proPurchased;
          final bool proFeaturesDisabled = !proPurchased && (index > 4);

          // List<PopupMenuItem> buildListContextMenuItems(Sheet sheet) {
          //   return [
          //     PopupMenuItem(
          //       child: const Text(
          //         'Remove',
          //         style: TextStyle(color: Colors.red),
          //       ),
          //       onTap: () => _showConfirmRemovalDialog(context, sheet),
          //     ),
          //   ];
          // }

          return Opacity(
            opacity: (proFeaturesDisabled) ? 0.4 : 1.0,
            child: GestureDetector(
              // onSecondaryTapUp: (TapUpDetails details) {
              //   showContextMenu(
              //     context: context,
              //     offset: details.globalPosition,
              //     items: buildListContextMenuItems(sheet),
              //   );
              // },
              child: MouseRegion(
                onEnter: (_) => setState(() => isHovered = true),
                onExit: (_) => setState(() => isHovered = false),
                child: Material(
                  type: MaterialType.transparency,
                  child: Builder(
                    builder: (context) {
                      final listTile = ListTile(
                        selected: isActiveSheet,
                        title: Text(sheet.name),
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
                      );

                      if (mediaQuery.isHandset) {
                        return ReorderableDelayedDragStartListener(
                          index: state.sheets.indexOf(sheet),
                          child: listTile,
                        );
                      } else {
                        return ReorderableDragStartListener(
                          index: state.sheets.indexOf(sheet),
                          child: listTile,
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
