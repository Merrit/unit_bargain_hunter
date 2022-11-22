import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unit_bargain_hunter/app/app.dart';

class MockAppVersion extends Mock implements AppVersion {}

final appVersion = MockAppVersion();

void main() {
  setUp(() {
    when(() => appVersion.latestVersion())
        .thenAnswer((_) async => Future.value('1.0.0'));
    when(() => appVersion.runningVersion())
        .thenAnswer((_) async => Future.value('1.0.0'));
    when(() => appVersion.updateAvailable())
        .thenAnswer((_) async => Future.value(false));
  });
  group('AppCubit:', () {
    test('instance variable is accessible', () {
      final _appCubit = AppCubit(appVersion);
      final state = appCubit.state;
      expect(state, isA<AppState>());
    });
  });
}
