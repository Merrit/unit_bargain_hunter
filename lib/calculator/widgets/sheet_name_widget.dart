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
  final FocusNode focusNode = FocusNode(debugLabel: 'SheetNameWidget node');
  final FocusNode textFieldFocusNode = FocusNode(
    debugLabel: 'SheetNameWidget TextField node',
  );

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      onFocusChange: (focused) => calcCubit.updateEditingSheetName(focused),
      child: Center(
        child: Container(
          width: 250,
          padding: const EdgeInsets.only(top: 10),
          child: BlocBuilder<CalculatorCubit, CalculatorState>(
            builder: (context, state) {
              controller.text = state.activeSheet.name;

              void _updateSheet() {
                calcCubit.updateActiveSheet(
                  state.activeSheet.copyWith(name: controller.text),
                );
                focusNode.unfocus();
              }

              Widget child;
              if (focusNode.hasFocus) {
                child = TextField(
                  focusNode: textFieldFocusNode,
                  controller: controller..selectAll(),
                  autofocus: true,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  onSubmitted: (_) => _updateSheet(),
                );
              } else {
                child = Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(state.activeSheet.name),
                ));
              }

              return InkWell(
                onTap: () {
                  focusNode.requestFocus();
                  textFieldFocusNode.requestFocus();
                },
                child: child,
              );
            },
          ),
        ),
      ),
    );
  }
}
