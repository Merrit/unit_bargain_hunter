import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart';

Future showModal(BuildContext context, Widget contents) {
  final mediaQuery = MediaQuery.of(context);
  BoxConstraints? constraints = (mediaQuery.isHandset) //
      ? null
      : const BoxConstraints(maxWidth: 500);

  return showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: context,
    constraints: constraints,
    builder: (context) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: contents,
        ),
      );
    },
  );
}
