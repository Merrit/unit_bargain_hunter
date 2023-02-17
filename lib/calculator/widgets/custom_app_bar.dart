import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../calculator_cubit/calculator_cubit.dart';
import 'widgets.dart';
import '../../platform/platform.dart';
import '../../app/widgets/widgets.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final preferredSize = const Size.fromHeight(kToolbarHeight);

  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        if (state.activeSheet == null) {
          return AppBar();
        }

        return ExcludeFocusTraversal(
          child: AppBar(
            centerTitle: (Platform.isAndroid) ? false : true,
            title: const _SheetNameWidget(),
          ),
        );
      },
    );
  }
}

/// Displays the sheet's name, and allows the user to change it.
class _SheetNameWidget extends StatelessWidget {
  const _SheetNameWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => showModal(context, const SheetSettingsView()),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.activeSheet!.name),
                const SizedBox(width: 4),
                const Opacity(
                  opacity: 0.6,
                  child: Icon(
                    Icons.edit,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
