import 'package:window_size/window_size.dart' as window_size;

import '../logs/logs.dart';

/// Use `window_size` from `flutter-desktop-embedding` to manage the
/// application window on desktop platforms.
///
/// This plugin is a preview that is likely to be moved to a proper
/// package in the future or integrated directly with Flutter.
class Window {
  Window._();

  static Future<Window> initialize() async {
    log.i('Initializing desktop application window.');
    instance = Window._();
    instance.setWindowTitle('Unit Bargain Hunter');
    return instance;
  }

  // TODO: Catch window close event on desktop and trigger sync before closing.

  static late final Window instance;

  void setWindowTitle(String title) => window_size.setWindowTitle(title);
}
