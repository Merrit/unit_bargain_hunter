import 'package:web/web.dart';

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
    EventStreamProviders.contextMenuEvent.forTarget(document).listen((event) {
      event.preventDefault();
    });
  }
}
