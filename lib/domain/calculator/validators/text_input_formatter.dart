import 'package:flutter/services.dart';

extension BetterTextInputFormatter on FilteringTextInputFormatter {
  /// A [TextInputFormatter] that allows only a double, such as `0.42`.
  static final TextInputFormatter doubleOnly =
      FilteringTextInputFormatter.allow(
    RegExp(r'(^\d*\.?\d*)'),
  );
}
