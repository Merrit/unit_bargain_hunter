import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unit_bargain_hunter/calculator/models/models.dart';
import 'package:unit_bargain_hunter/storage/storage_service.dart';
import 'package:unit_bargain_hunter/sync/sync.dart';

class MockDriveApi extends Mock implements DriveApi {}

final driveApi = MockDriveApi();

class MockFilesResource extends Mock implements FilesResource {}

final filesResource = MockFilesResource();

class MockMedia extends Mock implements Media {}

final media = MockMedia();

class MockAuthClient extends Mock implements AuthClient {}

final authClient = MockAuthClient();

class MockStorageService extends Mock implements StorageService {}

final storageService = MockStorageService();

late GoogleDriveSyncService service;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final exampleData = SyncData(
    lastSynced: DateTime(2021, 1, 1),
    sheets: [
      Sheet(
        index: 0,
        name: 'Example Sheet',
        items: [
          Item(
            price: 1.00,
            quantity: 1.00,
            unit: Unit.gram,
          ),
          Item(
            price: 2.00,
            quantity: 2.00,
            unit: Unit.gram,
          ),
        ],
      ),
      Sheet(
        index: 1,
        name: 'Example Sheet 2',
        items: [
          Item(
            price: 3.00,
            quantity: 3.00,
            unit: Unit.kilogram,
          ),
          Item(
            price: 4.00,
            quantity: 4.00,
            unit: Unit.milligram,
          ),
        ],
      ),
    ],
  );

  setUpAll(() async {
    registerFallbackValue(const DownloadOptions());
    registerFallbackValue(File());

    // Mock the storage service.
    StorageService.instance = storageService;
    when(() => storageService.getValue('lastSynced'))
        .thenAnswer((_) async => null);
    when(() => storageService.saveValue(
        key: 'lastSynced',
        value: any(named: 'value'))).thenAnswer((_) async {});

    // Mock the auth client.
    when(() => authClient.close()).thenAnswer((_) async {});

    // Mock the drive api.
    when(() => driveApi.files).thenReturn(filesResource);

    // Mock the media.
    when(() => media.stream).thenAnswer((_) async* {
      yield utf8.encode(exampleData.toJson());
    });
    when(() => media.contentType).thenReturn('application/json');
    when(() => media.length)
        .thenReturn(jsonEncode(exampleData.toJson()).length);

    // Mock the files resource.
    when(() => filesResource.list()).thenAnswer((_) async {
      final response = Response(
        jsonEncode({
          'files': [
            {
              'id': 'abc123',
              'name': kSyncDataFileName,
            }
          ]
        }),
        200,
      );
      return FileList.fromJson(jsonDecode(response.body));
    });
    when(() => filesResource.create(any())).thenAnswer((_) async {
      final response = Response(
        jsonEncode({
          'id': 'abc123',
          'name': kSyncDataFileName,
        }),
        200,
      );
      return File.fromJson(jsonDecode(response.body));
    });
    when(() => filesResource.update(any(), any(),
        uploadMedia: any(named: 'uploadMedia'))).thenAnswer((_) async {
      final response = Response(
        jsonEncode({
          'id': 'abc123',
          'name': kSyncDataFileName,
        }),
        200,
      );
      return File.fromJson(jsonDecode(response.body));
    });

    when(() => filesResource.get(any(),
        downloadOptions: any(named: 'downloadOptions'))).thenAnswer((_) async {
      return media;
    });
  });

  setUp(() async {
    service = GoogleDriveSyncService(driveApi);
    await service.remoteSyncFileExists();
  });

  group('GoogleDriveSyncService:', () {
    test('can upload data', () async {
      final result = await service.upload(exampleData);
      expect(result, isNotNull);
      expect(result!.lastSynced.isAfter(exampleData.lastSynced), isTrue);
      expect(result.sheets.length, exampleData.sheets.length);
      expect(result.sheets.first.name, exampleData.sheets.first.name);
    });

    test('can download data', () async {
      final result = await service.download();
      expect(result, isNotNull);
      expect(result.sheets.length, exampleData.sheets.length);
      expect(result.sheets.first.name, exampleData.sheets.first.name);
    });

    test('can sync sheets', () async {
      final result = await service.syncSheets(exampleData.sheets);
      expect(result, isNotNull);
      expect(result?.length, exampleData.sheets.length);
    });
  });
}
