import 'package:flutter/material.dart';

import '../../calculator/calculator_cubit/calculator_cubit.dart';
import '../../calculator/widgets/widgets.dart';
import '../../platform/platform.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final preferredSize = const Size.fromHeight(kToolbarHeight);

  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget compareButton = Padding(
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton(
        onPressed: () => calcCubit.compare(),
        child: const Text('Compare'),
      ),
    );

    return ExcludeFocusTraversal(
      child: AppBar(
        centerTitle: (Platform.isAndroid) ? false : true,
        title: const SheetNameWidget(),
        actions: [
          compareButton,
          const CompareByDropdownButton(),
        ],
      ),
    );
  }
}
