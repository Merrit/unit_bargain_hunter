import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:unit_bargain_hunter/application/calculator/cubit/calculator_cubit.dart';

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
            bottomNavigationBar: CustomBottomAppBar(),
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
    return BlocListener<CalculatorCubit, CalculatorState>(
      listener: (context, state) {
        // When user initiates compare we remove focus from any
        // input fields to have a clean look for the compared items.
        if (state.resultExists) focusNode.requestFocus();
      },
      // GestureDetector & FocusNode allow clicking outside input areas in
      // order to deselect them as expected on web & desktop platforms.
      child: GestureDetector(
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
                      CompareByDropdownButton(),
                    ],
                  ),
                ),
                ScrollingItemsList(),
              ],
            ),
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
                (previous.items.length != current.items.length) ||
                (previous.comareBy != current.comareBy),
            builder: (context, state) {
              final itemCount = state.items.length;
              return Wrap(
                alignment: WrapAlignment.center,
                children: [
                  SizedBox(width: double.infinity),
                  for (var index = 0; index < itemCount; index++)
                    ItemCard(
                      key: ValueKey(index),
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
