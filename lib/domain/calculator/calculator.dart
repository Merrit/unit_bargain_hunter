export 'models/models.dart';
export 'validators/validators.dart';

import 'models/models.dart';

class Calculator {
  const Calculator();

  Result compare({required List<Item> items}) {
    Item cheapest = items.first;
    items.forEach((item) {
      final previous = cheapest.price;
      final current = item.price;
      if (current < previous) cheapest = item;
    });
    return Result(cheapest: cheapest);
  }
}
