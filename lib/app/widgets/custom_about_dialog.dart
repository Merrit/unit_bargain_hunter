import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../core/constants.dart';
import '../../theme/styles.dart';
import '../app.dart';

class CustomAboutDialog extends StatelessWidget {
  const CustomAboutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

    final String appVersion =
        'v' + context.read<AppCubit>().state.runningVersion;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return AboutDialog(
          applicationVersion: appVersion,
          applicationIcon: const ImageIcon(
            AssetImage('assets/icon/icon.png'),
            color: Colors.lightBlue,
          ),
          children: [
            MarkdownBody(
              styleSheet: _markdownStyleSheet,
              data: '''
Hello! 👋

I hope you are enjoying Unit Bargain Hunter.

If you find it useful, please consider buying me a coffee. ☕
''',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.coffee),
                      label: const Text('Buy me a coffee'),
                      onPressed: () {
                        appCubit.launchURL(
                          'https://www.buymeacoffee.com/Merritt',
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            MarkdownBody(
              styleSheet: _markdownStyleSheet,
              onTapLink: (String text, String? href, String title) {
                if (href == null) return;
                appCubit.launchURL(href);
              },
              data: '''
Every contribution is greatly appreciated, and allows me to continue creating. 💙

This app is open source software. The source is available on GitHub.

Available for: Linux, Windows, Android & Web.''',
            ),
            Spacers.verticalMedium,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: _greyButtonStyle,
                  onPressed: () => appCubit.launchURL(websiteUrl),
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
          ],
        );
      },
    );
  }
}
