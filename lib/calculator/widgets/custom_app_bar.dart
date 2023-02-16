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
            title: const SheetNameWidget(),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => showModal(context, const SheetSettingsView()),
              )
            ],
          ),
        );
      },
    );
  }
}
