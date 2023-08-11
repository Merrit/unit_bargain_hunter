import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart';

Future showModal(BuildContext context, Widget contents) {
  final mediaQuery = MediaQuery.of(context);
  final BoxConstraints? constraints = (mediaQuery.isHandset) //
      ? null
      : const BoxConstraints(maxWidth: 350);

  return showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: context,
    constraints: constraints,
    isScrollControlled: true,
    builder: (context) {
      // SingleChildScrollView with AnimatedPadding allow the modal to move up
      // and out of the way when the virtual keyboard comes on screen.
      return SingleChildScrollView(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: contents,
            ),
          ),
        ),
      );
    },
  );
}
