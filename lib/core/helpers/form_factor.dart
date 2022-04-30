import 'package:flutter/widgets.dart';

class ScreenType {
  static const double desktop = 900;
  static const double tablet = 600;
  static const double handset = 300;
}

enum FormFactor { desktop, tablet, handset, watch }

/// Returns a [FormFactor] enum of one of the following:
/// Desktop, Tablet, Handset, Watch
FormFactor getFormFactor(BuildContext context) {
  // Use .shortestSide to detect device type regardless of orientation
  double deviceWidth = MediaQuery.of(context).size.shortestSide;
  if (deviceWidth > ScreenType.desktop) return FormFactor.desktop;
  if (deviceWidth > ScreenType.tablet) return FormFactor.tablet;
  if (deviceWidth > ScreenType.handset) return FormFactor.handset;
  return FormFactor.watch;
}

bool isLargeFormFactor(BuildContext context) {
  final formFactor = getFormFactor(context);
  final isDesktop = (formFactor == FormFactor.desktop);
  final isTablet = (formFactor == FormFactor.tablet);
  return (isDesktop || isTablet) ? true : false;
}

bool isHandset(BuildContext context) {
  final formFactor = getFormFactor(context);
  return (formFactor == FormFactor.handset);
}
