import 'package:googleapis/drive/v3.dart';
import 'package:googleapis_auth/auth_io.dart';

import 'src/src.dart';

/// Abstract class for sync repository.
///
/// Implemented by concrete sync repositories to provide a unified interface
/// for syncing data between the app and a cloud service.
abstract class SyncRepository {
  /// Singleton instance of the [SyncRepository].
  ///
  /// Will be null if the [SyncRepository] has not been initialized.
  static SyncRepository? instance;

  static Future<SyncRepository> initialize(
    AuthClient authClient,
  ) async {
    instance = GoogleDrive(DriveApi(authClient));
    return instance!;
  }

  /// Download a file from the cloud with the given [fileName].
  ///
  /// The download is returned as bytes.
  ///
  /// Returns null if the file does not exist.
  ///
  /// Throws a [SyncException] if the download failed.
  Future<List<int>?> download({
    required String fileName,
  });

  /// Upload a file to the cloud.
  ///
  /// The upload is performed from a Stream of bytes.
  ///
  /// Returns true if the upload was successful.
  /// Returns false if the upload failed.
  Future<bool> upload({
    required String fileName,
    required List<int> data,
  });
}
