import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unit_bargain_hunter/calculator/models/models.dart';
import 'package:unit_bargain_hunter/storage/storage_service.dart';
import 'package:unit_bargain_hunter/sync/sync.dart';

class MockStorageService extends Mock implements StorageService {}

class MockSyncRepository extends Mock implements SyncRepository {}

void main() {
  late MockStorageService storageService;
  late MockSyncRepository syncRepository;
  late SyncService syncService;

  setUp(() async {
    // Mock the StorageService
    storageService = MockStorageService();
    when(() => storageService.getValue('lastSynced')).thenAnswer((_) async {});
    when(() => storageService.saveValue(
          key: any(named: 'key'),
          value: any(named: 'value'),
          storageArea: any(named: 'storageArea'),
        )).thenAnswer((_) async => Future.value());

    // Mock the SyncRepository
    syncRepository = MockSyncRepository();

    // Initialize the SyncService
    syncService = await SyncService.initialize(
      storageService: storageService,
      syncRepository: syncRepository,
    );
  });
  group('SyncService: ', () {
    test('initializes correctly', () {
      expect(syncService, isA<SyncService>());
    });

    test('returns remote data if the local data is empty', () async {
      when(() => syncRepository.download(fileName: kSyncDataFileName))
          .thenAnswer((_) async {
        final lastSynced = DateTime.now().subtract(const Duration(hours: 2));
        final syncData = SyncData(
          lastSynced: lastSynced,
          sheets: [Sheet(name: 'Sheet 1')],
        );
        return syncData.toBytes();
      });

      final result = await syncService.syncSheets([]);
      expect(result.length, 1);
      expect(result.first.name, 'Sheet 1');
    });

    test('returns local data if the remote data is empty', () async {
      when(() => syncRepository.download(fileName: kSyncDataFileName))
          .thenAnswer((_) async => null);
      when(() => syncRepository.upload(
            fileName: any(named: 'fileName'),
            data: any(named: 'data'),
          )).thenAnswer((_) async => true);

      final result = await syncService.syncSheets([Sheet(name: 'Sheet 1')]);
      expect(result.length, 1);
      expect(result.first.name, 'Sheet 1');
    });

    test('returns local data if the remote data is older', () async {
      // Storage service returns last sync time as 1 hour ago
      when(() => storageService.getValue('lastSynced')).thenAnswer((_) async =>
          DateTime.now()
              .subtract(const Duration(hours: 1))
              .toUtc()
              .toIso8601String());

      // Remote returns data marked as synced 2 hours ago
      when(() => syncRepository.download(fileName: kSyncDataFileName))
          .thenAnswer((_) async {
        final lastSynced = DateTime.now().subtract(const Duration(hours: 2));
        final syncData = SyncData(
          lastSynced: lastSynced,
          sheets: [Sheet(name: 'Sheet 1')],
        );
        return syncData.toBytes();
      });
      when(() => syncRepository.upload(
            fileName: any(named: 'fileName'),
            data: any(named: 'data'),
          )).thenAnswer((_) async => true);

      final result = await syncService.syncSheets([Sheet(name: 'Sheet 2')]);
      expect(result.length, 1);
      expect(result.first.name, 'Sheet 2');
    });

    test('returns remote data if the local data is older', () async {
      // Storage service returns last sync time as 2 hours ago
      when(() => storageService.getValue('lastSynced')).thenAnswer((_) async =>
          DateTime.now()
              .subtract(const Duration(hours: 2))
              .toUtc()
              .toIso8601String());

      // Remote returns data marked as synced 1 hour ago
      when(() => syncRepository.download(fileName: kSyncDataFileName))
          .thenAnswer((_) async {
        final lastSynced = DateTime.now().subtract(const Duration(hours: 1));
        final syncData = SyncData(
          lastSynced: lastSynced,
          sheets: [Sheet(name: 'Sheet 1')],
        );
        return syncData.toBytes();
      });
      when(() => syncRepository.upload(
            fileName: any(named: 'fileName'),
            data: any(named: 'data'),
          )).thenAnswer((_) async => true);

      final result = await syncService.syncSheets([Sheet(name: 'Sheet 2')]);
      expect(result.length, 1);
      expect(result.first.name, 'Sheet 1');
    });

    group('isLocalSyncDataNewer', () {
      test('returns true if the local data is newer', () {
        final localSyncData = SyncData(
          lastSynced: DateTime.now().subtract(const Duration(hours: 1)),
          sheets: [Sheet(name: 'Sheet 1')],
        );
        final remoteSyncData = SyncData(
          lastSynced: DateTime.now().subtract(const Duration(hours: 2)),
          sheets: [Sheet(name: 'Sheet 2')],
        );
        final result = syncService.isLocalSyncDataNewer(
          localSyncData: localSyncData,
          cloudSyncData: remoteSyncData,
        );
        expect(result, true);
      });

      test('returns false if the remote data is newer', () {
        final localSyncData = SyncData(
          lastSynced: DateTime.now().subtract(const Duration(hours: 2)),
          sheets: [Sheet(name: 'Sheet 1')],
        );
        final remoteSyncData = SyncData(
          lastSynced: DateTime.now().subtract(const Duration(hours: 1)),
          sheets: [Sheet(name: 'Sheet 2')],
        );
        final result = syncService.isLocalSyncDataNewer(
          localSyncData: localSyncData,
          cloudSyncData: remoteSyncData,
        );
        expect(result, false);
      });

      test('returns true if the data is the same', () {
        final syncTime = DateTime //
                .now()
            .subtract(const Duration(hours: 1))
            .toUtc();
        final localSyncData = SyncData(
          lastSynced: syncTime,
          sheets: [Sheet(name: 'Sheet 1')],
        );
        final remoteSyncData = SyncData(
          lastSynced: syncTime,
          sheets: [Sheet(name: 'Sheet 1')],
        );
        final result = syncService.isLocalSyncDataNewer(
          localSyncData: localSyncData,
          cloudSyncData: remoteSyncData,
        );
        expect(result, true);
      });
    });
  });
}
