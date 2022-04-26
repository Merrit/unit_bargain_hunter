import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'widgets.dart';

class CustomBottomAppBar extends StatelessWidget {
  const CustomBottomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Made with 💙 by '),
                  TextSpan(
                    text: 'Kristen McWilliam',
                    style: const TextStyle(color: Colors.lightBlueAccent),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _showInfoDialog(context),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CustomAboutDialog(),
    );
  }
}
