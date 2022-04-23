import 'package:flutter/widgets.dart';

extension TextEditingControllerHelper on TextEditingController {
  /// Clean & easy way to 'select all' in a text field.
  void selectAll() {
    if (text.isEmpty) return;
    selection = TextSelection(baseOffset: 0, extentOffset: text.length);
  }
}
