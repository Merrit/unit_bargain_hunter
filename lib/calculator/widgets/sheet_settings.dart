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
  final subtitleTextFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final sheet = calcCubit.state.activeSheet;
    if (sheet == null) return;
    nameTextFieldController.text = sheet.name;
    subtitleTextFieldController.text = sheet.subtitle ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        final sheet = state.activeSheet;
        if (sheet == null) return const SizedBox();

        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(width: double.maxFinite),
                Text(
                  'List Settings',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);

                      await calcCubit.updateActiveSheet(
                        state.activeSheet!.copyWith(
                          name: nameTextFieldController.text,
                          subtitle: subtitleTextFieldController.text,
                        ),
                      );

                      navigator.pop();
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ListTile(
              title: TextField(
                controller: nameTextFieldController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
            ),
            ListTile(
              title: TextField(
                controller: subtitleTextFieldController,
                decoration: const InputDecoration(
                  labelText: 'Subtitle',
                ),
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
                onPressed: () => _showConfirmRemovalDialog(context, sheet),
                child: const Text(
                  'Delete List',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
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
