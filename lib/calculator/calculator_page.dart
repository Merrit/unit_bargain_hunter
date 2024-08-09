import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpers/helpers.dart';
import 'package:multi_split_view/multi_split_view.dart';

import '../app/app_widget.dart';
import '../app/widgets/widgets.dart';
import '../core/constants.dart';
import '../l10n/helper.dart';
import '../purchases/pages/purchases_page.dart';
import '../settings/cubit/settings_cubit.dart';
import '../settings/settings.dart';
import 'calculator_cubit/calculator_cubit.dart';
import 'widgets/widgets.dart';

class CalculatorPage extends StatelessWidget {
  static const id = 'calculator_page';

  CalculatorPage({super.key});

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

    return BlocListener<AppCubit, AppState>(
      listener: (context, state) {
        if (state.promptForProUpgrade) {
          Navigator.pushNamed(context, PurchasesPage.id);
        }
      },
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (state.releaseNotes != null) {
              _showReleaseNotesDialog(context, state.releaseNotes!);
            }
          });

          final PreferredSizeWidget? appBar;
          if (mediaQuery.isHandset) {
            appBar = const CustomAppBar();
          } else {
            appBar = null;
          }

          return SafeArea(
            // GestureDetector & FocusNode allow clicking outside input areas in
            // order to deselect them as expected on web & desktop platforms.
            child: GestureDetector(
              onTap: () => focusNode.requestFocus(),
              child: FocusableActionDetector(
                focusNode: focusNode,
                child: Scaffold(
                  appBar: appBar,
                  drawer: drawer,
                  body: const CalculatorView(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showReleaseNotesDialog(
    BuildContext context,
    ReleaseNotes releaseNotes,
  ) {
    final appCubit = context.read<AppCubit>();

    return showDialog(
      context: context,
      builder: (context) => ReleaseNotesDialog(
        releaseNotes: releaseNotes,
        donateCallback: () => appCubit.launchURL(donateUrl),
        launchURL: (url) => appCubit.launchURL(url),
        onClose: () {
          appCubit.dismissReleaseNotesDialog();
          Navigator.pop(context);
        },
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final preferredSize = const Size.fromHeight(kToolbarHeight);

  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        if (state.activeSheet == null) {
          return AppBar();
        }

        return ExcludeFocusTraversal(
          child: AppBar(
            centerTitle: true,
            title: const _SheetNameWidget(),
            actions: const [
              _ExtraActionsDropdown(),
            ],
          ),
        );
      },
    );
  }
}

/// A menu button for extra actions in the app bar related to the active sheet.
class _ExtraActionsDropdown extends StatelessWidget {
  const _ExtraActionsDropdown();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        return MenuAnchor(
          menuChildren: [
            MenuItemButton(
              leadingIcon: const Icon(Icons.edit),
              onPressed: () => showModal(context, const SheetSettingsView()),
              child: Text(context.translations.renameSheet),
            ),
            MenuItemButton(
              leadingIcon: const Icon(Icons.refresh),
              onPressed: () => _confirmResetSheet(context),
              child: Text(context.translations.resetSheet),
            ),
            MenuItemButton(
              leadingIcon: const Icon(Icons.delete),
              onPressed: () {
                showConfirmRemovalDialog(context, state.activeSheet!);
              },
              child: Text(context.translations.deleteSheet),
            ),
          ],
          builder: (context, controller, child) {
            return IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                });
          },
        );
      },
    );
  }
}

class CalculatorView extends StatefulWidget {
  const CalculatorView({super.key});

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  final focusNode = FocusNode(
    debugLabel: 'CalculatorView node',
    skipTraversal: true,
  );

  late MultiSplitViewController multiSplitViewController;
  late SettingsCubit settingsCubit;

  @override
  void initState() {
    super.initState();
    settingsCubit = context.read<SettingsCubit>();
    multiSplitViewController = MultiSplitViewController(
      areas: Area.weights([settingsCubit.state.navigationAreaRatio]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        return MultiSplitView(
          controller: multiSplitViewController,
          onWeightChange: () {
            final navigationAreaRatio = multiSplitViewController //
                .getArea(0)
                .weight;

            if (navigationAreaRatio == null) return;

            settingsCubit.updateNavigationAreaRatio(navigationAreaRatio);
          },
          children: [
            if (defaultTargetPlatform != TargetPlatform.android)
              const ExcludeFocusTraversal(
                child: SidePanel(),
              ),
            GestureDetector(
              onTap: () => focusNode.requestFocus(),
              child: Focus(
                focusNode: focusNode,
                child: const _MainView(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MainView extends StatelessWidget {
  const _MainView();

  @override
  Widget build(BuildContext context) {
    final calcCubit = context.read<CalculatorCubit>();
    final mediaQuery = MediaQuery.of(context);

    const Widget sheetNameWidget = _SheetNameWidget();

    final Widget header;
    if (mediaQuery.isHandset) {
      header = const SizedBox();
    } else {
      header = const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Ensure name widget is centered
          SizedBox(width: 8),
          sheetNameWidget,
          _ExtraActionsDropdown(),
        ],
      );
    }

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

        final Widget compareButton = ElevatedButton(
          onPressed: () => calcCubit.compare(),
          child: const Text('Compare'),
        );

        final Widget addButton = IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => calcCubit.addItem(),
        );

        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              header,
              Expanded(
                child: SingleChildScrollView(
                  controller: ScrollController(),
                  child: Wrap(
                    runSpacing: 20.0,
                    alignment: WrapAlignment.center,
                    children: [
                      const SizedBox(width: double.infinity),
                      for (var item in state.activeSheet!.items)
                        ItemCard(item: item),
                    ],
                  ),
                ),
              ),
              Card(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const CompareByDropdownButton(),
                    compareButton,
                    addButton,
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Displays the sheet's name, and allows the user to change it.
class _SheetNameWidget extends StatelessWidget {
  const _SheetNameWidget();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => showModal(context, const SheetSettingsView()),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              state.activeSheet!.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        );
      },
    );
  }
}

/// Show a dialog to confirm the user wants to reset the sheet.
void _confirmResetSheet(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Reset sheet?'),
      content: const Text(
        'This will remove all items from the sheet.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            context.read<CalculatorCubit>().resetActiveSheet();
            Navigator.pop(context);
          },
          child: const Text('Reset'),
        ),
      ],
    ),
  );
}
