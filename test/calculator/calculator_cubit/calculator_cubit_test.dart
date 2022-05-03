import 'package:flutter_test/flutter_test.dart';
import 'package:unit_bargain_hunter/calculator/calculator_cubit/calculator_cubit.dart';
import 'package:unit_bargain_hunter/storage/storage_service.dart';

late StorageService storageService;
late CalculatorCubit cubit;
CalculatorState state() => cubit.state;

Future<void> main() async {
  setUp(() async {
    storageService = await StorageService.initialize();
  });

  group('CalculatorCubit: ', () {
    setUp(() async {
      cubit = await CalculatorCubit.initialize(storageService);
    });

    test('initializes with 2 items', () {
      expect(state().activeSheet.items.length, 2);
    });

    test('items have unique uuids', () {
      final uuidA = state().activeSheet.items[0].uuid;
      final uuidB = state().activeSheet.items[1].uuid;
      expect(uuidA != uuidB, true);
    });

    test('added item is in correct order', () {
      final initialItems =
          state().activeSheet.items.map((e) => e.uuid).toList();

      cubit.addItem();

      expect(state().activeSheet.items[0].uuid, initialItems[0]);
      expect(state().activeSheet.items[1].uuid, initialItems[1]);

      final updatedItems =
          state().activeSheet.items.map((e) => e.uuid).toList();
      final newItem = updatedItems[2];

      expect(initialItems.contains(newItem), false);
      expect(updatedItems.contains(newItem), true);
    });

    test('deleting sheet works', () async {
      final initalSheets = state().sheets;
      expect(initalSheets.isNotEmpty, true);
      final initialSheetUuids = initalSheets.map((e) => e.uuid).toList();

      await cubit.addSheet();
      expect(state().sheets.length == (initalSheets.length + 1), true);

      final newSheet = state()
          .sheets
          .where((element) => !initialSheetUuids.contains(element.uuid))
          .first;

      await cubit.removeSheet(newSheet);
      expect(state().sheets.contains(newSheet), false);
    });
  });
}
