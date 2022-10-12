import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart';

import '../calculator_cubit/calculator_cubit.dart';
import '../models/models.dart';

class EditItemDialog extends StatefulWidget {
  final Item item;

  const EditItemDialog(
    this.item, {
    super.key,
  });

  @override
  State<EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  late Item item;

  final locationTextFieldController = TextEditingController();
  final detailsTextFieldController = TextEditingController();
  final priceTextFieldController = TextEditingController();
  final quantityTextFieldController = TextEditingController();

  final priceTextFieldFocusNode = FocusNode();
  final quantityTextFieldFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    item = widget.item;
    locationTextFieldController.text = item.location;
    detailsTextFieldController.text = item.details;
    priceTextFieldController.text = item.price.toStringAsFixed(2);
    quantityTextFieldController.text = item.quantity.toString();

    priceTextFieldFocusNode.addListener(() {
      if (priceTextFieldFocusNode.hasFocus) {
        priceTextFieldController.selectAll();
      }
    });

    quantityTextFieldFocusNode.addListener(() {
      if (quantityTextFieldFocusNode.hasFocus) {
        quantityTextFieldController.selectAll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            const SizedBox(width: double.maxFinite),
            Text(
              'Edit item',
              style: Theme.of(context).textTheme.headline5,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _saveItemChanges(context),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        ListTile(
          title: TextField(
            controller: locationTextFieldController,
            decoration: const InputDecoration(
              labelText: 'Location',
              prefixIcon: Icon(Icons.location_on),
            ),
          ),
        ),
        ListTile(
          title: TextField(
            controller: detailsTextFieldController,
            decoration: const InputDecoration(
              labelText: 'Details',
              prefixIcon: Icon(Icons.notes),
            ),
            keyboardType: TextInputType.multiline,
            maxLines: null,
          ),
        ),
        ListTile(
          title: TextField(
            controller: priceTextFieldController,
            decoration: const InputDecoration(
              labelText: 'Price',
              prefixIcon: Icon(Icons.attach_money),
            ),
            focusNode: priceTextFieldFocusNode,
          ),
        ),
        ListTile(
          title: TextField(
            controller: quantityTextFieldController,
            decoration: const InputDecoration(
              labelText: 'Quantity',
              prefixIcon: Icon(Icons.numbers),
            ),
            focusNode: quantityTextFieldFocusNode,
          ),
          trailing: DropdownButton<Unit>(
            value: item.unit,
            onChanged: (Unit? value) {
              setState(() => item = item.copyWith(unit: value));
            },
            items: item.unit.baseUnit.subTypes
                .map((value) => DropdownMenuItem<Unit>(
                      value: value,
                      child: Text('$value'),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  void _saveItemChanges(BuildContext context) {
    final navigator = Navigator.of(context);

    calcCubit.updateItem(
        item: item.copyWith(
      location: locationTextFieldController.text,
      details: detailsTextFieldController.text,
      price: double.tryParse(priceTextFieldController.text),
      quantity: double.tryParse(quantityTextFieldController.text),
    ));

    navigator.pop();
  }
}
