import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpers/helpers.dart';

import '../app/app.dart';
import '../app/widgets/widgets.dart';
import '../purchases/pages/purchases_page.dart';
import 'calculator_cubit/calculator_cubit.dart';
import 'widgets/widgets.dart';

class CalculatorPage extends StatelessWidget {
  static const id = 'calculator_page';

  CalculatorPage({Key? key}) : super(key: key);

  final focusNode = FocusNode(
    debugLabel: 'Background node',
    skipTraversal: true,
  );

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    Widget? drawer;
    if (mediaQuery.isHandset) {
      drawer = const Drawer(child: SidePanel());
    }

    final Widget sidePanelToggleButton =
        BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        if (mediaQuery.isHandset) return const SizedBox();
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

    return BlocListener<AppCubit, AppState>(
      listener: (context, state) {
        if (state.promptForProUpgrade) {
          Navigator.pushNamed(context, PurchasesPage.id);
        }
      },
      child: SafeArea(
        // GestureDetector & FocusNode allow clicking outside input areas in
        // order to deselect them as expected on web & desktop platforms.
        child: GestureDetector(
          onTap: () => focusNode.requestFocus(),
          child: FocusableActionDetector(
            focusNode: focusNode,
            child: Scaffold(
              appBar: const CustomAppBar(),
              drawer: drawer,
              body: Stack(
                children: [
                  sidePanelToggleButton,
                  CalculatorView(),
                ],
              ),
              floatingActionButton:
                  BlocBuilder<CalculatorCubit, CalculatorState>(
                builder: (context, state) {
                  if (state.activeSheet == null) {
                    return const SizedBox();
                  }

                  return FloatingActionButton(
                    onPressed: () => calcCubit.addItem(),
                    child: const Icon(Icons.add),
                  );
                },
              ),
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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final Widget sidePanel = BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        final bool showSidePanel = !mediaQuery.isHandset && state.showSidePanel;
        return ExcludeFocusTraversal(
          child: (showSidePanel) ? const SidePanel() : const SizedBox(),
        );
      },
    );

    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sidePanel,
            Expanded(
              // GestureDetector & FocusNode allow clicking outside input areas in
              // order to deselect them as expected on web & desktop platforms.
              child: GestureDetector(
                onTap: () => focusNode.requestFocus(),
                child: Focus(
                  focusNode: focusNode,
                  child: const ScrollingItemsList(),
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
  const ScrollingItemsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        if (state.activeSheet == null) {
          return Center(
            child: ElevatedButton(
              onPressed: () => calcCubit.addSheet(),
              child: const Text('New sheet'),
            ),
          );
        }

        return SingleChildScrollView(
          controller: ScrollController(),
          child: Wrap(
            runSpacing: 20.0,
            alignment: WrapAlignment.center,
            children: [
              const SizedBox(width: double.infinity),
              for (var item in state.activeSheet!.items)
                ItemCard(
                  item: item,
                ),
            ],
          ),
        );
      },
    );
  }
}
