import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unit_bargain_hunter/application/calculator/cubit/calculator_cubit.dart';
import 'package:unit_bargain_hunter/domain/calculator/calculator.dart';

class CompareByDropdownButton extends StatelessWidget {
  const CompareByDropdownButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        return DropdownButton<Unit>(
          value: state.comareBy,
          items: UnitType.all
              .map(
                (unitType) => DropdownMenuItem(
                  value: unitType,
                  child: Text('$unitType'),
                ),
              )
              .toList(),
          onChanged: (value) => calcCubit.updateCompareBy(value!),
        );
      },
    );
  }
}
