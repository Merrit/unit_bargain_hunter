import 'setup_stub.dart'
    if (dart.library.html) 'setup_web.dart'
    if (dart.library.io) 'setup_other.dart';

// Conditional imports for web and other platforms.
// Without this non-web platforms complain dart:html cannot be found.
//
// References:
// https://aschilken.medium.com/flutter-conditional-import-for-web-and-native-9ae6b5a5cd39
// https://github.com/schilken/conditional_import

abstract class Setup {
  void init();
}

final setup = getSetup();
