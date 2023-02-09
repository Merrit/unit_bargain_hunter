import 'dart:io' as io;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart';

import '../../calculator/models/models.dart';
import '../../logs/logs.dart';
import '../../storage/storage_service.dart';
import '../sync.dart';

/// Name of the sync data file.
const kSyncDataFileName = 'unit_bargain_hunter_sync_data.json';

/// Google Drive sync service.
class GoogleDriveSyncService implements SyncService {
  final DriveApi _driveApi;

  GoogleDriveSyncService(this._driveApi);

  @override
  Future<List<Sheet>?> syncSheets(List<Sheet> sheets) async {
    // Check if the sync data file exists.
    final remoteFileExists = await remoteSyncFileExists();

    // If the file does not exist, create it.
    if (!remoteFileExists) {
      await createFile();
    }

    // Download the sync data file.
    final remoteData = await download();

    // Check which data is newer.
    final lastSynced = await this.lastSynced();

    // If the local data is newer, upload it.
    if (lastSynced == null || lastSynced.isAfter(remoteData.lastSynced)) {
      final syncedData = await upload(SyncData(
        lastSynced: DateTime.now(),
        sheets: sheets,
      ));

      if (syncedData == null) {
        return null;
      }

      // Save when the local data was last synced.
      await saveLastSynced(syncedData.lastSynced);

      return syncedData.sheets;
    }

    // If the remote data is newer, return it.
    if (lastSynced.isBefore(remoteData.lastSynced)) {
      // Save when the local data was last synced.
      await saveLastSynced(remoteData.lastSynced);

      return remoteData.sheets;
    }

    // If the data is the same, return the local data.
    return sheets;
  }

  /// Check when local data was last synced.
  @visibleForTesting
  Future<DateTime?> lastSynced() async {
    String? savedSyncTime = await StorageService.instance!.getValue(
      'lastSynced',
    );

    final lastSynced = (savedSyncTime != null) //
        ? DateTime.tryParse(savedSyncTime)
        : null;

    return lastSynced;
  }

  /// Save when local data was last synced.
  @visibleForTesting
  Future<void> saveLastSynced(DateTime lastSynced) async {
    await StorageService.instance!.saveValue(
      key: 'lastSynced',
      value: lastSynced.toString(),
    );
  }

  // Sync data file ID.
  String? _fileId;

  /// Check if the sync data file exists in the user's Google Drive.
  ///
  /// Throws an exception if there are multiple files with the same name.
  @visibleForTesting
  Future<bool> remoteSyncFileExists() async {
    final files = await _driveApi.files.list();
    final file =
        files.files?.firstWhereOrNull((file) => file.name == kSyncDataFileName);
    if (file == null) {
      return false;
    }

    final filesWithSameName =
        files.files?.where((file) => file.name == kSyncDataFileName).toList();
    if (filesWithSameName?.length != 1) {
      throw Exception('Multiple files with the same name');
    }

    _fileId = file.id;

    return true;
  }

  /// Create initial sync data file in the user's Google Drive.
  ///
  /// Returns true if the file was created successfully.
  /// Returns false if there was an error or if there file already exists.
  @visibleForTesting
  Future<bool> createFile() async {
    if (await remoteSyncFileExists()) {
      return false;
    }

    final fileMetadata = File(name: kSyncDataFileName);

    try {
      await _driveApi.files.create(fileMetadata);
      return true;
    } catch (e) {
      log.e(e);
      return false;
    }
  }

  // Download the sync data file from the user's Google Drive.
  @visibleForTesting
  Future<SyncData> download() async {
    final files = await _driveApi.files.list();
    final file =
        files.files?.firstWhere((file) => file.name == kSyncDataFileName);
    if (file == null) {
      throw Exception('File not found');
    }

    final tempDir = io.Directory.systemTemp;
    final fileStream =
        io.File('${tempDir.path}/$kSyncDataFileName}').openWrite();
    final media = await _driveApi.files
        .get(file.id!, downloadOptions: DownloadOptions.fullMedia) as Media;
    await media.stream.pipe(fileStream);

    final fileAsString =
        await io.File('${tempDir.path}/$kSyncDataFileName}').readAsString();

    final syncData = SyncData.fromJson(fileAsString);

    // final syncData = SyncData.fromJson(
    //   await io.File('${tempDir.path}/$kSyncDataFileName}').readAsString(),
    // );

    return syncData;
  }

  /// Update the sync data file in the user's Google Drive.
  ///
  /// Returns the updated [SyncData].
  /// Returns null if there was an error.
  ///
  /// Throws an exception if the file does not already exist.
  ///
  /// Will update the [SyncData]'s [SyncData.lastSynced] field.
  @visibleForTesting
  Future<SyncData?> upload(SyncData data) async {
    if (_fileId == null) {
      throw Exception('File does not exist');
    }

    // Update the last synced field before sync.
    final updatedData = data.copyWith(lastSynced: DateTime.now().toUtc());

    final tempDir = io.Directory.systemTemp;
    await io.File('${tempDir.path}/$kSyncDataFileName}').writeAsString(
      updatedData.toJson(),
    );

    final media = Media(
      io.File('${tempDir.path}/$kSyncDataFileName}').openRead(),
      io.File('${tempDir.path}/$kSyncDataFileName}').lengthSync(),
    );

    try {
      await _driveApi.files.update(
        File(name: kSyncDataFileName),
        _fileId!,
        uploadMedia: media,
      );
      return updatedData;
    } catch (e) {
      log.e(e);
      return null;
    }
  }
}
