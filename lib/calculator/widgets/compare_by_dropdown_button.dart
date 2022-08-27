import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../calculator_cubit/calculator_cubit.dart';
import '../models/models.dart';

class CompareByDropdownButton extends StatelessWidget {
  const CompareByDropdownButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 12,
          right: 10,
          bottom: 8,
        ),
        child: BlocBuilder<CalculatorCubit, CalculatorState>(
          builder: (context, state) {
            return DropdownButton<Unit>(
              value: state.activeSheet!.compareBy,
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
        ),
      ),
    );
  }
}
