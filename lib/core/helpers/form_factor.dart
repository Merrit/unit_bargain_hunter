import 'package:flutter/widgets.dart';

/// Categories of different device types.
///
/// Useful for evaluating things like when to show
/// a small mobile UI, or a larger UI suited for tablet, PC, etc.
extension BreakpointHelper on BoxConstraints {
  bool get isTablet => maxWidth > 730;
  bool get isDesktop => maxWidth > 1200;
  bool get isMobile => !isTablet && !isDesktop;
}
