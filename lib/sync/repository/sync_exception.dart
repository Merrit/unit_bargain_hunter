class SyncException implements Exception {
  final String message;

  SyncException(this.message);

  @override
  String toString() => 'SyncException: $message';
}
