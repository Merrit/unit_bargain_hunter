import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/widgets/widgets.dart';
import '../../settings/settings.dart';
import '../calculator_cubit/calculator_cubit.dart';
import '../models/models.dart';
import 'edit_item_dialog.dart';

/// A reference to the current item for each [ItemCard], via `Riverpod`.
///
/// Accessing this means not having to pass the [Item] to child widgets.
final _currentItem = Provider<Item>((ref) => throw UnimplementedError());

class ItemCard extends StatelessWidget {
  final Item item;

  const ItemCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCheapest = context
        .watch<CalculatorCubit>()
        .state
        .result
        .map((e) => e.uuid)
        .toList()
        .contains(item.uuid);

    final BoxDecoration itemBorder;
    if (isCheapest) {
      itemBorder = const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.lightBlueAccent,
            blurRadius: 6.0,
          ),
        ],
      );
    } else {
      itemBorder = const BoxDecoration();
    }

    return ProviderScope(
      overrides: [
        _currentItem.overrideWithValue(item),
      ],
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 190,
        decoration: itemBorder,
        // Stack is used so the close button doesn't push down the contents.
        child: const Stack(
          alignment: AlignmentDirectional.topEnd,
          children: [
            _ItemContents(),
            _CloseButton(),
          ],
        ),
      ),
    );
  }
}

class _ItemContents extends StatelessWidget {
  const _ItemContents({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final Item item = ref.watch(_currentItem);
        final price = item.price.toStringAsFixed(2);
        final quantity = item.quantity.toString();

        final priceWidget = Row(
          children: [
            Text('\$ $price'),
            const SizedBox(width: 6),
            if (!item.taxIncluded)
              Text(
                // ignore: prefer_interpolation_to_compose_strings
                '+' + AppLocalizations.of(context)!.tax.toLowerCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.greenAccent,
                    ),
              ),
          ],
        );

        return SizedBox(
          width: 200,
          child: Card(
            child: InkWell(
              onTap: () => showModal(context, EditItemDialog(item)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Text(item.location)),
                    Opacity(
                      opacity: 0.8,
                      child: Center(child: Text(item.details)),
                    ),
                    const SizedBox(height: 10),
                    priceWidget,
                    Text('$quantity ${item.unit}s'),
                    const _UnitCalculations(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Only shown when there are more than 2 item cards.
class _CloseButton extends ConsumerWidget {
  const _CloseButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calcCubit = context.read<CalculatorCubit>();
    final item = ref.watch(_currentItem);

    final shouldShowCloseButton =
        context.watch<CalculatorCubit>().state.activeSheet!.items.length > 2;

    return ExcludeFocusTraversal(
      child: (shouldShowCloseButton)
          ? Padding(
              padding: const EdgeInsets.all(4.0),
              child: Material(
                color: Colors.transparent,
                type: MaterialType.circle,
                clipBehavior: Clip.antiAlias,
                child: IconButton(
                  onPressed: () => calcCubit.removeItem(item.uuid),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white38,
                  ),
                ),
              ),
            )
          : const SizedBox(),
    );
  }
}

/// Only shown when a comparison has been completed.
///
/// Lists the item's cost per gram, millilitre, etc.
class _UnitCalculations extends StatelessWidget {
  const _UnitCalculations({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final Item item = ref.watch(_currentItem);
        final settingsCubit = context.read<SettingsCubit>();
        final double taxRate = 1 + (settingsCubit.state.taxRate / 100);

        return BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            return BlocBuilder<CalculatorCubit, CalculatorState>(
              builder: (context, calcState) {
                final List<Cost> costsPerUnit = [...item.costPerUnit];

                costsPerUnit.removeWhere(
                    (cost) => !settingsState.enabledUnits.contains(cost.unit));

                if (costsPerUnit.isEmpty || !calcState.resultExists) {
                  return const SizedBox();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const _CostPerHundredWidget(),
                    ...costsPerUnit.map((cost) {
                      final double value =
                          _valueWithTax(item.taxIncluded, cost.value, taxRate);

                      final valueString = _valueAsString(value);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('\$$valueString per ${cost.unit}'),
                      );
                    }).toList(),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

/// If the comparison type is weight or volume, show the cost per 100 grams or
/// millilitres.
class _CostPerHundredWidget extends StatelessWidget {
  const _CostPerHundredWidget();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        if (settingsState.showCostPerHundred == false) {
          return const SizedBox();
        }

        return Consumer(
          builder: (context, ref, child) {
            final Item item = ref.watch(_currentItem);
            final double taxRate = 1 + (settingsState.taxRate / 100);

            return BlocBuilder<CalculatorCubit, CalculatorState>(
              builder: (context, calcCubit) {
                final comparisonType = calcCubit.activeSheet!.compareBy;

                if (comparisonType is Weight || comparisonType is Volume) {
                  final costPerHundredValue = item.costPerUnit.firstWhere(
                    (cost) => cost.unit == comparisonType.baseUnit,
                    orElse: () => Cost(
                      unit: comparisonType.baseUnit,
                      value: 0,
                    ),
                  );

                  final value = _valueWithTax(
                    item.taxIncluded,
                    costPerHundredValue.value * 100,
                    taxRate,
                  );

                  // Round to 2 decimal places.
                  final roundedValue = (value * 100).round() / 100;
                  final String valueString = _valueAsString(roundedValue);

                  return Text(
                    '\$$valueString per 100 ${comparisonType.baseUnit}s',
                  );
                }

                return const SizedBox();
              },
            );
          },
        );
      },
    );
  }
}

double _valueWithTax(bool taxIncluded, double value, double taxRate) {
  if (taxIncluded) {
    return value;
  } else {
    return value * taxRate;
  }
}

String _valueAsString(double value) {
  String valueString = value.toStringAsFixed(3);

  if (valueString == '0.000') {
    // Calculated value too small to show within 3 decimal points.
    valueString = '--.--';
  }

  if (valueString.endsWith('0')) {
    // Only show 2 decimal places when ending with a 0, for example:
    // 77.50 instead of 77.500
    final lastIndex = valueString.length - 1;
    valueString = valueString.substring(0, lastIndex);
  }

  return valueString;
}
