import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpers/helpers.dart';
import 'package:super_context_menu/super_context_menu.dart';

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
    super.key,
  });

  @override
  State<SheetTile> createState() => _SheetTileState();
}

class _SheetTileState extends State<SheetTile> {
  late CalculatorCubit calcCubit;
  late final Sheet sheet;

  @override
  void initState() {
    calcCubit = context.read<CalculatorCubit>();
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

          final Widget? subtitle = (sheet.subtitle != null) //
              ? Text(sheet.subtitle!)
              : null;

          return ContextMenuWidget(
            // Context menu is disabled on mobile, as it conflicts with the long
            // press to reorder sheets.
            // Instead, users can access such settings via the app bar.
            contextMenuIsAllowed: (_) => !defaultTargetPlatform.isMobile,
            menuProvider: (_) {
              return Menu(
                children: [
                  MenuAction(
                    title: 'Remove',
                    callback: () => _showConfirmRemovalDialog(context, sheet),
                  ),
                ],
              );
            },
            child: Opacity(
              opacity: (proFeaturesDisabled) ? 0.4 : 1.0,
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
                        subtitle: subtitle,
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

  /// Shows a dialog to confirm the removal of a [Sheet].
  Future<void> _showConfirmRemovalDialog(
    BuildContext context,
    Sheet sheet,
  ) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove sheet?'),
          content: Text(
              'Are you sure you want to remove the sheet "${sheet.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      calcCubit.removeSheet(sheet);
    }
  }
}
