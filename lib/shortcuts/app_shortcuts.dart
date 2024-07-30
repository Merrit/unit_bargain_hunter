import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'shortcuts.dart';

/// Shortcuts that are available everywhere in the app.
///
/// This widget is to be wrapped around the app widget.
class AppShortcuts extends StatelessWidget {
  final Widget child;

  AppShortcuts({
    super.key,
    required this.child,
  });

  final _shortcuts = <ShortcutActivator, Intent>{
    const SingleActivator(
      LogicalKeyboardKey.keyQ,
      control: true,
    ): const QuitIntent(),
  };

  final _actions = <Type, Action<Intent>>{
    QuitIntent: QuitAction(),
  };

  @override
  Widget build(BuildContext context) {
    return Shortcuts.manager(
      manager: LoggingShortcutManager(shortcuts: _shortcuts),
      child: Actions(
        dispatcher: LoggingActionDispatcher(),
        actions: _actions,
        child: child,
      ),
    );
  }
}
