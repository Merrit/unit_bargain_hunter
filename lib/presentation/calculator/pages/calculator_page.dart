import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:unit_bargain_hunter/application/calculator/cubit/calculator_cubit.dart';

import '../calculator.dart';

class CalculatorPage extends StatelessWidget {
  CalculatorPage({Key? key}) : super(key: key);

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
            appBar: const CustomAppBar(),
            body: CalculatorView(),
            bottomNavigationBar: const CustomBottomAppBar(),
          ),
        ),
      ),
    );
  }
}

class CalculatorView extends StatelessWidget {
  final focusNode = FocusNode();

  CalculatorView({Key? key}) : super(key: key);

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
                    children: const [
                      Text('Compare by:'),
                      SizedBox(width: 10),
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

  ScrollingItemsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Scrollbar is always shown when moved from the top,
    // but hides when at the top or the screen doesn't need to scroll.
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      scrollController.addListener(() {
        final offset = scrollController.offset;
        final showScrollbar = (offset > 0) ? true : false;
        calcCubit.updateShowScrollbar(showScrollbar);
      });
    });

    return Expanded(
      child: BlocBuilder<CalculatorCubit, CalculatorState>(
        buildWhen: (previous, current) =>
            (previous.items.length != current.items.length) ||
            (previous.comareBy != current.comareBy) ||
            (previous.alwaysShowScrollbar != current.alwaysShowScrollbar),
        builder: (context, state) {
          final itemCount = state.items.length;
          return Scrollbar(
            controller: scrollController,
            thumbVisibility: state.alwaysShowScrollbar,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  const SizedBox(width: double.infinity),
                  for (var index = 0; index < itemCount; index++)
                    ItemCard(
                      key: ValueKey(index),
                      index: index,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
