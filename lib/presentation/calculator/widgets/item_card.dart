import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unit_bargain_hunter/application/calculator/cubit/calculator_cubit.dart';
import 'package:unit_bargain_hunter/application/item/cubit/item_cubit.dart';

import 'package:unit_bargain_hunter/domain/calculator/models/models.dart';

class ItemCard extends StatelessWidget {
  // final int index;
  final Item item;

  const ItemCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ItemCubit(calcCubit, index: index),
      child: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
          _ItemContents(),
          Focus(
            skipTraversal: true,
            child: _CloseButton(),
          ),
        ],
      ),
    );
  }
}

late ItemCubit _itemCubit;

class _ItemContents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // itemCubit = context.read<ItemCubit>();
    _itemCubit = context.watch<ItemCubit>();
    final quantityController = _itemCubit.quantityController;
    final itemState = context.watch<ItemCubit>().state;

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
              onFocusChange: (focused) {
                if (!focused) {
                  calcCubit.updateItem(
                    index: _itemCubit.state.index,
                    price: _itemCubit.priceController.text,
                    quantity: _itemCubit.quantityController.text,
                  );
                  // calculatorNotifier.updateItem(
                  //   index: itemState.index,
                  //   price: context
                  //       .read(itemProvider.notifier)
                  //       .priceController
                  //       .text,
                  //   quantity: context
                  //       .read(itemProvider.notifier)
                  //       .quantityController
                  //       .text,
                  // );
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Item ${itemState.index + 1}'),
                  SizedBox(height: 10),
                  _PriceWidget(),
                  const SizedBox(height: 20),
                  // Quantity
                  Focus(
                    skipTraversal: true,
                    onFocusChange: (focused) {
                      if (focused) {
                        quantityController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset:
                              itemState.item.quantity.toStringAsFixed(2).length,
                        );
                      } else {
                        // calculatorNotifier.updateItem(
                        //   index: itemState.index,
                        //   quantity: quantityController.text,
                        // );
                      }
                    },
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                      ),
                      controller: quantityController,
                      textAlign: TextAlign.center,
                      // onEditingComplete: () {
                      //   calculatorNotifier.updateItem(
                      //     index: itemState.index,
                      //     quantity: quantityController.text,
                      //   );
                      // },
                      // onChanged: (value) {
                      //   calculatorNotifier.updateItem(
                      //     index: _itemState.index,
                      //     quantity: value,
                      //   );
                      // },
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text('Unit'),
                  _UnitChooser(),
                  Text(
                    (context.watch<CalculatorCubit>().state.result != null)
                        ? '\$${itemState.item.costPerUnit?.costPer} per ${itemState.item.unit.baseUnit}'
                        : '',
                  ),
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
  @override
  Widget build(BuildContext context) {
    final priceController = _itemCubit.priceController;
    final price =
        context.watch<ItemCubit>().state.item.price.toStringAsFixed(2);

    return Focus(
      skipTraversal: true,
      onFocusChange: (focused) {
        if (focused) {
          priceController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: price.length,
          );
        } else {
          // calculatorNotifier.updateItem(
          //   index: _itemState.index,
          //   price: priceController.text,
          // );
        }
      },
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Price',
        ),
        controller: priceController,
        textAlign: TextAlign.center,
        // onChanged: (value) {
        //   priceController.text = value;
        //   // calculatorNotifier.updateItem(
        //   //   index: index,
        //   //   price: value,
        //   // );
        // },
      ),
    );
  }
}

class _UnitChooser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<Unit>(
      value: context.watch<ItemCubit>().state.item.unit,
      onChanged: (value) => calcCubit.updateItem(
        index: _itemCubit.state.index,
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
  }
}

class _CloseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        final shouldShowCloseButton = state.items.length >= 3;
        return (shouldShowCloseButton)
            ? IconButton(
                onPressed: () => calcCubit.removeItem(_itemCubit.state.index),
                icon: Icon(
                  Icons.close,
                  color: Colors.red[800],
                ),
              )
            : const SizedBox();
      },
    );
  }
}
