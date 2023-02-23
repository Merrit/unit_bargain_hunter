import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants.dart';
import '../../theme/styles.dart';
import '../app_widget.dart';
import 'widgets.dart';

class CustomAboutDialog extends StatelessWidget {
  const CustomAboutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final greyButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.grey[700],
    );

    final String appVersion =
        'v${context.read<AppCubit>().state.runningVersion}';

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return AboutDialog(
          applicationVersion: appVersion,
          applicationIcon: const ImageIcon(
            AssetImage('assets/icon/icon.png'),
            color: Colors.lightBlue,
          ),
          children: [
            const EmojiText(text: '''
Hello! 👋

I hope you are enjoying Unit Bargain Hunter.
If you find this app useful, please consider donating to support its development.
'''),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: ElevatedButton(
                      child: const Text('Donate'),
                      onPressed: () => AppCubit.instance.launchURL(donateUrl),
                    ),
                  ),
                ),
              ],
            ),
            const EmojiText(text: '''
Every contribution is greatly appreciated, and allows me to continue creating. 💙

This app is open source software. The source is available on GitHub.
Available for: Linux, Windows, Android & Web.'''),
            Spacers.verticalMedium,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: greyButtonStyle,
                  onPressed: () => AppCubit.instance.launchURL(websiteUrl),
                  child: const Text('Website'),
                ),
                Spacers.horizontalSmall,
                ElevatedButton(
                  style: greyButtonStyle,
                  onPressed: () {
                    AppCubit.instance.launchURL(
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
