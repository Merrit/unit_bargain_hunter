import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unit_bargain_hunter/application/calculator/cubit/calculator_cubit.dart';
import 'package:unit_bargain_hunter/infrastructure/platform_repository/platform_repository.dart';
import 'package:window_size/window_size.dart' as window;

import 'presentation/app_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (PlatformRepository.isDesktop) {
    window.setWindowTitle('Unit Bargain Hunter');
    window.setWindowFrame(const Offset(1.0, 2.0) & const Size(635, 650));
  }

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
