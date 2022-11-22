import 'package:flutter_test/flutter_test.dart';
import 'package:unit_bargain_hunter/calculator/models/models.dart';

void main() {
  test('Gram and kilogram are different', () {
    final gram = Gram();
    final kilogram = Kilogram();
    expect(gram == kilogram, false);
  });

  test('Gram and gram are the same', () {
    final gram1 = Gram();
    final gram2 = Gram();
    expect(gram1 == gram2, true);
  });
}
