import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/helpers/helpers.dart';
import '../../theme/styles.dart';
import '../calculator_cubit/calculator_cubit.dart';
import '../models/models.dart';
import '../validators/validators.dart';

/// A reference to the current item for each [ItemCard], via `Riverpod`.
///
/// Accessing this means not having to pass the [Item] to child widgets.
final _currentItem = Provider<Item>((ref) => throw UnimplementedError());

/// The widget representing each item.
class ItemCard extends StatelessWidget {
  final Item item;

  const ItemCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        _currentItem.overrideWithValue(item),
      ],
      child: Consumer(
        builder: (context, ref, child) {
          final item = ref.watch(_currentItem);

          final isCheapest = context
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

          return AnimatedContainer(
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
          );
        },
      ),
    );
  }
}

class _ItemContents extends StatelessWidget {
  const _ItemContents({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 12,
          right: 14,
          bottom: 14,
        ),
        // FocusTraversalGroup ensures that using `Tab` to
        // navigate with a keyboard moves in the correct direction.
        child: FocusTraversalGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ItemNameWidget(),
              Spacers.verticalXtraSmall,
              _NumericInputWidget('Price'),
              Spacers.verticalXtraSmall,
              _NumericInputWidget('Quantity'),
              Spacers.verticalXtraSmall,
              _UnitChooser(),
              Spacers.verticalSmall,
              _PerUnitCalculation(),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemNameWidget extends StatefulWidget {
  const ItemNameWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<ItemNameWidget> createState() => _ItemNameWidgetState();
}

class _ItemNameWidgetState extends State<ItemNameWidget> {
  final controller = TextEditingController();
  final nameFocusNode = FocusNode(debugLabel: 'ItemName node');
  final textFieldFocusNode = FocusNode(debugLabel: 'ItemName TextField node');
  bool nameHasFocus = false;

  @override
  void dispose() {
    controller.dispose();
    nameFocusNode.dispose();
    textFieldFocusNode.dispose();
    super.dispose();
  }

  void _updateItem(Item item) {
    calcCubit.updateItem(
      item: item.copyWith(name: controller.text),
    );
    nameFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final item = ref.watch(_currentItem);

        Widget child;
        if (nameFocusNode.hasFocus) {
          child = TextFormField(
            focusNode: textFieldFocusNode,
            controller: controller..selectAll(),
            autofocus: true,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            textCapitalization: TextCapitalization.words,
            onFieldSubmitted: (_) => _updateItem(item),
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              suffixIcon: (isHandset(context))
                  ? null
                  : IconButton(
                      onPressed: () => _updateItem(item),
                      padding: const EdgeInsets.all(4),
                      icon: const Icon(Icons.done, color: Colors.green),
                    ),
            ),
          );
        } else {
          child = Padding(
            padding: const EdgeInsets.all(14.0),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${item.name} '),
                  const WidgetSpan(
                    child: Icon(Icons.edit, size: 15, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return Focus(
          focusNode: nameFocusNode,
          onFocusChange: (focused) {
            setState(() => nameHasFocus = focused);

            if (focused) controller.text = item.name;

            if (!focused) FocusManager.instance.primaryFocus?.unfocus();
          },
          skipTraversal: true,
          descendantsAreTraversable: false,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Center(
                  child: InkWell(
                    onTap: () {
                      nameFocusNode.requestFocus();
                      textFieldFocusNode.requestFocus();
                    },
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Input box for the `Price` & `Quantity` fields.
class _NumericInputWidget extends StatelessWidget {
  /// Either `Price` or `Quantity`.
  final String itemProperty;

  _NumericInputWidget(
    this.itemProperty, {
    Key? key,
  }) : super(key: key);

  final _controller = TextEditingController();
  final _focusNode = FocusNode(debugLabel: '_NumericInputWidget node');

  /// Set the text on the [_controller].
  void _setText(Item item) {
    if (itemProperty == 'Price') {
      _controller.text = item.price.toStringAsFixed(2);
    } else {
      _controller.text = item.quantity.toStringAsFixed(2);
    }
  }

  void _updateItem(Item item) {
    calcCubit.updateItem(
      item: item,
      price: (itemProperty == 'Price') ? _controller.text : null,
      quantity: (itemProperty == 'Quantity') ? _controller.text : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final item = ref.watch(_currentItem);

        _setText(item);

        return Focus(
          skipTraversal: true,
          debugLabel: '_NumericInputWidget focus controller node',
          onFocusChange: (focused) {
            if (focused) {
              _controller.selectAll();
              // If the user is selecting a field *after* having done
              // a calculation we want to clear the results so that we
              // are no longer showing a winner until a new calculation.
              calcCubit.resetResult();
            } else {
              _updateItem(item);
            }
          },
          child: TextField(
            decoration: InputDecoration(labelText: itemProperty),
            focusNode: _focusNode,
            controller: _controller,
            textAlign: TextAlign.center,
            inputFormatters: [BetterTextInputFormatter.doubleOnly],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            onSubmitted: (_) {
              _updateItem(item);
              calcCubit.compare();
            },
          ),
        );
      },
    );
  }
}

/// Allow choosing between eg `grams`, `millilitres`, etc.
class _UnitChooser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final item = ref.watch(_currentItem);

        return BlocBuilder<CalculatorCubit, CalculatorState>(
          builder: (context, state) {
            if (state.activeSheet.compareBy is ItemUnit) {
              return const SizedBox();
            }

            return Column(
              children: [
                const Text('Unit'),
                DropdownButton<Unit>(
                  value: item.unit,
                  onChanged: (value) => calcCubit.updateItem(
                    item: item,
                    unit: value,
                  ),
                  items: state.activeSheet.compareBy.subTypes
                      .map((value) => DropdownMenuItem<Unit>(
                            value: value,
                            child: Text('$value'),
                          ))
                      .toList(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Only shown when a comparison has been completed, lists the
/// item's cost per gram, millilitre, etc.
class _PerUnitCalculation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final item = ref.watch(_currentItem);
        return BlocBuilder<CalculatorCubit, CalculatorState>(
          builder: (context, state) {
            return (item.costPerUnit.isEmpty || !state.resultExists)
                ? const SizedBox()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: item.costPerUnit.map((cost) {
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
                  );
          },
        );
      },
    );
  }
}

/// Only shown when there are more than 2 item cards.
// class _CloseButton extends StatelessWidget {
class _CloseButton extends ConsumerWidget {
  const _CloseButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(_currentItem);

    final shouldShowCloseButton =
        context.watch<CalculatorCubit>().state.activeSheet.items.length > 2;

    return ExcludeFocusTraversal(
      child: (shouldShowCloseButton)
          ? Material(
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
            )
          : const SizedBox(),
    );
  }
}
