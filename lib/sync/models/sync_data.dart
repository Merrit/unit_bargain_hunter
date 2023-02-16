import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../calculator/models/models.dart';

/// Represents the data that has been synced.
class SyncData extends Equatable {
  /// The last time the data was synced.
  ///
  /// This is used to determine whether the local or cloud version of the [SyncData] is newer.
  ///
  /// If `null`, the data has never been synced.
  final DateTime? lastSynced;

  /// The list of [Sheet]s that have been synced.
  final List<Sheet> sheets;

  /// Creates a [SyncData] object.
  const SyncData({
    required this.lastSynced,
    required this.sheets,
  });

  @override
  String toString() => 'SyncData(lastSynced: $lastSynced, sheets: $sheets)';

  SyncData copyWith({
    DateTime? lastSynced,
    List<Sheet>? sheets,
  }) {
    return SyncData(
      lastSynced: lastSynced ?? this.lastSynced,
      sheets: sheets ?? this.sheets,
    );
  }

  /// Convert a [List<int>] to a [SyncData] object.
  static SyncData fromBytes(List<int> bytes) {
    return SyncData.fromJson(utf8.decode(bytes));
  }

  /// Convert a [SyncData] object to a [List<int>].
  List<int> toBytes() {
    return utf8.encode(toJson());
  }

  /// Convert a [Stream<List<int>>] to a [SyncData] object.

  @override
  List<Object?> get props => [lastSynced, sheets];

  Map<String, dynamic> toMap() {
    return {
      'lastSynced': lastSynced?.millisecondsSinceEpoch,
      'sheets': sheets.map((x) => x.toMap()).toList(),
    };
  }

  factory SyncData.fromMap(Map<String, dynamic> map) {
    return SyncData(
      lastSynced: map['lastSynced'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastSynced'])
          : null,
      sheets: List<Sheet>.from(map['sheets']?.map((x) => Sheet.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory SyncData.fromJson(String source) =>
      SyncData.fromMap(json.decode(source));
}
