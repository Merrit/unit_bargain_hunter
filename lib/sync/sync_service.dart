import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/drive/v3.dart';

import '../calculator/models/models.dart';
import 'src/src.dart';

/// Abstract class for sync service
///
/// This class is used to sync data between the app and a cloud service.
abstract class SyncService {
  static Future<SyncService> initialize(
    AuthClient authClient,
  ) async {
    return GoogleDriveSyncService(DriveApi(authClient));
  }

  /// Takes a list of [Sheet]s and syncs them to the cloud.
  ///
  /// Returns a list of [Sheet]s that were synced.
  /// Returns null if the sync failed.
  Future<List<Sheet>?> syncSheets(List<Sheet> sheets);
}
