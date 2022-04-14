import 'package:equatable/equatable.dart';

import 'models.dart';

class Cost extends Equatable {
  final Unit unit;

  /// The calculated cost per [Unit].
  final double value;

  const Cost({
    required this.unit,
    required this.value,
  });

  @override
  List<Object> get props => [unit, value];

  @override
  bool get stringify => true;
}
