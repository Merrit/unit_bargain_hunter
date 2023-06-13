import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helpers/helpers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unit_bargain_hunter/app/app_widget.dart';
import 'package:unit_bargain_hunter/storage/storage_service.dart';
import 'package:unit_bargain_hunter/updates/updates.dart';

class MockReleaseNotesService extends Mock implements ReleaseNotesService {}

final releaseNotesService = MockReleaseNotesService();

class MockStorageService extends Mock implements StorageService {}

final storageService = MockStorageService();

class MockUpdateService extends Mock implements UpdateService {}

final updateService = MockUpdateService();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Mock the ReleaseNotesService.
    when(() => releaseNotesService.getReleaseNotes(any())).thenAnswer(
      (_) => Future.value(null),
    );

    // Mock the StorageService.
    StorageService.instance = storageService;
    when(() => storageService.getValue(any())).thenAnswer(
      (_) => Future.value(null),
    );
    when(() => storageService.saveValue(
        key: any(named: 'key'),
        value: any(named: 'value'))).thenAnswer((_) => Future.value(null));

    // Mock the UpdateService.
    when(() => updateService.getVersionInfo()).thenAnswer(
      (_) => Future.value(
        const VersionInfo(
          currentVersion: '1.0.0',
          latestVersion: '1.0.0',
          updateAvailable: false,
        ),
      ),
    );
  });

  setUp(() {
    // Reset the StorageService.
    when(() => storageService.getValue('firstRun'))
        .thenAnswer((_) async => false);
  });

  group('AppCubit:', () {
    test('instance variable is accessible', () {
      final appCubit = AppCubit(
        releaseNotesService: releaseNotesService,
        updateService: updateService,
      );
      expect(appCubit, isA<AppCubit>());
      final state = appCubit.state;
      expect(state, isA<AppState>());
    });

    blocTest<AppCubit, AppState>(
      'initial state is correct',
      build: () => AppCubit(
        releaseNotesService: releaseNotesService,
        updateService: updateService,
      ),
      expect: () => [
        const AppState(
          firstRun: false,
          runningVersion: '1.0.0',
          updateVersion: '1.0.0',
          updateAvailable: false,
          showUpdateButton: false,
          promptForProUpgrade: false,
          releaseNotes: null,
        ),
      ],
    );

    blocTest<AppCubit, AppState>(
      'promptForProUpgrade() sets promptForProUpgrade to true',
      build: () => AppCubit(
        releaseNotesService: releaseNotesService,
        updateService: updateService,
      ),
      act: (cubit) => cubit.promptForProUpgrade(),
      seed: () => const AppState(
        firstRun: false,
        runningVersion: '1.0.0',
        updateVersion: '1.0.0',
        updateAvailable: false,
        showUpdateButton: false,
        promptForProUpgrade: false,
        releaseNotes: null,
      ),
      expect: () => [
        const AppState(
          firstRun: false,
          runningVersion: '1.0.0',
          updateVersion: '1.0.0',
          updateAvailable: false,
          showUpdateButton: false,
          promptForProUpgrade: true,
          releaseNotes: null,
        ),
        const AppState(
          firstRun: false,
          runningVersion: '1.0.0',
          updateVersion: '1.0.0',
          updateAvailable: false,
          showUpdateButton: false,
          promptForProUpgrade: false,
          releaseNotes: null,
        ),
      ],
    );

    blocTest<AppCubit, AppState>(
      'release notes are not fetched if they have been previously shown for the current version',
      build: () {
        when(() => storageService.getValue('lastReleaseNotesVersionShown'))
            .thenAnswer((_) => Future.value('1.0.0'));
        return AppCubit(
          releaseNotesService: releaseNotesService,
          updateService: updateService,
        );
      },
      expect: () => [
        const AppState(
          firstRun: false,
          runningVersion: '1.0.0',
          updateVersion: '1.0.0',
          updateAvailable: false,
          showUpdateButton: false,
          promptForProUpgrade: false,
          releaseNotes: null,
        ),
      ],
    );

    blocTest<AppCubit, AppState>(
      'release notes are not shown the first time the app is run',
      build: () {
        when(() => storageService.getValue('firstRun'))
            .thenAnswer((_) => Future.value(null));
        when(() => storageService.getValue('lastReleaseNotesVersionShown'))
            .thenAnswer((_) => Future.value(null));
        when(() => releaseNotesService.getReleaseNotes('v1.0.0'))
            .thenAnswer((_) => Future.value(
                  const ReleaseNotes(
                    version: '1.0.0',
                    date: '2023-01-31T20:36:20Z',
                    notes: 'Release notes',
                    fullChangeLogUrl:
                        'https://github.com/owner/repo/releases/tag/v1.0.0',
                  ),
                ));
        return AppCubit(
          releaseNotesService: releaseNotesService,
          updateService: updateService,
        );
      },
      expect: () => [
        const AppState(
          firstRun: true,
          runningVersion: '',
          updateVersion: null,
          updateAvailable: false,
          showUpdateButton: false,
          promptForProUpgrade: false,
          releaseNotes: null,
        ),
        const AppState(
          firstRun: true,
          runningVersion: '1.0.0',
          updateVersion: '1.0.0',
          updateAvailable: false,
          showUpdateButton: false,
          promptForProUpgrade: false,
          releaseNotes: null,
        ),
      ],
    );

    blocTest<AppCubit, AppState>(
      'release notes are fetched if never shown',
      build: () {
        when(() => storageService.getValue('lastReleaseNotesVersionShown'))
            .thenAnswer((_) => Future.value(null));

        when(() => releaseNotesService.getReleaseNotes('v1.0.0'))
            .thenAnswer((_) => Future.value(
                  const ReleaseNotes(
                    version: '1.0.0',
                    date: '2023-01-31T20:36:20Z',
                    notes: 'Release notes',
                    fullChangeLogUrl:
                        'https://github.com/owner/repo/releases/tag/v1.0.0',
                  ),
                ));
        return AppCubit(
          releaseNotesService: releaseNotesService,
          updateService: updateService,
        );
      },
      expect: () => [
        const AppState(
          firstRun: false,
          runningVersion: '1.0.0',
          updateVersion: '1.0.0',
          updateAvailable: false,
          showUpdateButton: false,
          promptForProUpgrade: false,
          releaseNotes: null,
        ),
        const AppState(
          firstRun: false,
          runningVersion: '1.0.0',
          updateVersion: '1.0.0',
          updateAvailable: false,
          showUpdateButton: false,
          promptForProUpgrade: false,
          releaseNotes: ReleaseNotes(
            version: '1.0.0',
            date: '2023-01-31T20:36:20Z',
            notes: 'Release notes',
            fullChangeLogUrl:
                'https://github.com/owner/repo/releases/tag/v1.0.0',
          ),
        ),
        const AppState(
          firstRun: false,
          runningVersion: '1.0.0',
          updateVersion: '1.0.0',
          updateAvailable: false,
          showUpdateButton: false,
          promptForProUpgrade: false,
          releaseNotes: null,
        ),
      ],
    );

    blocTest<AppCubit, AppState>(
      'release notes are fetched if shown for a previous version',
      build: () {
        // current version is 1.4.1
        when(() => updateService.getVersionInfo()).thenAnswer(
          (_) => Future.value(
            const VersionInfo(
              currentVersion: '1.4.1',
              latestVersion: '1.4.1',
              updateAvailable: false,
            ),
          ),
        );
        // last shown version is 1.4.0
        when(() => storageService.getValue('lastReleaseNotesVersionShown'))
            .thenAnswer((_) => Future.value('1.4.0'));
        when(() => releaseNotesService.getReleaseNotes('v1.4.1'))
            .thenAnswer((_) => Future.value(
                  const ReleaseNotes(
                    version: '1.4.1',
                    date: '2023-01-31T20:36:20Z',
                    notes: 'Release notes',
                    fullChangeLogUrl:
                        'https://github.com/owner/repo/releases/tag/v1.4.1',
                  ),
                ));
        return AppCubit(
          releaseNotesService: releaseNotesService,
          updateService: updateService,
        );
      },
      expect: () => [
        const AppState(
          firstRun: false,
          runningVersion: '1.4.1',
          updateVersion: '1.4.1',
          updateAvailable: false,
          showUpdateButton: false,
          promptForProUpgrade: false,
          releaseNotes: null,
        ),
        const AppState(
          firstRun: false,
          runningVersion: '1.4.1',
          updateVersion: '1.4.1',
          updateAvailable: false,
          showUpdateButton: false,
          promptForProUpgrade: false,
          releaseNotes: ReleaseNotes(
            version: '1.4.1',
            date: '2023-01-31T20:36:20Z',
            notes: 'Release notes',
            fullChangeLogUrl:
                'https://github.com/owner/repo/releases/tag/v1.4.1',
          ),
        ),
        const AppState(
          firstRun: false,
          runningVersion: '1.4.1',
          updateVersion: '1.4.1',
          updateAvailable: false,
          showUpdateButton: false,
          promptForProUpgrade: false,
          releaseNotes: null,
        ),
      ],
    );
  });
}
