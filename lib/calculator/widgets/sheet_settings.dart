import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../calculator_cubit/calculator_cubit.dart';
import '../calculator_page.dart';
import '../models/models.dart';

class SheetSettingsView extends StatefulWidget {
  const SheetSettingsView({super.key});

  @override
  State<SheetSettingsView> createState() => _SheetSettingsViewState();
}

class _SheetSettingsViewState extends State<SheetSettingsView> {
  final nameTextFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final sheet = calcCubit.state.activeSheet;
    if (sheet == null) return;
    nameTextFieldController.text = sheet.name;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        final sheet = state.activeSheet;
        if (sheet == null) return const SizedBox();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'List Settings',
                  style: Theme.of(context).textTheme.headline5,
                ),
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(height: 30),
                      ListTile(
                        title: TextField(
                          controller: nameTextFieldController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                          ),
                          onSubmitted: (value) {
                            calcCubit.updateActiveSheet(
                              state.activeSheet!.copyWith(
                                name: nameTextFieldController.text,
                              ),
                            );
                          },
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.done),
                          onPressed: () {
                            calcCubit.updateActiveSheet(
                              state.activeSheet!.copyWith(
                                name: nameTextFieldController.text,
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20.0,
                          horizontal: 50.0,
                        ),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(30),
                          ),
                          onPressed: () =>
                              _showConfirmRemovalDialog(context, sheet),
                          child: const Text(
                            'Delete List',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Confirm the user really wants to remove the sheet.
void _showConfirmRemovalDialog(BuildContext context, Sheet sheet) {
  Future.delayed(
    const Duration(seconds: 0),
    () => showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text('Remove sheet "${sheet.name}?"'),
          actions: [
            TextButton(
              onPressed: () {
                calcCubit.removeSheet(sheet);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  CalculatorPage.id,
                  (route) => false,
                );
              },
              child: const Text(
                'REMOVE',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    ),
  );
}