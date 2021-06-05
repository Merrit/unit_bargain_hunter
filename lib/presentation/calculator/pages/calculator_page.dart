import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:unit_bargain_hunter/application/calculator/cubit/calculator_cubit.dart';
import 'package:unit_bargain_hunter/application/providers.dart';
import 'package:unit_bargain_hunter/domain/calculator/calculator.dart';

import '../calculator.dart';

class CalculatorPage extends StatelessWidget {
  const CalculatorPage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _AppBar(),
        body: CalculatorView(),
        bottomNavigationBar: _BottomAppBar(),
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final preferredSize = Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.help_outline),
        ),
      ],
    );
  }
}

class CalculatorView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final state = context.read<CalculatorCubit>();
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 12,
            bottom: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text('Compare by:'),
              const SizedBox(width: 10),
              DropdownButton<Unit>(
                value: UnitType.weight,
                items: <Unit>[
                  UnitType.weight,
                  // Volume(),
                ]
                    .map(
                      (unitType) => DropdownMenuItem(
                        value: unitType,
                        child: Text('$unitType'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {},
              ),
            ],
          ),
        ),
        ScrollingItemsList(),
      ],
    );
  }
}

class ScrollingItemsList extends StatelessWidget {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Scrollbar(
        controller: scrollController,
        isAlwaysShown: true,
        child: SingleChildScrollView(
          controller: scrollController,
          child: BlocBuilder<CalculatorCubit, CalculatorState>(
            buildWhen: (previous, current) =>
                previous.items.length != current.items.length,
            builder: (context, state) {
              final itemCount = state.items.length;
              return Wrap(
                alignment: WrapAlignment.center,
                children: [
                  SizedBox(width: double.infinity),
                  // ...state.items.map((item) => ItemCard(item: item)).toList(),
                  for (var index = 0; index < itemCount; index++)
                    ItemCard(
                      key: ValueKey(index),
                      // item: state.items[index],
                      index: index,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BottomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
            ElevatedButton(
              onPressed: () => calcCubit.compare(),
              child: Text('Compare'),
            ),
            IconButton(
              onPressed: () => calcCubit.addItem(),
              icon: Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
