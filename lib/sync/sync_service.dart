import 'package:flutter/foundation.dart';

import '../calculator/models/models.dart';
import '../storage/storage_service.dart';
import 'sync.dart';

/// Name of the sync data file.
const kSyncDataFileName = 'unit_bargain_hunter_sync_data.json';

/// This class is used to sync data between the app and a cloud service.
class SyncService {
  final StorageService _storageService;
  final SyncRepository _syncRepository;

  SyncService._(this._storageService, this._syncRepository) {
    instance = this;
  }

  /// Singleton instance of the [SyncService].
  static SyncService? instance;

  /// Initialize the [SyncService].
  static Future<SyncService> initialize({
    required StorageService storageService,
    required SyncRepository syncRepository,
  }) async {
    return SyncService._(storageService, syncRepository);
  }

  /// Takes a list of [Sheet]s to sync with the cloud service.
  ///
  /// Compares the [Sheet]s with the [SyncData] stored in the cloud service.
  ///
  /// Returns a list of [Sheet]s that have been updated.
  ///
  /// Throws a [SyncException] if an error occurs.
  Future<List<Sheet>> syncSheets(List<Sheet> sheets) async {
    final SyncData? cloudSyncData = await _downloadSyncData();

    SyncData localSyncData = SyncData(
      lastSynced: await _whenLocalLastSynced(),
      sheets: sheets,
    );

    final bool localIsNewer = isLocalSyncDataNewer(
      localSyncData: localSyncData,
      cloudSyncData: cloudSyncData,
    );

    // If the local version is newer, upload it to the cloud service.
    if (localIsNewer) {
      // Update sync data with the new last synced time.
      localSyncData = localSyncData.copyWith(
        lastSynced: DateTime.now().toUtc(),
      );

      final bool uploadSuccessful = await _uploadSyncData(localSyncData);
      if (!uploadSuccessful) {
        throw SyncException('Failed to upload sync data to cloud service.');
      }
    } else {
      // If the cloud version is newer, set it as the local data to be returned.
      localSyncData = cloudSyncData!;
    }

    // Save the last time data was synced.
    await _storageService.saveValue(
      key: 'lastSynced',
      value: localSyncData.lastSynced!.toUtc().toIso8601String(),
    );

    return localSyncData.sheets;
  }

  /// Downloads the [SyncData] from the cloud service.
  ///
  /// Returns the [SyncData] if it exists, `null` otherwise.
  ///
  /// Throws a [SyncException] if an error occurs.
  Future<SyncData?> _downloadSyncData() async {
    final cloudSyncDataBytes = await _syncRepository.download(
      fileName: kSyncDataFileName,
    );

    if (cloudSyncDataBytes != null) {
      return SyncData.fromBytes(cloudSyncDataBytes);
    }

    return null;
  }

  /// Checks whether the local or cloud version of the [SyncData] is newer.
  ///
  /// Returns `true` if the local version is newer, `false` if the cloud version is newer.
  /// Returns `true` if the cloud version does not exist.
  /// Returns `true` if both versions exist and are the same.
  @visibleForTesting
  bool isLocalSyncDataNewer({
    required SyncData localSyncData,
    required SyncData? cloudSyncData,
  }) {
    if (cloudSyncData == null) {
      return true;
    }

    if (localSyncData.lastSynced == null) {
      return false;
    }

    if (cloudSyncData.lastSynced == null) {
      return true;
    }

    if (localSyncData.lastSynced!.isAtSameMomentAs(cloudSyncData.lastSynced!)) {
      return true;
    }

    return localSyncData.lastSynced!.isAfter(cloudSyncData.lastSynced!);
  }

  /// Uploads the [SyncData] to the cloud service.
  ///
  /// Returns `true` if the upload was successful, `false` otherwise.
  ///
  /// Throws a [SyncException] if an error occurs.
  Future<bool> _uploadSyncData(SyncData syncData) async {
    try {
      await _syncRepository.upload(
        fileName: kSyncDataFileName,
        data: syncData.toBytes(),
      );
      return true;
    } on SyncException catch (e) {
      throw SyncException(
        'Failed to upload sync data to cloud service: ${e.message}',
      );
    }
  }

  /// Checks local storage for the last time data was synced.
  ///
  /// Returns a DateTime object representing the last time data was synced.
  ///
  /// Returns null if no data has been synced.
  Future<DateTime?> _whenLocalLastSynced() async {
    final String? lastSyncedString = await _storageService.getValue(
      'lastSynced',
    );

    if (lastSyncedString == null) {
      return null;
    }

    return DateTime.parse(lastSyncedString);
  }
}
