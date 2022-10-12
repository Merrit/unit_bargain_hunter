import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/widgets/widgets.dart';
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
        child: Stack(
          alignment: AlignmentDirectional.topEnd,
          children: const [
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
                    Text('\$ $price'),
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

        return BlocBuilder<CalculatorCubit, CalculatorState>(
          builder: (context, state) {
            return (item.costPerUnit.isEmpty || !state.resultExists)
                ? const SizedBox()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      ...item.costPerUnit.map((cost) {
                        String stringValue = cost.value.toStringAsFixed(3);
                        if (stringValue == '0.000') {
                          // Calculated value too small to show within 3 decimal points.
                          stringValue = '--.--';
                        }
                        if (stringValue.endsWith('0')) {
                          // Only show 2 decimal places when ending with a 0, for example:
                          // 77.50 instead of 77.500
                          final lastIndex = stringValue.length - 1;
                          stringValue = stringValue.substring(0, lastIndex);
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text('\$$stringValue per ${cost.unit}'),
                        );
                      }).toList(),
                    ],
                  );
          },
        );
      },
    );
  }
}
