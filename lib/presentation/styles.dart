import 'package:flutter/material.dart';

abstract class BorderRadii {
  static BorderRadius gentlyRounded = BorderRadius.circular(10);
}

abstract class Spacers {
  static const horizontalSmall = SizedBox(width: 20);

  static const verticalXtraSmall = SizedBox(height: 10);
  static const verticalSmall = SizedBox(height: 20);
}

class TextStyles {
  static const TextStyle base = TextStyle();

  static TextStyle body1 = base.copyWith(fontSize: 15);

  static TextStyle link1 = body1.copyWith(color: Colors.lightBlueAccent);

  static TextStyle headline1 = base.copyWith(fontSize: 20);
}
