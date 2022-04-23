import 'package:flutter_test/flutter_test.dart';
import 'package:unit_bargain_hunter/calculator/calculator_cubit/calculator_cubit.dart';

CalculatorCubit cubit = CalculatorCubit();
CalculatorState state() => cubit.state;

void main() {
  group('CalculatorCubit: ', () {
    setUp(() {
      cubit = CalculatorCubit();
    });

    test('initializes with 2 items', () {
      expect(state().items.length, 2);
    });

    test('items have unique uuids', () {
      final uuidA = state().items[0].uuid;
      final uuidB = state().items[1].uuid;
      expect(uuidA != uuidB, true);
    });

    test('added item is in correct order', () {
      final initialItems = state().items.map((e) => e.uuid).toList();

      cubit.addItem();

      expect(state().items[0].uuid, initialItems[0]);
      expect(state().items[1].uuid, initialItems[1]);

      final updatedItems = state().items.map((e) => e.uuid).toList();
      final newItem = updatedItems[2];

      expect(initialItems.contains(newItem), false);
      expect(updatedItems.contains(newItem), true);
    });
  });
}
