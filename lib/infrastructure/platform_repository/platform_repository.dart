import 'src/platform.dart';

abstract class PlatformRepository {
  const PlatformRepository();

  static final PlatformType _platformType = platform;

  static bool get isLinux => _platformType == PlatformType.linux;
  static bool get isMacOS => _platformType == PlatformType.macos;
  static bool get isWindows => _platformType == PlatformType.windows;
  static bool get isAndroid => _platformType == PlatformType.android;
  static bool get isIOS => _platformType == PlatformType.ios;
  static bool get isWeb => _platformType == PlatformType.web;

  static bool get isDesktop => isLinux || isMacOS || isWindows;
}
