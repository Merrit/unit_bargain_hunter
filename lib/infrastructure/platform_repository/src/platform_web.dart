import 'platform.dart';

PlatformType getPlatform() => WebPlatform().runningPlatform;

class WebPlatform implements Platform {
  @override
  PlatformType get runningPlatform => PlatformType.web;
}
