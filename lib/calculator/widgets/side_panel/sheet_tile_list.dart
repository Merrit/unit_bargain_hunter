import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../calculator_cubit/calculator_cubit.dart';
import '../../models/models.dart';
import 'sheet_tile.dart';

/// The scrolling list of tiles in the drawer for each calculator sheet.
class SheetTileList extends StatefulWidget {
  const SheetTileList({super.key});

  @override
  State<SheetTileList> createState() => _SheetTileListState();
}

class _SheetTileListState extends State<SheetTileList> {
  @override
  Widget build(BuildContext context) {
    final calcCubit = context.read<CalculatorCubit>();

    return Expanded(
      child: BlocBuilder<CalculatorCubit, CalculatorState>(
        builder: (context, state) {
          return ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            onReorder: (int oldIndex, int newIndex) {
              calcCubit.reorderSheets(oldIndex, newIndex);
            },
            buildDefaultDragHandles: false,
            itemCount: state.sheets.length,
            itemBuilder: (BuildContext context, int index) {
              final Sheet sheet = state.sheets[index];
              return SheetTile(
                sheet,
                key: ValueKey(sheet),
              );
            },
          );
        },
      ),
    );
  }
}
