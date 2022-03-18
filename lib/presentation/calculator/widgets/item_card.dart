import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:unit_bargain_hunter/application/calculator/cubit/calculator_cubit.dart';
import 'package:unit_bargain_hunter/application/item/cubit/item_cubit.dart';
import 'package:unit_bargain_hunter/domain/calculator/models/models.dart';
import 'package:unit_bargain_hunter/domain/calculator/validators/text_input_formatter.dart';

import '../../styles.dart';
import '../calculator.dart';

/// The widget representing each item.
class ItemCard extends StatelessWidget {
  final int index;

  const ItemCard({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ItemCubit(index),
      // Stack is used so the close button doesn't push down the contents.
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

class _ItemContents extends StatefulWidget {
  @override
  __ItemContentsState createState() => __ItemContentsState();
}

// Contents uses a StatefulWidget in order to get the
// Ticker & setState for the animations.
class __ItemContentsState extends State<_ItemContents>
    with TickerProviderStateMixin {
  // Start with no opacity.
  double _opacity = 0;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 800),
    vsync: this,
  )..forward();

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCirc,
  );

  @override
  void initState() {
    super.initState();
    // Opacity fades in when widget is created.
    setState(() => _opacity = 1);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 800),
      opacity: _opacity,
      child: ScaleTransition(
        scale: _animation,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            // Prevent the card from taking all available width.
            maxWidth: 190,
          ),
          child: Card(
            elevation: 2,
            // Stack is used to layer the 'winner' color underneath
            // the actual widgets that make up the card.
            child: Stack(
              children: [
                Positioned.fill(
                  child: BlocBuilder<ItemCubit, ItemState>(
                    builder: (context, state) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeIn,
                        decoration: BoxDecoration(
                          gradient: (state.isCheapest)
                              ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.greenAccent,
                                    Colors.lightBlue,
                                  ],
                                )
                              : null,
                          borderRadius: BorderRadii.gentlyRounded,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 14,
                  ),
                  // FocusTraversalGroup ensures that using `Tab` to
                  // navigate with a keyboard moves in the correct direction.
                  child: FocusTraversalGroup(
                    child: Focus(
                      skipTraversal: true,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              'Item ${context.read<ItemCubit>().state.index + 1}'),
                          Spacers.verticalSmall,
                          _PriceWidget(),
                          Spacers.verticalXtraSmall,
                          _QuantityWidget(),
                          Spacers.verticalXtraSmall,
                          const Text('Unit'),
                          _UnitChooser(),
                          Spacers.verticalSmall,
                          _PerUnitCalculation(),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PriceWidget extends StatelessWidget {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    bool isFocused = false;
    return BlocBuilder<ItemCubit, ItemState>(
      buildWhen: (previous, current) => !isFocused || current.resultExists,
      builder: (context, state) {
        _controller.text = state.priceAsString;

        // Listen to the FocusNode & update [isFocused],
        // this ensures the widget doesn't rebuild when the user is
        // still actually editing it.
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          _focusNode.addListener(() {
            if (_focusNode.hasFocus) {
              isFocused = true;
              _controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: _controller.text.length,
              );
            } else {
              isFocused = false;
            }
          });
        });

        return CompareItemsShortcut(
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Price',
            ),
            focusNode: _focusNode,
            controller: _controller,
            textAlign: TextAlign.center,
            inputFormatters: [BetterTextInputFormatter.doubleOnly],
            keyboardType: const TextInputType.numberWithOptions(),
            textInputAction: TextInputAction.next,
            onChanged: (value) {
              calcCubit.updateItem(
                key: state.item.key,
                price: _controller.text,
              );
            },
          ),
        );
      },
    );
  }
}

class _QuantityWidget extends StatelessWidget {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    bool isFocused = false;

    return BlocBuilder<ItemCubit, ItemState>(
      buildWhen: (previous, current) => !isFocused || current.resultExists,
      builder: (context, state) {
        _controller.text = state.quantityAsString;

        // Listen to the FocusNode & update [isFocused],
        // this ensures the widget doesn't rebuild when the user is
        // still actually editing it.
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          _focusNode.addListener(() {
            if (_focusNode.hasFocus) {
              isFocused = true;
              _controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: _controller.text.length,
              );
            } else {
              isFocused = false;
            }
          });
        });

        return CompareItemsShortcut(
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Quantity',
            ),
            focusNode: _focusNode,
            controller: _controller,
            textAlign: TextAlign.center,
            inputFormatters: [BetterTextInputFormatter.doubleOnly],
            keyboardType: const TextInputType.numberWithOptions(),
            textInputAction: TextInputAction.next,
            onChanged: (value) {
              calcCubit.updateItem(
                key: state.item.key,
                quantity: _controller.text,
              );
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

/// Only shown when a comparison has been completed, lists the
/// item's cost per gram, millilitre, etc.
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

/// Only shown when there are more than 2 item cards.
class _CloseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemCubit, ItemState>(
      builder: (context, state) {
        return FocusTraversalGroup(
          descendantsAreFocusable: false,
          child: (state.shouldShowCloseButton)
              ? Material(
                  color: Colors.transparent,
                  type: MaterialType.circle,
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                    onPressed: () => calcCubit.removeItem(state.item.key),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white38,
                    ),
                  ),
                )
              : const SizedBox(),
        );
      },
    );
  }
}
