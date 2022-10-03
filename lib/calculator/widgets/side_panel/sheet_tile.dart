import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:helpers/helpers.dart';

import '../../../demonstration/cubit/demonstration_cubit.dart';
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

          List<PopupMenuItem> contextMenuItems(Sheet sheet) {
            return [
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
            child: _Slidable(
              child: GestureDetector(
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
            ),
          );
        },
      ),
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

class _Slidable extends StatefulWidget {
  final Widget child;

  const _Slidable({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<_Slidable> createState() => _SlidableState();
}

class _SlidableState extends State<_Slidable> {
  late bool slidableEnabled;

  /// Demonstrate how the slidable works, and that it exists.
  Future<void> _demoSlidable(BuildContext context) async {
    if (!slidableEnabled) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final slidable = Slidable.of(context);
      if (slidable == null) return;

      await Future.delayed(const Duration(milliseconds: 1500));
      slidable.openEndActionPane();
      await Future.delayed(const Duration(milliseconds: 800));
      slidable.close();
    });

    demonstrationCubit.setSlidableDemoShown();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    slidableEnabled = mediaQuery.isHandset;

    return Consumer(
      builder: (context, ref, _) {
        final sheet = ref.watch(_currentSheet);

        return Slidable(
          groupTag: '0',
          enabled: slidableEnabled,
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
          child: BlocBuilder<DemonstrationCubit, DemonstrationState>(
            builder: (context, state) {
              if (sheet.index == 0 && !state.slidableDemoShown) {
                _demoSlidable(context);
              }

              return widget.child;
            },
          ),
        );
      },
    );
  }
}
