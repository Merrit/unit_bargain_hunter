import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unit_bargain_hunter/app/cubit/app_cubit.dart';
import 'package:unit_bargain_hunter/authentication/authentication.dart';
import 'package:unit_bargain_hunter/calculator/calculator_cubit/calculator_cubit.dart';
import 'package:unit_bargain_hunter/calculator/models/models.dart';
import 'package:unit_bargain_hunter/logs/logs.dart';
import 'package:unit_bargain_hunter/purchases/cubit/purchases_cubit.dart';
import 'package:unit_bargain_hunter/storage/storage_service.dart';
import 'package:unit_bargain_hunter/sync/sync.dart';

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

class MockAuthenticationCubit extends MockCubit<AuthenticationState>
    implements AuthenticationCubit {}

class MockLogger extends Mock implements Logger {}

class MockPurchasesCubit extends Mock implements PurchasesCubit {}

class MockStorageService extends Mock implements StorageService {}

class MockSyncRepository extends Mock implements SyncRepository {}

late MockAppCubit appCubit;
late MockAuthenticationCubit authCubit;
late MockPurchasesCubit _purchasesCubit;
late MockStorageService storageService;
late MockSyncRepository syncRepository;
late SyncService syncService;

late CalculatorCubit cubit;

Future<void> main() async {
  group('CalculatorCubit: ', () {
    setUpAll(() async {
      await LoggingManager.initialize(verbose: false);
    });

    setUp(() async {
      // Mock the AppCubit
      appCubit = MockAppCubit();
      when(() => appCubit.state).thenReturn(
        const AppState(
          firstRun: false,
          runningVersion: '1.0.0',
          updateVersion: '1.0.0',
          updateAvailable: false,
          showUpdateButton: false,
          promptForProUpgrade: false,
          releaseNotes: null,
        ),
      );

      // Mock the AuthenticationCubit
      authCubit = MockAuthenticationCubit();
      when(() => authCubit.state).thenReturn(
        const AuthenticationState(
          accessCredentials: null,
          signedIn: false,
          waitingForUserToSignIn: false,
        ),
      );

      // Mock the PurchasesCubit
      _purchasesCubit = MockPurchasesCubit();

      // Mock the StorageService
      storageService = MockStorageService();
      when(() => storageService.getValue('activeSheetId'))
          .thenAnswer((_) async => '1');
      when(() => storageService.saveValue(
            key: 'activeSheetId',
            value: any(named: 'value'),
          )).thenAnswer((_) async => Future.value());
      when(() => storageService.getValue('lastSynced'))
          .thenAnswer((_) async {});
      when(() => storageService.getValue('showSidePanel'))
          .thenAnswer((_) async => true);
      when(() => storageService.getStorageAreaValues('sheets'))
          .thenAnswer((_) async => []);
      when(() => storageService.saveValue(
            key: any(named: 'key'),
            value: any(named: 'value'),
            storageArea: any(named: 'storageArea'),
          )).thenAnswer((_) async => Future.value());
      when(() => storageService.deleteValue(
            any(),
            storageArea: any(named: 'storageArea'),
          )).thenAnswer((_) async => Future.value());

      // Mock the SyncService
      syncRepository = MockSyncRepository();
      SyncRepository.instance = syncRepository;

      // Setup the SyncService
      syncService = await SyncService.initialize(
        storageService: storageService,
        syncRepository: syncRepository,
      );
      SyncService.instance = syncService;

      // Initialize the CalculatorCubit
      cubit = await CalculatorCubit.initialize(
        appCubit,
        authCubit,
        _purchasesCubit,
        storageService,
      );
    });

    test('initializes with 2 items', () {
      expect(cubit.state.activeSheet?.items.length, 2);
    });

    test('items have unique uuids', () {
      final uuidA = cubit.state.activeSheet?.items[0].uuid;
      final uuidB = cubit.state.activeSheet?.items[1].uuid;
      expect(uuidA != uuidB, true);
    });

    test('added item is in correct order', () {
      final initialItems =
          cubit.state.activeSheet?.items.map((e) => e.uuid).toList();

      cubit.addItem();

      expect(cubit.state.activeSheet?.items[0].uuid, initialItems![0]);
      expect(cubit.state.activeSheet?.items[1].uuid, initialItems[1]);

      final updatedItems =
          cubit.state.activeSheet?.items.map((e) => e.uuid).toList();
      final newItem = updatedItems![2];

      expect(initialItems.contains(newItem), false);
      expect(updatedItems.contains(newItem), true);
    });

    test('deleting sheet works', () async {
      final initalSheets = cubit.state.sheets;
      expect(initalSheets.isNotEmpty, true);
      final initialSheetUuids = initalSheets.map((e) => e.uuid).toList();

      await cubit.addSheet();
      expect(cubit.state.sheets.length == (initalSheets.length + 1), true);

      final newSheet = cubit.state.sheets
          .where((element) => !initialSheetUuids.contains(element.uuid))
          .first;

      await cubit.removeSheet(newSheet);
      expect(cubit.state.sheets.contains(newSheet), false);
    });

    test('sheets without index return correctly', () {
      List<Sheet> sheets = [
        Sheet(name: 'Oats'),
        Sheet(name: 'Rice'),
        Sheet(name: 'Sugar'),
      ];

      /// Sheets initally all have index `-1` since it was not specified.
      expect(sheets.map((e) => e.index).toSet().toList(), [-1]);

      /// Sheets have been given a random index order.
      sheets = CalculatorCubit.putSheetsInOrder(sheets);
      expect(sheets.map((e) => e.index).toSet().toList(), [0, 1, 2]);
    });

    test('sheets where some are missing index returns correctly', () {
      List<Sheet> sheets = [
        Sheet(name: 'Oats', index: 0),
        Sheet(name: 'Rice'),
        Sheet(name: 'Sugar', index: 1),
      ];

      sheets = CalculatorCubit.putSheetsInOrder(sheets);
      expect(sheets[0].name, 'Oats');
      expect(sheets[0].index, 0);
      expect(sheets[1].name, 'Sugar');
      expect(sheets[1].index, 1);
      expect(sheets[2].name, 'Rice');
      expect(sheets[2].index, 2);
    });

    test('sheets with index returns correctly', () {
      List<Sheet> sheets = [
        Sheet(name: 'Oats', index: 0),
        Sheet(name: 'Rice', index: 1),
        Sheet(name: 'Sugar', index: 2),
      ];

      sheets = CalculatorCubit.putSheetsInOrder(sheets);
      expect(sheets[0].name, 'Oats');
      expect(sheets[0].index, 0);
      expect(sheets[1].name, 'Rice');
      expect(sheets[1].index, 1);
      expect(sheets[2].name, 'Sugar');
      expect(sheets[2].index, 2);
    });

    test('sheets with incorrect index returns correctly', () {
      List<Sheet> sheets = [
        Sheet(name: 'Oats', index: 0),
        Sheet(name: 'Sugar', index: 2),
      ];

      sheets = CalculatorCubit.putSheetsInOrder(sheets);
      expect(sheets[0].name, 'Oats');
      expect(sheets[0].index, 0);
      expect(sheets[1].name, 'Sugar');
      expect(sheets[1].index, 1);
    });

    group('sync:', () {
      setUp(() {
        // Mock the AuthenticationCubit
        const authenticatedState = AuthenticationState(
          accessCredentials: null,
          signedIn: true,
          waitingForUserToSignIn: false,
        );

        whenListen(
          authCubit,
          Stream.fromIterable([authenticatedState]),
          initialState: authenticatedState,
        );

        // Mock the StorageService
        when(() => storageService.getValue('lastSynced'))
            .thenAnswer((_) async => null);

        // Mock the SyncRepository
        when(() => syncRepository.upload(
              fileName: any(named: 'fileName'),
              data: any(named: 'data'),
            )).thenAnswer((_) async => true);
      });

      test('remote sheets are returned if there is no sync time saved locally',
          () async {
        // expect state to have default sheet
        expect(cubit.state.sheets.length, 1);
        expect(cubit.state.sheets.first.name, 'Unnamed Sheet');

        final remoteSheets = [
          Sheet(name: 'Oats', index: 0),
          Sheet(name: 'Rice', index: 1),
          Sheet(name: 'Sugar', index: 2),
        ];

        final remoteLastSynced = DateTime //
                .now()
            .subtract(const Duration(hours: 2));

        when(() => storageService.getValue('lastSynced'))
            .thenAnswer((_) async => null);
        when(() => syncRepository.download(fileName: any(named: 'fileName')))
            .thenAnswer((_) async => SyncData(
                  lastSynced: remoteLastSynced,
                  sheets: remoteSheets,
                ).toBytes());

        await cubit.syncData();

        expect(cubit.state.sheets.length, 3);
        expect(cubit.state.sheets, remoteSheets);
      });

      test(
          'local sheets are returned if there is a sync time saved locally and '
          'the remote sync time is older', () async {
        // expect state to have default sheet
        expect(cubit.state.sheets.length, 1);
        expect(cubit.state.sheets.first.name, 'Unnamed Sheet');
        expect(cubit.state.sheets.first.items.length, 2);

        // Customize local sheet
        cubit.updateActiveSheet(
          cubit.state.activeSheet!.copyWith(name: 'Oats'),
        );

        cubit.updateItem(
            item: cubit.state.activeSheet!.items[0].copyWith(
          location: 'Costco',
          price: 2,
          quantity: 900,
          unit: Unit.gram,
        ));

        cubit.updateItem(
            item: cubit.state.activeSheet!.items[1].copyWith(
          location: 'Walmart',
          price: 4,
          quantity: 0.2,
          unit: Unit.kilogram,
        ));

        // Verify local sheet and items are customized
        expect(cubit.state.sheets.length, 1);
        expect(cubit.state.sheets.first.name, 'Oats');
        expect(cubit.state.sheets.first.items.length, 2);
        expect(cubit.state.sheets.first.items[0].location, 'Costco');
        expect(cubit.state.sheets.first.items[0].price, 2);
        expect(cubit.state.sheets.first.items[0].quantity, 900);
        expect(cubit.state.sheets.first.items[0].unit, Unit.gram);
        expect(cubit.state.sheets.first.items[1].location, 'Walmart');
        expect(cubit.state.sheets.first.items[1].price, 4);
        expect(cubit.state.sheets.first.items[1].quantity, 0.2);
        expect(cubit.state.sheets.first.items[1].unit, Unit.kilogram);

        final remoteSheets = [
          Sheet(name: 'Rice', index: 0),
          Sheet(name: 'Sugar', index: 1),
        ];

        final remoteLastSynced = DateTime //
                .now()
            .subtract(const Duration(days: 20));

        final localLastSynced = DateTime //
                .now()
            .subtract(const Duration(days: 5));

        when(() => storageService.getValue('lastSynced'))
            .thenAnswer((_) async => localLastSynced.toUtc().toIso8601String());
        when(() => syncRepository.download(fileName: any(named: 'fileName')))
            .thenAnswer((_) async => SyncData(
                  lastSynced: remoteLastSynced,
                  sheets: remoteSheets,
                ).toBytes());

        await cubit.syncData();

        expect(cubit.state.sheets.length, 1);
        expect(cubit.state.sheets.first.name, 'Oats');
        expect(cubit.state.sheets.first.items.length, 2);
        expect(cubit.state.sheets.first.items[0].location, 'Costco');
        expect(cubit.state.sheets.first.items[0].price, 2);
        expect(cubit.state.sheets.first.items[0].quantity, 900);
        expect(cubit.state.sheets.first.items[0].unit, Unit.gram);
        expect(cubit.state.sheets.first.items[1].location, 'Walmart');
        expect(cubit.state.sheets.first.items[1].price, 4);
        expect(cubit.state.sheets.first.items[1].quantity, 0.2);
        expect(cubit.state.sheets.first.items[1].unit, Unit.kilogram);
      });

      test(
          'remote sheets are returned if there is a sync time saved locally and '
          'the remote sync time is newer', () async {
        // expect state to have default sheet
        expect(cubit.state.sheets.length, 1);
        expect(cubit.state.sheets.first.name, 'Unnamed Sheet');
        expect(cubit.state.sheets.first.items.length, 2);

        // Customize local sheet
        cubit.updateActiveSheet(
          cubit.state.activeSheet!.copyWith(name: 'Oats'),
        );

        cubit.updateItem(
            item: cubit.state.activeSheet!.items[0].copyWith(
          location: 'Costco',
          price: 2,
          quantity: 900,
          unit: Unit.gram,
        ));

        cubit.updateItem(
            item: cubit.state.activeSheet!.items[1].copyWith(
          location: 'Walmart',
          price: 4,
          quantity: 0.2,
          unit: Unit.kilogram,
        ));

        // Verify local sheet and items are customized
        expect(cubit.state.sheets.length, 1);
        expect(cubit.state.sheets.first.name, 'Oats');
        expect(cubit.state.sheets.first.items.length, 2);
        expect(cubit.state.sheets.first.items[0].location, 'Costco');
        expect(cubit.state.sheets.first.items[0].price, 2);
        expect(cubit.state.sheets.first.items[0].quantity, 900);
        expect(cubit.state.sheets.first.items[0].unit, Unit.gram);
        expect(cubit.state.sheets.first.items[1].location, 'Walmart');
        expect(cubit.state.sheets.first.items[1].price, 4);
        expect(cubit.state.sheets.first.items[1].quantity, 0.2);
        expect(cubit.state.sheets.first.items[1].unit, Unit.kilogram);

        final remoteSheets = [
          Sheet(
            name: 'Rice',
            index: 0,
            items: [
              Item(
                details: 'Large bag',
                location: 'Costco',
                price: 2,
                quantity: 900,
                unit: Unit.gram,
              ),
              Item(
                details: 'Box',
                location: 'Walmart',
                price: 4,
                quantity: 0.2,
                unit: Unit.kilogram,
              ),
            ],
          ),
          Sheet(
            name: 'Sugar',
            index: 1,
            items: [
              Item(
                location: 'Costco',
                price: 2,
                quantity: 500,
                unit: Unit.gram,
              ),
              Item(
                location: 'Walmart',
                price: 4,
                quantity: 0.125,
                unit: Unit.kilogram,
              ),
            ],
          ),
        ];

        final remoteLastSynced = DateTime //
                .now()
            .subtract(const Duration(days: 5));

        final localLastSynced = DateTime //
                .now()
            .subtract(const Duration(days: 20));

        when(() => storageService.getValue('lastSynced'))
            .thenAnswer((_) async => localLastSynced.toUtc().toIso8601String());
        when(() => syncRepository.download(fileName: any(named: 'fileName')))
            .thenAnswer((_) async => SyncData(
                  lastSynced: remoteLastSynced,
                  sheets: remoteSheets,
                ).toBytes());

        await cubit.syncData();

        expect(cubit.state.sheets.length, 2);

        expect(cubit.state.sheets.first.name, 'Rice');
        expect(cubit.state.sheets.first.items.length, 2);
        expect(cubit.state.sheets.first.items[0].location, 'Costco');
        expect(cubit.state.sheets.first.items[0].price, 2);
        expect(cubit.state.sheets.first.items[0].quantity, 900);
        expect(cubit.state.sheets.first.items[0].unit, Unit.gram);
        expect(cubit.state.sheets.first.items[1].location, 'Walmart');
        expect(cubit.state.sheets.first.items[1].price, 4);
        expect(cubit.state.sheets.first.items[1].quantity, 0.2);
        expect(cubit.state.sheets.first.items[1].unit, Unit.kilogram);

        expect(cubit.state.sheets[1].name, 'Sugar');
        expect(cubit.state.sheets[1].items.length, 2);
        expect(cubit.state.sheets[1].items[0].location, 'Costco');
        expect(cubit.state.sheets[1].items[0].price, 2);
        expect(cubit.state.sheets[1].items[0].quantity, 500);
        expect(cubit.state.sheets[1].items[0].unit, Unit.gram);
        expect(cubit.state.sheets[1].items[1].location, 'Walmart');
        expect(cubit.state.sheets[1].items[1].price, 4);
        expect(cubit.state.sheets[1].items[1].quantity, 0.125);
        expect(cubit.state.sheets[1].items[1].unit, Unit.kilogram);
      });
    });
  });
}
