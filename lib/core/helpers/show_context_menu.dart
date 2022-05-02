import 'package:flutter/material.dart';

/// Show a popup context menu.
///
/// Like what is normally expected when right-clicking on desktop or
/// long-pressing on mobile. The popup appears near where the
/// click / press interaction occurred by passing the [offset], for
/// example from a [GestureDetector]'s `onSecondaryTapUp`:
///
/// ```dart
/// onSecondaryTapUp: (TapUpDetails details) {
///   showContextMenu(
///     context: context,
///     offset: details.globalPosition,
///     items: [...],
///   );
/// }
/// ```.
showContextMenu({
  required BuildContext context,
  required Offset offset,
  required List<PopupMenuItem> items,
}) async {
  final screenSize = MediaQuery.of(context).size;
  double left = offset.dx;
  double top = offset.dy;
  double right = screenSize.width - offset.dx;
  double bottom = screenSize.height - offset.dy;

  await showMenu(
    context: context,
    position: RelativeRect.fromLTRB(left, top, right, bottom),
    elevation: 8.0,
    items: items,
  );
}
