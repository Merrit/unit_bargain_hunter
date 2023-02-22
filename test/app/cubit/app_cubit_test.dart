import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unit_bargain_hunter/app/app_widget.dart';
import 'package:unit_bargain_hunter/updates/updates.dart';

class MockUpdateService extends Mock implements UpdateService {}

final updateService = MockUpdateService();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
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

  group('AppCubit:', () {
    test('instance variable is accessible', () {
      // Simulate instantiation on app run.
      AppCubit(updateService);
      // Verify instance variable.
      final state = AppCubit.instance.state;
      expect(state, isA<AppState>());
    });
  });
}
