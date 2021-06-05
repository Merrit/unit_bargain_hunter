import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:unit_bargain_hunter/application/calculator/cubit/calculator_cubit.dart';
import 'package:unit_bargain_hunter/domain/calculator/models/models.dart';

class ItemCard extends StatelessWidget {
  final int index;

  const ItemCard({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<int>(
      create: (context) => index,
      child: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
          _ItemContents(),
          _CloseButton(),
        ],
      ),
    );
  }
}

class _ItemContents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 300,
        maxWidth: 160,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 14,
          ),
          child: FocusTraversalGroup(
            child: Focus(
              skipTraversal: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Item ${context.read<int>() + 1}'),
                  SizedBox(height: 10),
                  _PriceWidget(),
                  const SizedBox(height: 20),
                  _QuantityWidget(),
                  const SizedBox(height: 15),
                  Text('Unit'),
                  _UnitChooser(),
                  _PerUnitCalculation(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PriceWidget extends StatelessWidget {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final index = context.read<int>();

    return BlocBuilder<CalculatorCubit, CalculatorState>(
      buildWhen: (previous, current) =>
          previous.items[index].price != current.items[index].price,
      builder: (context, state) {
        final item = state.items[index];
        _controller.text = item.price.toStringAsFixed(2);

        return Focus(
          skipTraversal: true,
          onFocusChange: (focused) {
            if (focused) {
              _controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: item.price.toStringAsFixed(2).length,
              );
            } else {
              calcCubit.updateItem(
                key: item.key,
                price: _controller.text,
              );
            }
          },
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Price',
            ),
            controller: _controller,
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}

class _QuantityWidget extends StatelessWidget {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final index = context.read<int>();

    return BlocBuilder<CalculatorCubit, CalculatorState>(
      buildWhen: (previous, current) =>
          previous.items[index].quantity != current.items[index].quantity,
      builder: (context, state) {
        final item = state.items[index];
        _controller.text = state.items[index].quantity.toStringAsFixed(2);
        return Focus(
          skipTraversal: true,
          onFocusChange: (focused) {
            if (focused) {
              _controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: item.quantity.toStringAsFixed(2).length,
              );
            } else {
              calcCubit.updateItem(
                key: item.key,
                quantity: _controller.text,
              );
            }
          },
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Quantity',
            ),
            controller: _controller,
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}

class _UnitChooser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final index = context.read<int>();

    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        final item = state.items[index];

        return DropdownButton<Unit>(
          value: item.unit,
          onChanged: (value) => calcCubit.updateItem(
            key: item.key,
            unit: value,
          ),
          items: state.comareBy.subTypes
              .map((value) => DropdownMenuItem<Unit>(
                    value: value,
                    child: Text('$value'),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _PerUnitCalculation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final index = context.read<int>();

    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        final item = state.items[index];
        final resultExists = state.result != null;
        if (resultExists) {
          if (item.costPerUnit == null) return Container();
          final costPer = item.costPerUnit!.costPer.toStringAsFixed(3);
          final baseUnit = item.unit.baseUnit;
          return Text('\$$costPer per $baseUnit');
        }
        return Container();
      },
    );
  }
}

class _CloseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final index = context.read<int>();

    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        final item = state.items[index];
        final showCloseButton = state.items.length >= 3;

        return FocusTraversalGroup(
          descendantsAreFocusable: false,
          child: (showCloseButton)
              ? IconButton(
                  onPressed: () => calcCubit.removeItem(item.key),
                  icon: Icon(
                    Icons.close,
                    color: Colors.red[800],
                  ),
                )
              : const SizedBox(),
        );
      },
    );
  }
}
