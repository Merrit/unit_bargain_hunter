import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unit_bargain_hunter/application/calculator/cubit/calculator_cubit.dart';

import 'presentation/app_widget.dart';

void main() {
  runApp(
    ProviderScope(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => CalculatorCubit(),
          ),
        ],
        child: AppWidget(),
      ),
    ),
  );
}
