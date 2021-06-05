import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverbloc/riverbloc.dart';

import 'package:unit_bargain_hunter/application/calculator/cubit/calculator_cubit.dart';
import 'package:unit_bargain_hunter/application/providers.dart';
import 'package:unit_bargain_hunter/domain/calculator/models/models.dart';

late BlocProvider<CalculatorCubit, CalculatorState> _calcProvider;

late Provider<Item> _itemProvider;
late Provider<int> _indexProvider;
// late Provider<TextEditingController> _priceControllerProvider;
// late Provider<TextEditingController> _quantityControllerProvider;

class ItemCard extends StatelessWidget {
  // final Item item;
  final int index;

  const ItemCard({
    Key? key,
    // required this.item,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('ItemCard building');
    _calcProvider = BlocProvider<CalculatorCubit, CalculatorState>(
      (ref) => calcCubit,
    );
    _itemProvider = Provider<Item>(
      (ref) => ref.watch(_calcProvider).items[index],
    );
    _indexProvider = Provider<int>((ref) => index);
    // _priceControllerProvider = Provider<TextEditingController>((ref) {
    //   return TextEditingController(
    //     text: context.read(_itemProvider).price.toStringAsFixed(2),
    //   );
    // });
    // _quantityControllerProvider = Provider<TextEditingController>((ref) {
    //   return TextEditingController(
    //     text: context.read(_itemProvider).quantity.toStringAsFixed(2),
    //   );
    // });
    // _priceControllerProvider = Provider<TextEditingController>((ref) {
    //   return TextEditingController(text: item.price.toStringAsFixed(2));
    // });
    // _quantityControllerProvider = Provider<TextEditingController>((ref) {
    //   return TextEditingController(text: item.quantity.toStringAsFixed(2));
    // });

    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: [
        _ItemContents(),
        _CloseButton(),
      ],
    );
  }
}

class _ItemContents extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    print('_ItemContents building');
    // final item = watch(_itemProvider);
    // final index = watch(_indexProvider);
    // final priceController = context.read(_priceControllerProvider);
    // final quantityController = context.read(_quantityControllerProvider);
    // final priceController = watch(_priceControllerProvider);
    // final quantityController = watch(_quantityControllerProvider);
    // priceController.text = item.price.toStringAsFixed(2);
    // quantityController.text = item.quantity.toStringAsFixed(2);

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
              // onFocusChange: (focused) {
              //   if (!focused) {
              //     calcCubit.updateItem(
              //       key: item.key,
              //       index: index,
              //       price: priceController.text,
              //       quantity: quantityController.text,
              //     );
              //   }
              // },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Item ${watch(_indexProvider) + 1}'),
                  SizedBox(height: 10),

                  _PriceWidget(),

                  const SizedBox(height: 20),

                  _QuantityWidget(),

                  const SizedBox(height: 15),
                  Text('Unit'),
                  _UnitChooser(),
                  _PerUnitCalculation(),
                  // Text(
                  //   (context.watch<CalculatorCubit>().state.result != null)
                  //       ? '\$${itemState.item.costPerUnit?.costPer} per ${itemState.item.unit.baseUnit}'
                  //       : '',
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PriceWidget extends ConsumerWidget {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    print('_PriceWidget building');
    _controller.text = context.read(_itemProvider).price.toStringAsFixed(2);
    final item = context.read(_itemProvider);
    // final item = watch(_itemProvider);
    // final priceController = context.read(_priceControllerProvider);
    // final priceController = watch(_priceControllerProvider);

    return Focus(
      skipTraversal: true,
      // autofocus: true,
      // autofocus: (FocusScope.of(context).nearestScope.hasFocus) ? true : false,
      onFocusChange: (focused) {
        if (focused) {
          print(_controller.selection);
          _controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset:
                context.read(_itemProvider).price.toStringAsFixed(2).length,
          );
        } else {
          print(
            'Unfocused, updating item:\n'
            'item:\n'
            '$item \n'
            '_controller.text: ${_controller.text}\n',
          );
          calcCubit.updateItem(
            key: item.key,
            index: context.read(_indexProvider),
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
  }
}

class _QuantityWidget extends ConsumerWidget {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    _controller.text = context.read(_itemProvider).quantity.toStringAsFixed(2);
    final item = context.read(_itemProvider);

    return Focus(
      skipTraversal: true,
      onFocusChange: (focused) {
        if (focused) {
          _controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset:
                context.read(_itemProvider).quantity.toStringAsFixed(2).length,
          );
        } else {
          calcCubit.updateItem(
            key: item.key,
            index: context.read(_indexProvider),
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
  }
}

class _UnitChooser extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final item = watch(_itemProvider);

    return DropdownButton<Unit>(
      value: item.unit,
      onChanged: (value) => calcCubit.updateItem(
        key: item.key,
        index: watch(_indexProvider),
        unit: value,
      ),
      items: watch(_calcProvider)
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

class _PerUnitCalculation extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final item = watch(_itemProvider);
    final calcState = watch(_calcProvider);
    final resultExists = calcState.result != null;
    if (resultExists) {
      final costPer = item.costPerUnit!.costPer.toStringAsFixed(3);
      final baseUnit = item.unit.baseUnit;
      return Text('\$$costPer per $baseUnit');
    } else {
      return Container();
    }
  }
}

class _CloseButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final itemKey = watch(_itemProvider).key;
    final calcState = watch(_calcProvider);
    final showCloseButton = calcState.items.length >= 3;
    return FocusTraversalGroup(
      descendantsAreFocusable: false,
      child: (showCloseButton)
          ? IconButton(
              onPressed: () => calcCubit.removeItem(itemKey),
              icon: Icon(
                Icons.close,
                color: Colors.red[800],
              ),
            )
          : const SizedBox(),
    );
  }
}
