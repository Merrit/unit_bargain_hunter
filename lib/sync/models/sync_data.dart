import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../calculator/models/models.dart';

/// Represents the data that has been synced.
class SyncData extends Equatable {
  /// The last time the data was synced.
  final DateTime lastSynced;

  /// The list of [Sheet]s that have been synced.
  final List<Sheet> sheets;

  /// Sync file id.
  ///
  /// This is the unique ID of the remote sync file.
  final String? syncFileId;

  /// Creates a [SyncData] object.
  const SyncData({
    required this.lastSynced,
    required this.sheets,
    this.syncFileId,
  });

  @override
  String toString() =>
      'SyncData(lastSynced: $lastSynced, sheets: $sheets, syncFileId: $syncFileId)';

  SyncData copyWith({
    DateTime? lastSynced,
    List<Sheet>? sheets,
    String? syncFileId,
  }) {
    return SyncData(
      lastSynced: lastSynced ?? this.lastSynced,
      sheets: sheets ?? this.sheets,
      syncFileId: syncFileId ?? this.syncFileId,
    );
  }

  @override
  List<Object?> get props => [lastSynced, sheets, syncFileId];

  Map<String, dynamic> toMap() {
    return {
      'lastSynced': lastSynced.millisecondsSinceEpoch,
      'sheets': sheets.map((x) => x.toMap()).toList(),
      'syncFileId': syncFileId,
    };
  }

  factory SyncData.fromMap(Map<String, dynamic> map) {
    return SyncData(
      lastSynced: DateTime.fromMillisecondsSinceEpoch(map['lastSynced']),
      sheets: List<Sheet>.from(map['sheets']?.map((x) => Sheet.fromMap(x))),
      syncFileId: map['syncFileId'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SyncData.fromJson(String source) =>
      SyncData.fromMap(json.decode(source));
}
