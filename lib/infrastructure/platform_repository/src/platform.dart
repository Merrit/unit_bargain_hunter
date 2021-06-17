import 'platform_stub.dart'
    if (dart.library.html) 'platform_web.dart'
    if (dart.library.io) 'platform_general.dart';

enum PlatformType {
  linux,
  macos,
  windows,
  android,
  ios,
  web,
}

abstract class Platform {
  PlatformType get runningPlatform;
}

final platform = getPlatform();
