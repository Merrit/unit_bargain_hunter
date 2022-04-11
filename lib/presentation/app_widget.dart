import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unit_bargain_hunter/application/theme/cubit/theme_cubit.dart';

import 'calculator/calculator.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'Unit Bargain Hunter',
          debugShowCheckedModeBanner: false,
          theme: state.themeData,
          home: CalculatorPage(),
        );
      },
    );
  }
}