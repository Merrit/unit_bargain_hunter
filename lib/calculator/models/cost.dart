import 'dart:convert';

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

  Map<String, dynamic> toMap() {
    return {
      'unit': unit.toString(),
      'value': value,
    };
  }

  factory Cost.fromMap(Map<String, dynamic> map) {
    return Cost(
      unit: Unit.fromString(map['unit']),
      value: map['value']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Cost.fromJson(String source) => Cost.fromMap(json.decode(source));
}
