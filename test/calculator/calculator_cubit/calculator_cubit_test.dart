import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unit_bargain_hunter/calculator/calculator_cubit/calculator_cubit.dart';
import 'package:unit_bargain_hunter/calculator/models/models.dart';
import 'package:unit_bargain_hunter/purchases/cubit/purchases_cubit.dart';
import 'package:unit_bargain_hunter/storage/storage_service.dart';

class MockPurchasesCubit extends Mock implements PurchasesCubit {}

class MockStorageService extends Mock implements StorageService {}

late MockPurchasesCubit _purchasesCubit;
late MockStorageService storageService;
late CalculatorCubit cubit;

Future<void> main() async {
  group('CalculatorCubit: ', () {
    setUp(() async {
      _purchasesCubit = MockPurchasesCubit();
      storageService = MockStorageService();
      when(() => storageService.getValue('showSidePanel'))
          .thenAnswer((_) async => true);
      when(() => storageService.getStorageAreaValues('sheets'))
          .thenAnswer((_) async => []);
      when(() => storageService.saveValue(
            key: any(named: 'key'),
            value: any(named: 'value'),
            storageArea: any(named: 'storageArea'),
          )).thenAnswer((_) async => Future.value());
      when(() => storageService.deleteValue(
            any(),
            storageArea: any(named: 'storageArea'),
          )).thenAnswer((_) async => Future.value());
      cubit = await CalculatorCubit.initialize(_purchasesCubit, storageService);
    });

    test('initializes with 2 items', () {
      expect(cubit.state.activeSheet?.items.length, 2);
    });

    test('items have unique uuids', () {
      final uuidA = cubit.state.activeSheet?.items[0].uuid;
      final uuidB = cubit.state.activeSheet?.items[1].uuid;
      expect(uuidA != uuidB, true);
    });

    test('added item is in correct order', () {
      final initialItems =
          cubit.state.activeSheet?.items.map((e) => e.uuid).toList();

      cubit.addItem();

      expect(cubit.state.activeSheet?.items[0].uuid, initialItems![0]);
      expect(cubit.state.activeSheet?.items[1].uuid, initialItems[1]);

      final updatedItems =
          cubit.state.activeSheet?.items.map((e) => e.uuid).toList();
      final newItem = updatedItems![2];

      expect(initialItems.contains(newItem), false);
      expect(updatedItems.contains(newItem), true);
    });

    test('deleting sheet works', () async {
      final initalSheets = cubit.state.sheets;
      expect(initalSheets.isNotEmpty, true);
      final initialSheetUuids = initalSheets.map((e) => e.uuid).toList();

      await cubit.addSheet();
      expect(cubit.state.sheets.length == (initalSheets.length + 1), true);

      final newSheet = cubit.state.sheets
          .where((element) => !initialSheetUuids.contains(element.uuid))
          .first;

      await cubit.removeSheet(newSheet);
      expect(cubit.state.sheets.contains(newSheet), false);
    });

    test('sheets without index return correctly', () {
      List<Sheet> sheets = [
        Sheet(name: 'Oats'),
        Sheet(name: 'Rice'),
        Sheet(name: 'Sugar'),
      ];

      /// Sheets initally all have index `-1` since it was not specified.
      expect(sheets.map((e) => e.index).toSet().toList(), [-1]);

      /// Sheets have been given a random index order.
      sheets = CalculatorCubit.putSheetsInOrder(sheets);
      expect(sheets.map((e) => e.index).toSet().toList(), [0, 1, 2]);
    });

    test('sheets where some are missing index returns correctly', () {
      List<Sheet> sheets = [
        Sheet(name: 'Oats', index: 0),
        Sheet(name: 'Rice'),
        Sheet(name: 'Sugar', index: 1),
      ];

      sheets = CalculatorCubit.putSheetsInOrder(sheets);
      expect(sheets[0].name, 'Oats');
      expect(sheets[0].index, 0);
      expect(sheets[1].name, 'Sugar');
      expect(sheets[1].index, 1);
      expect(sheets[2].name, 'Rice');
      expect(sheets[2].index, 2);
    });

    test('sheets with index returns correctly', () {
      List<Sheet> sheets = [
        Sheet(name: 'Oats', index: 0),
        Sheet(name: 'Rice', index: 1),
        Sheet(name: 'Sugar', index: 2),
      ];

      sheets = CalculatorCubit.putSheetsInOrder(sheets);
      expect(sheets[0].name, 'Oats');
      expect(sheets[0].index, 0);
      expect(sheets[1].name, 'Rice');
      expect(sheets[1].index, 1);
      expect(sheets[2].name, 'Sugar');
      expect(sheets[2].index, 2);
    });

    test('sheets with incorrect index returns correctly', () {
      List<Sheet> sheets = [
        Sheet(name: 'Oats', index: 0),
        Sheet(name: 'Sugar', index: 2),
      ];

      sheets = CalculatorCubit.putSheetsInOrder(sheets);
      expect(sheets[0].name, 'Oats');
      expect(sheets[0].index, 0);
      expect(sheets[1].name, 'Sugar');
      expect(sheets[1].index, 1);
    });
  });
}
