import 'package:flutter/material.dart';

/// Given a string containing emojis, builds a RichText widget where the
/// emojis are separate `TextSpan`s that will display emoji correctly.
///
/// https://github.com/flutter/flutter/issues/75188
class EmojiText extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;

  const EmojiText({
    Key? key,
    required this.text,
    this.textStyle,
  }) : super(key: key);

  bool shouldBreak(bool isEmoji, int value) {
    if (isEmoji) {
      return value <= 255;
    } else {
      return value > 255;
    }
  }

  @override
  Widget build(BuildContext context) {
    final emojiTextStyle = textStyle?.copyWith(fontFamily: 'Emoji') ??
        const TextStyle(fontFamily: 'Emoji');
    final List<TextSpan> children = [];
    final Runes runes = text.runes;

    for (int i = 0; i < runes.length;) {
      int current = runes.elementAt(i);
      final bool isEmoji = current > 255;

      final chunk = <int>[];
      while (!shouldBreak(isEmoji, current)) {
        chunk.add(current);
        if (++i >= runes.length) break;
        current = runes.elementAt(i);
      }

      children.add(
        TextSpan(
          text: String.fromCharCodes(chunk),
          style: isEmoji ? emojiTextStyle : textStyle,
        ),
      );
    }

    return Text.rich(TextSpan(children: children));
  }
}
