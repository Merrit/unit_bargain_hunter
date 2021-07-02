import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:unit_bargain_hunter/application/calculator/cubit/calculator_cubit.dart';
import 'package:unit_bargain_hunter/application/item/cubit/item_cubit.dart';
import 'package:unit_bargain_hunter/domain/calculator/models/models.dart';
import 'package:unit_bargain_hunter/domain/calculator/validators/text_input_formatter.dart';
import 'package:unit_bargain_hunter/presentation/calculator/widgets/compare_items_shortcut.dart';
import 'package:unit_bargain_hunter/presentation/styles.dart';

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

class _ItemContents extends StatefulWidget {
  @override
  __ItemContentsState createState() => __ItemContentsState();
}

class __ItemContentsState extends State<_ItemContents>
    with TickerProviderStateMixin {
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
    setState(() => _opacity = 1);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 800),
      opacity: _opacity,
      child: ScaleTransition(
        scale: _animation,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 190,
          ),
          child: Card(
            elevation: 2,
            child: Stack(
              children: [
                Positioned.fill(
                  child: BlocBuilder<ItemCubit, ItemState>(
                    builder: (context, state) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeIn,
                        decoration: BoxDecoration(
                          gradient: (state.isCheapest)
                              ? LinearGradient(
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
                          Text('Unit'),
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
            decoration: InputDecoration(
              labelText: 'Price',
            ),
            focusNode: _focusNode,
            controller: _controller,
            textAlign: TextAlign.center,
            inputFormatters: [BetterTextInputFormatter.doubleOnly],
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
            decoration: InputDecoration(
              labelText: 'Quantity',
            ),
            focusNode: _focusNode,
            controller: _controller,
            textAlign: TextAlign.center,
            inputFormatters: [BetterTextInputFormatter.doubleOnly],
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
              ? Material(
                  color: Colors.transparent,
                  type: MaterialType.circle,
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                    onPressed: () => calcCubit.removeItem(state.item.key),
                    icon: Icon(
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
