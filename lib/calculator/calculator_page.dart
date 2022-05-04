import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/widgets/widgets.dart';
import '../core/helpers/helpers.dart';
import 'calculator_cubit/calculator_cubit.dart';
import 'widgets/widgets.dart';

class CalculatorPage extends StatelessWidget {
  CalculatorPage({Key? key}) : super(key: key);

  final focusNode = FocusNode(
    debugLabel: 'Background node',
    skipTraversal: true,
  );

  @override
  Widget build(BuildContext context) {
    Widget? _drawer;
    if (isHandset(context)) _drawer = const Drawer(child: SidePanel());

    final Widget _sidePanelToggleButton =
        BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        if (isHandset(context)) return const SizedBox();
        if (state.showSidePanel) return const SizedBox();

        return Opacity(
          opacity: 0.8,
          child: IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => calcCubit.toggleShowSidePanel(),
          ),
        );
      },
    );

    return SafeArea(
      // GestureDetector & FocusNode allow clicking outside input areas in
      // order to deselect them as expected on web & desktop platforms.
      child: GestureDetector(
        onTap: () => focusNode.requestFocus(),
        child: FocusableActionDetector(
          focusNode: focusNode,
          child: Scaffold(
            appBar: const CustomAppBar(),
            drawer: _drawer,
            body: Stack(
              children: [
                _sidePanelToggleButton,
                CalculatorView(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CalculatorView extends StatelessWidget {
  final focusNode = FocusNode(
    debugLabel: 'CalculatorView node',
    skipTraversal: true,
  );

  CalculatorView({Key? key}) : super(key: key);

  final Widget _sidePanel = BlocBuilder<CalculatorCubit, CalculatorState>(
    builder: (context, state) {
      final bool showSidePanel = !isHandset(context) && state.showSidePanel;
      return ExcludeFocusTraversal(
        child: (showSidePanel) ? const SidePanel() : const SizedBox(),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CalculatorCubit, CalculatorState>(
      listener: (context, state) {
        // When user initiates compare we remove focus from any
        // input fields to have a clean look for the compared items.
        if (state.resultExists) focusNode.requestFocus();
      },
      builder: (context, state) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sidePanel,
            Expanded(
              // GestureDetector & FocusNode allow clicking outside input areas in
              // order to deselect them as expected on web & desktop platforms.
              child: GestureDetector(
                onTap: () => focusNode.requestFocus(),
                child: Focus(
                  focusNode: focusNode,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ExcludeFocusTraversal(
                        child: Stack(
                          children: const [
                            SheetNameWidget(),
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
          ],
        );
      },
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.addListener(() {
        final offset = scrollController.offset;
        final showScrollbar = (offset > 0) ? true : false;
        calcCubit.updateShowScrollbar(showScrollbar);
      });
    });

    return Expanded(
      child: BlocBuilder<CalculatorCubit, CalculatorState>(
        builder: (context, state) {
          return Scrollbar(
            controller: scrollController,
            thumbVisibility: state.alwaysShowScrollbar,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  const SizedBox(width: double.infinity),
                  for (var item in state.activeSheet.items)
                    ItemCard(
                      item: item,
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
