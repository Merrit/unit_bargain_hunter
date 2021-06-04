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
      // theme: ThemeData(
      //   brightness: Brightness.dark,
      //   primarySwatch: Colors.blue,
      // ),
      home: CalculatorPage(),
    );
  }
}
