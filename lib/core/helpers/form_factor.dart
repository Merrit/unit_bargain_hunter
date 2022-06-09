import 'package:flutter/widgets.dart';

/// Categories of different device types.
///
/// Useful for evaluating things like when to show
/// a small mobile UI, or a larger UI suited for tablet, PC, etc.
enum FormFactor {
  desktop(deviceWidth: 900),
  tablet(deviceWidth: 600),
  handset(deviceWidth: 300),
  watch(deviceWidth: 0);

  /// The minimum width for this device type.
  final int deviceWidth;

  const FormFactor({required this.deviceWidth});

  /// Returns a [FormFactor] based on the current screen size.
  static FormFactor check(BuildContext context) {
    /// Use `shortestSide` to detect device type regardless of orientation.
    final double deviceWidth = MediaQuery.of(context).size.shortestSide;
    if (deviceWidth > desktop.deviceWidth) return desktop;
    if (deviceWidth > tablet.deviceWidth) return tablet;
    if (deviceWidth > handset.deviceWidth) return handset;
    return FormFactor.watch;
  }

  /// Whether the current screen size counts as running on a handset / phone.
  static bool isHandset(BuildContext context) {
    return check(context) == FormFactor.handset;
  }
}
