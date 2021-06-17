import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:window_size/window_size.dart' as _window;

class Window {
  const Window();

  Future<Offset> _getScreenCenter() async {
    final screen = await _window.getCurrentScreen();
    final screenRect = screen?.visibleFrame;
    final position = screenRect?.center ?? Offset.zero;
    if (position == Offset.zero) print('Unable to find screen center.');
    return position;
  }

  void setWindowTitle(String title) {
    _window.setWindowTitle(title);
  }

  /// Defaults to centering the window, however a check
  /// could be added to customize the initial window position.
  Future<void> setWindowFrame({
    required double width,
    required double height,
  }) async {
    if (kDebugMode) return;
    final position = await _getScreenCenter();
    _window.setWindowFrame(
      Rect.fromCenter(center: position, width: 635, height: 650),
    );
  }
}
