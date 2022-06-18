import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unit_bargain_hunter/calculator/calculator_cubit/calculator_cubit.dart';
import 'package:unit_bargain_hunter/calculator/models/sheet.dart';
import 'package:unit_bargain_hunter/calculator/widgets/sheet_name_widget.dart';
import 'package:unit_bargain_hunter/purchases/cubit/purchases_cubit.dart';
import 'package:unit_bargain_hunter/storage/storage_service.dart';

class MockPurchasesCubit extends MockCubit<PurchasesState>
    implements PurchasesCubit {}

class MockStorageService extends Mock implements StorageService {}

late MockPurchasesCubit _purchasesCubit;
late MockStorageService _storageService;
late CalculatorCubit _calcCubit;

final _defaultSheet = Sheet();

final _defaultState = CalculatorState(
  showSidePanel: true,
  sheets: [_defaultSheet],
  activeSheetId: 'activeSheetId',
  activeSheet: _defaultSheet,
  result: const [],
);

void main() {
  group('SheetNameWidget:', () {
    setUp(() {
      _purchasesCubit = MockPurchasesCubit();
      _storageService = MockStorageService();
      when(() => _storageService.saveValue(
          key: any(named: 'key'),
          value: any(named: 'value'),
          storageArea: any(named: 'storageArea'))).thenAnswer((_) async {});
      _calcCubit = CalculatorCubit(
        _purchasesCubit,
        _storageService,
        initialState: _defaultState,
      );
    });

    testWidgets('name can be edited', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<CalculatorCubit>.value(
          value: _calcCubit,
          child: const MaterialApp(
            home: Material(child: SheetNameWidget()),
          ),
        ),
      ));

      final nameFinder = find.text('Unnamed Sheet');
      expect(nameFinder, findsOneWidget);
      await tester.tap(nameFinder);
      await tester.pumpAndSettle();

      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);
      await tester.enterText(textFieldFinder, 'Oats');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final newNameFinder = find.text('Oats');
      expect(newNameFinder, findsOneWidget);
      expect(newNameFinder.evaluate().first.widget.runtimeType, Text);
    });
  });
}
