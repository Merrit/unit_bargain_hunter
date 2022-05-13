// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';

import 'setup.dart';

Setup getSetup() => WebSetup();

/// Setup tasks specific to Flutter Web.
class WebSetup implements Setup {
  @override
  void init() => _disableWebRightClick();

  /// Disable right-click on Web platform.
  ///
  /// This allows us to show a custom right-click
  /// menu in the style of a desktop application.
  void _disableWebRightClick() {
    document.onContextMenu.listen((event) => event.preventDefault());
  }
}
