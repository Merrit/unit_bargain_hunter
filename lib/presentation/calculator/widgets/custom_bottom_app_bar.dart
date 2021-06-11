import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unit_bargain_hunter/application/calculator/cubit/calculator_cubit.dart';
import 'package:unit_bargain_hunter/presentation/styles.dart';

class CustomBottomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(children: [
                TextSpan(text: 'Made with ❤ by '),
                TextSpan(
                  text: 'Kristen McWilliam',
                  style: TextStyle(color: Colors.lightBlueAccent),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _showInfoDialog(context),
                ),
                TextSpan(text: '.'),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => InfoDialog(),
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
                      CircleAvatar(
                        foregroundImage:
                            AssetImage('assets/images/bio-photo.jpg'),
                        radius: 50,
                      ),
                      Spacers.horizontalSmall,
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hello! My name is Kristen.\n'
                                'I am the developer of this app.'),
                            TextButton(
                              onPressed: () => calcCubit.launchDonateURL(
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
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'If you find Unit Bargain Hunter useful and '
                              'would like to show appreciation you can ',
                          style: TextStyles.body1,
                        ),
                        TextSpan(
                          text: 'buy me a coffee',
                          style: TextStyles.link1,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => calcCubit.launchDonateURL(
                                  'https://merritt.codes/support',
                                ),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text('Find bargains on these platforms:\n'),
                  // TODO: Add IconButtons for other platform links.
                  Placeholder(
                    fallbackHeight: 30,
                  ),
                  Spacers.verticalSmall,
                  Text('This app is free and libre / open source software.'),
                  Text('The source code is available on GitHub.'),
                  IconButton(
                    onPressed: () => calcCubit.launchDonateURL(
                      'https://github.com/Merrit/unit_bargain_hunter',
                    ),
                    icon: FaIcon(FontAwesomeIcons.github),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
