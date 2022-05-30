import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/helpers/helpers.dart';
import '../calculator_cubit/calculator_cubit.dart';

/// Displays the sheet's name, and allows the user to change it.
class SheetNameWidget extends StatefulWidget {
  const SheetNameWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<SheetNameWidget> createState() => _SheetNameWidgetState();
}

class _SheetNameWidgetState extends State<SheetNameWidget> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode(
    debugLabel: 'SheetNameWidget FocusNode',
  );

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  bool _showTextField = false;

  @override
  Widget build(BuildContext context) {
    focusNode.addListener(() {
      // When focus is lost, switch back to showing the Text widget.
      if (!focusNode.hasFocus) setState(() => _showTextField = false);
    });

    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        controller.text = state.activeSheet.name;

        void _updateSheet() {
          calcCubit.updateActiveSheet(
            state.activeSheet.copyWith(name: controller.text),
          );
          FocusManager.instance.primaryFocus?.unfocus();
        }

        Widget child;
        if (_showTextField) {
          child = TextField(
            focusNode: focusNode,
            controller: controller..selectAll(),
            autofocus: true,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _updateSheet(),
          );
        } else {
          child = Text(state.activeSheet.name);
        }

        return InkWell(
          onTap: () {
            focusNode.requestFocus();
            setState(() => _showTextField = true);
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: child,
          ),
        );
      },
    );
  }
}
