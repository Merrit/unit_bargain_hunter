import 'package:flutter_test/flutter_test.dart';
import 'package:unit_bargain_hunter/app/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppCubit:', () {
    test('instance variable is accessible', () {
      // Simulate instantiation on app run.
      AppCubit();
      // Verify instance variable.
      final state = AppCubit.instance.state;
      expect(state, isA<AppState>());
    });
  });
}
