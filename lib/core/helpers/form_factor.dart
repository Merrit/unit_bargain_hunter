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
}

extension FormFactorHelper on MediaQueryData {
  /// Returns a [FormFactor] based on the current screen size.
  FormFactor get formFactor {
    /// Use `shortestSide` to detect device type regardless of orientation.
    final double deviceWidth = size.shortestSide;
    if (deviceWidth > FormFactor.desktop.deviceWidth) return FormFactor.desktop;
    if (deviceWidth > FormFactor.tablet.deviceWidth) return FormFactor.tablet;
    if (deviceWidth > FormFactor.handset.deviceWidth) return FormFactor.handset;
    return FormFactor.watch;
  }

  /// Whether the current screen size counts as running on a handset / phone.
  bool get isHandset {
    return formFactor == FormFactor.handset;
  }
}
