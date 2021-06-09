import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:unit_bargain_hunter/application/calculator/cubit/calculator_cubit.dart';
import 'package:unit_bargain_hunter/application/item/cubit/item_cubit.dart';
import 'package:unit_bargain_hunter/domain/calculator/models/models.dart';

class ItemCard extends StatelessWidget {
  final int index;

  const ItemCard({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ItemCubit(calcCubit, index),
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
        maxWidth: 200,
      ),
      child: BlocBuilder<ItemCubit, ItemState>(
        buildWhen: (previous, current) =>
            previous.isCheapest != current.isCheapest,
        builder: (context, state) {
          return Card(
            elevation: 2,
            color: (state.isCheapest) ? Colors.green[700] : null,
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
                      Text('Item ${context.read<ItemCubit>().state.index + 1}'),
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
          );
        },
      ),
    );
  }
}

class _PriceWidget extends StatelessWidget {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemCubit, ItemState>(
      buildWhen: (previous, current) =>
          previous.item.price != current.item.price,
      builder: (context, state) {
        final item = state.item;
        final priceAsString = item.price.toStringAsFixed(2);
        _controller.text = priceAsString;

        return Focus(
          skipTraversal: true,
          onFocusChange: (focused) {
            if (focused) {
              _controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: priceAsString.length,
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
    return BlocBuilder<ItemCubit, ItemState>(
      buildWhen: (previous, current) =>
          previous.item.quantity != current.item.quantity,
      builder: (context, state) {
        final item = state.item;
        final quantityAsString = item.quantity.toStringAsFixed(2);
        _controller.text = quantityAsString;
        return Focus(
          skipTraversal: true,
          onFocusChange: (focused) {
            if (focused) {
              _controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: quantityAsString.length,
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
    return BlocBuilder<ItemCubit, ItemState>(
      builder: (context, state) {
        final item = state.item;

        return DropdownButton<Unit>(
          value: item.unit,
          onChanged: (value) => calcCubit.updateItem(
            key: item.key,
            unit: value,
          ),
          items: context
              .watch<CalculatorCubit>()
              .state
              .comareBy
              .subTypes
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
    return BlocBuilder<ItemCubit, ItemState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var unit in state.costPerUnits)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(unit),
              ),
          ],
        );
      },
    );
  }
}

class _CloseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemCubit, ItemState>(
      builder: (context, state) {
        return FocusTraversalGroup(
          descendantsAreFocusable: false,
          child: (state.shouldShowCloseButton)
              ? IconButton(
                  onPressed: () => calcCubit.removeItem(state.item.key),
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
