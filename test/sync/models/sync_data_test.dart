import 'package:flutter_test/flutter_test.dart';
import 'package:unit_bargain_hunter/calculator/models/models.dart';
import 'package:unit_bargain_hunter/sync/sync.dart';

void main() {
  group('SyncData:', () {
    test('SyncData can be converted to and from JSON', () {
      final data = SyncData(
        lastSynced: DateTime(2021, 1, 1),
        sheets: [
          Sheet(
            index: 0,
            name: 'Example Sheet',
            items: [
              Item(
                price: 1.00,
                quantity: 1.00,
                unit: Unit.gram,
              ),
              Item(
                price: 2.00,
                quantity: 2.00,
                unit: Unit.gram,
              ),
            ],
          ),
          Sheet(
            index: 1,
            name: 'Example Sheet 2',
            items: [
              Item(
                price: 3.00,
                quantity: 3.00,
                unit: Unit.gram,
              ),
              Item(
                price: 4.00,
                quantity: 4.00,
                unit: Unit.gram,
              ),
            ],
          ),
        ],
      );

      final json = data.toJson();
      final convertedData = SyncData.fromJson(json);

      expect(data, convertedData);
    });
  });
}
