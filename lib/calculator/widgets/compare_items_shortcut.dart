import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../calculator_cubit/calculator_cubit.dart';

class CompareItemsIntent extends Intent {
  const CompareItemsIntent();
}

/// Trigger the callback to compare items when the user
/// presses `Enter` on the keyboard.
class CompareItemsShortcut extends StatelessWidget {
  final Widget child;

  const CompareItemsShortcut({
    Key? key,
    required this.child,
  }) : super(key: key);

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
