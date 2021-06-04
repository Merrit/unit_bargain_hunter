import 'models.dart';

class Result {
  final Item cheapest;
  final List<Item>? tiedItems;

  const Result({
    required this.cheapest,
    this.tiedItems,
  });
}
