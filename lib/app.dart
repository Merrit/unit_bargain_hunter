import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'application/theme/cubit/theme_cubit.dart';
import 'calculator/calculator_page.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

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
