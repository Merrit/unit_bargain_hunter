import 'package:flutter/material.dart';

import 'calculator/calculator.dart';
import 'theme.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unit Bargain Hunter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: CalculatorPage(),
    );
  }
}
