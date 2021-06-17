import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unit_bargain_hunter/application/calculator/cubit/calculator_cubit.dart';
import 'package:unit_bargain_hunter/infrastructure/platform_repository/platform_repository.dart';
import 'package:unit_bargain_hunter/infrastructure/platform_repository/src/window.dart';

import 'presentation/app_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CalculatorCubit(),
        ),
      ],
      child: AppWidget(),
    ),
  );
}

void init() async {
  if (PlatformRepository.isDesktop) {
    final window = Window();
    window.setWindowTitle('Unit Bargain Hunter');
    window.setWindowFrame(width: 635, height: 650);
  }
}
