import 'dart:io' as io;
import 'platform.dart';

PlatformType getPlatform() => PlatformGeneral().runningPlatform;

class PlatformGeneral implements Platform {
  @override
  PlatformType get runningPlatform {
    final platform = io.Platform.operatingSystem;
    switch (platform) {
      case 'linux':
        return PlatformType.linux;
      case 'macos':
        return PlatformType.macos;
      case 'windows':
        return PlatformType.windows;
      case 'android':
        return PlatformType.android;
      case 'ios':
        return PlatformType.ios;
      default:
        throw Exception('Unable to determine operating system.');
    }
  }
}
