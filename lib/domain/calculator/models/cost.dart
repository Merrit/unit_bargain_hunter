import 'package:equatable/equatable.dart';

import 'models.dart';

class Cost extends Equatable {
  final Unit unit;
  final double costPer;

  const Cost({
    required this.unit,
    required this.costPer,
  });

  @override
  List<Object> get props => [unit, costPer];

  @override
  bool get stringify => true;
}
