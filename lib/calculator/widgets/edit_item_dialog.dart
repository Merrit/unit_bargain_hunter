import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpers/helpers.dart';

import '../../l10n/helper.dart';
import '../../settings/settings.dart';
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

  late SettingsCubit settingsCubit;

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

    settingsCubit = context.read<SettingsCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, void Function()>{
        const SingleActivator(
          LogicalKeyboardKey.enter,
          control: true,
        ): () => _saveItemChanges(context),
        const SingleActivator(
          LogicalKeyboardKey.keyS,
          control: true,
        ): () => _saveItemChanges(context),
      },
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _saveItemChanges(context),
              child: Text(context.translations.save),
            ),
          ),
          Text(
            context.translations.editItem,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 30),
          ListTile(
            title: TextField(
              controller: locationTextFieldController,
              decoration: InputDecoration(
                labelText: context.translations.location,
                prefixIcon: const Icon(Icons.location_on),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          ListTile(
            title: TextField(
              controller: detailsTextFieldController,
              decoration: InputDecoration(
                labelText: context.translations.details,
                prefixIcon: const Icon(Icons.notes),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          ListTile(
            title: TextField(
              controller: priceTextFieldController,
              decoration: InputDecoration(
                labelText: context.translations.price,
                prefixIcon: const Icon(Icons.attach_money),
              ),
              focusNode: priceTextFieldFocusNode,
            ),
          ),
          SwitchListTile(
            title: Row(
              children: [
                Text(context.translations.taxIncluded),
                const SizedBox(width: 10),
                Tooltip(
                  message: context.translations.taxIncludedTooltip,
                  child: const Icon(Icons.info_outline),
                ),
              ],
            ),
            value: item.taxIncluded,
            onChanged: (value) {
              final taxRate = settingsCubit.state.taxRate;
              if (taxRate == 0.0) {
                // Prompt user to set tax rate.
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(context.translations.taxRateNotSet),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(context.translations.cancel),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed('/settings');
                        },
                        child: Text(context.translations.set),
                      ),
                    ],
                  ),
                );
                return;
              }
              setState(() => item = item.copyWith(taxIncluded: value));
            },
          ),
          ListTile(
            title: TextField(
              controller: quantityTextFieldController,
              decoration: InputDecoration(
                labelText: context.translations.quantity,
                prefixIcon: const Icon(Icons.numbers),
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
      ),
    );
  }

  void _saveItemChanges(BuildContext context) {
    final calcCubit = context.read<CalculatorCubit>();
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
