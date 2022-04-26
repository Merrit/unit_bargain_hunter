import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../app/app.dart';
import '../../core/helpers/helpers.dart';
import '../../platform/platform.dart';
import '../../theme/theme.dart';

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
      builder: (context) => const InfoDialog(),
    );
  }
}

class InfoDialog extends StatelessWidget {
  const InfoDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FormFactor formFactor = getFormFactor(context);
    final bool isHandset = (formFactor == FormFactor.handset);
    final bool isMobile = (isHandset && !Platform.isDesktop && !kIsWeb);
    final ThemeData themeData = Theme.of(context);
    final TextTheme textThemeData = themeData.textTheme;

    final _markdownStyleSheet = MarkdownStyleSheet.fromTheme(
      themeData.copyWith(
        textTheme: textThemeData.copyWith(
          bodyText2: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );

    final _greyButtonStyle = ElevatedButton.styleFrom(
      primary: Colors.grey[700],
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10.0 : 40.0,
            vertical: isMobile ? 50.0 : 24.0,
          ),
          content: ConstrainedBox(
            constraints: isMobile
                ? const BoxConstraints.expand()
                : BoxConstraints(maxWidth: constraints.maxWidth / 1.6),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MarkdownBody(
                    styleSheet: _markdownStyleSheet,
                    data: '''
Hello! 👋

I hope you are enjoying Unit Bargain Hunter.

If you find it useful, please consider buying me a coffee. ☕
''',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: ElevatedButton(
                      onPressed: () {
                        appCubit.launchURL(
                          'https://www.buymeacoffee.com/Merritt',
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('Buy me a coffee '),
                          Icon(Icons.coffee),
                        ],
                      ),
                    ),
                  ),
                  MarkdownBody(
                    styleSheet: _markdownStyleSheet,
                    onTapLink: (String text, String? href, String title) {
                      if (href == null) return;
                      appCubit.launchURL(href);
                    },
                    data: '''
Every contribution is greatly appreciated, and allows me to continue creating. 💙

This app is free and open source software.

Available for: Linux, Windows, Android & Web.''',
                  ),
                  Spacers.verticalMedium,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: _greyButtonStyle,
                        onPressed: () {
                          appCubit.launchURL('https://merritt.codes/bargain/');
                        },
                        child: const Text('Website'),
                      ),
                      Spacers.horizontalSmall,
                      ElevatedButton(
                        style: _greyButtonStyle,
                        onPressed: () {
                          appCubit.launchURL(
                            'https://github.com/Merrit/unit_bargain_hunter',
                          );
                        },
                        child: const Text('GitHub'),
                      ),
                    ],
                  ),
                  Spacers.verticalXtraSmall,
                  BlocBuilder<AppCubit, AppState>(
                    builder: (context, state) {
                      return Text('Version: ${state.runningVersion}');
                    },
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
