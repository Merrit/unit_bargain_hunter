import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unit_bargain_hunter/application/app/cubit/app_cubit.dart';
import 'package:unit_bargain_hunter/application/theme/cubit/theme_cubit.dart';
import 'package:unit_bargain_hunter/presentation/styles.dart';

class CustomBottomAppBar extends StatelessWidget {
  const CustomBottomAppBar();

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
                    style: TextStyle(color: Colors.lightBlueAccent),
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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return AlertDialog(
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth / 1.6),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        foregroundImage:
                            AssetImage('assets/images/bio-photo.jpg'),
                        radius: 50,
                      ),
                      Spacers.horizontalSmall,
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Hello! My name is Kristen.\n'
                                'I am the developer of this app. \n'
                                '\n'
                                'My website:'),
                            TextButton(
                              onPressed: () => appCubit.launchURL(
                                'https://merritt.codes',
                              ),
                              child: Text(
                                'https://merritt.codes',
                                style: TextStyles.link1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Spacers.verticalSmall,
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'If you find Unit Bargain Hunter useful and '
                              'would like to show appreciation you can ',
                        ),
                        TextSpan(
                          text: 'buy me a coffee',
                          style: TextStyles.link1,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => appCubit.launchURL(
                                  'https://merritt.codes/support',
                                ),
                        ),
                        const TextSpan(text: '. ☕'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  InkWell(
                    onTap: () => appCubit.launchURL(
                      'https://merritt.codes/bargain.html',
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[
                            context.read<ThemeCubit>().state.isDarkTheme
                                ? 850
                                : 300],
                        borderRadius: BorderRadii.gentlyRounded,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          'Find bargains on these platforms: ',
                                    ),
                                    WidgetSpan(
                                      child: Icon(
                                        Icons.launch,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // const Text('Find bargains on these platforms:\n'),
                              // Icon(Icons.launch),
                            ],
                          ),
                          const Text('Windows, Linux, Android & web.'),
                        ],
                      ),
                    ),
                  ),
                  Spacers.verticalSmall,
                  const Text(
                      'This app is free and libre / open source software.'),
                  const Text('The source code is available on GitHub.'),
                  IconButton(
                    onPressed: () => appCubit.launchURL(
                      'https://github.com/Merrit/unit_bargain_hunter',
                    ),
                    icon: const FaIcon(FontAwesomeIcons.github),
                  ),
                  Spacers.verticalMedium,
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
