import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:unit_bargain_hunter/application/calculator/cubit/calculator_cubit.dart';
import 'package:unit_bargain_hunter/domain/calculator/calculator.dart';

import '../calculator.dart';

class CalculatorPage extends StatelessWidget {
  CalculatorPage();

  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // GestureDetector & FocusNode allow clicking outside input areas in
      // order to deselect them as expected on web & desktop platforms.
      child: GestureDetector(
        onTap: () => focusNode.requestFocus(),
        child: FocusableActionDetector(
          focusNode: focusNode,
          child: Scaffold(
            appBar: CustomAppBar(),
            body: CalculatorView(),
            bottomNavigationBar: _BottomAppBar(),
          ),
        ),
      ),
    );
  }
}

class CalculatorView extends StatelessWidget {
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    // GestureDetector & FocusNode allow clicking outside input areas in
    // order to deselect them as expected on web & desktop platforms.
    return GestureDetector(
      onTap: () => focusNode.requestFocus(),
      child: Focus(
        focusNode: focusNode,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 12,
                  bottom: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Compare by:'),
                    const SizedBox(width: 10),
                    DropdownButton<Unit>(
                      value: UnitType.weight,
                      items: <Unit>[
                        UnitType.weight,
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
          ),
        ),
      ),
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(children: [
                TextSpan(text: 'Made with ❤ by '),
                TextSpan(
                  text: 'Kristen McWilliam',
                  style: TextStyle(color: Colors.lightBlueAccent),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text('This is dialog'),
                          );
                        },
                      );
                    },
                ),
                TextSpan(text: '.'),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
