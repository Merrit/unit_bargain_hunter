import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unit_bargain_hunter/application/calculator/cubit/calculator_cubit.dart';

class CompareItemsIntent extends Intent {
  const CompareItemsIntent();
}

class CompareItemsShortcut extends StatelessWidget {
  final Widget child;

  const CompareItemsShortcut({required this.child});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(
          LogicalKeyboardKey.enter,
        ): const CompareItemsIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          CompareItemsIntent: CallbackAction<CompareItemsIntent>(
            onInvoke: (intent) => calcCubit.compare(),
          )
        },
        child: child,
      ),
    );
  }
}
