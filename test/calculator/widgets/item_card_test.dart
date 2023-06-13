import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:unit_bargain_hunter/authentication/authentication.dart';
import 'package:unit_bargain_hunter/calculator/calculator_cubit/calculator_cubit.dart';
import 'package:unit_bargain_hunter/calculator/models/models.dart';
import 'package:unit_bargain_hunter/calculator/widgets/widgets.dart';
import 'package:unit_bargain_hunter/logs/logging_manager.dart';
import 'package:unit_bargain_hunter/purchases/cubit/purchases_cubit.dart';
import 'package:unit_bargain_hunter/settings/settings.dart';
import 'package:unit_bargain_hunter/storage/storage_service.dart';

@GenerateNiceMocks([
  MockSpec<AuthenticationCubit>(),
  MockSpec<PurchasesCubit>(),
  MockSpec<SettingsCubit>(),
  MockSpec<StorageService>(),
])
import 'item_card_test.mocks.dart';

late MockAuthenticationCubit authCubit;
late MockPurchasesCubit _purchasesCubit;
late MockSettingsCubit settingsCubit;
late MockStorageService storageService;

late CalculatorCubit calculatorCubit;

void main() {
  group('ItemCard:', () {
    setUpAll(() async {
      await LoggingManager.initialize(verbose: false);
    });

    setUp(() {
      authCubit = MockAuthenticationCubit();
      when(authCubit.state).thenReturn(
        const AuthenticationState(
          accessCredentials: null,
          signedIn: false,
          waitingForUserToSignIn: false,
        ),
      );

      _purchasesCubit = MockPurchasesCubit();

      settingsCubit = MockSettingsCubit();
      when(settingsCubit.state).thenReturn(
        SettingsState(
          navigationAreaRatio: 0.3,
          taxRate: 0.0,
          theme: ThemeData.dark(),
        ),
      );

      storageService = MockStorageService();

      final sheet = Sheet(uuid: '1');

      calculatorCubit = CalculatorCubit(
        authCubit,
        _purchasesCubit,
        storageService,
        initialState: CalculatorState(
          sheets: [sheet],
          activeSheetId: sheet.uuid,
          activeSheet: sheet,
          result: const <Item>[],
        ),
      );
    });

    testWidgets('basic item', (tester) async {
      final item = Item(
        details: 'Item 1',
        price: 1.00,
        unit: Unit.gram,
        quantity: 1,
      );

      final sheet = Sheet(
        uuid: '1',
        items: [item],
      );

      calculatorCubit = CalculatorCubit(
        authCubit,
        _purchasesCubit,
        storageService,
        initialState: CalculatorState(
          sheets: [sheet],
          activeSheetId: sheet.uuid,
          activeSheet: sheet,
          result: const <Item>[],
        ),
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<CalculatorCubit>.value(value: calculatorCubit),
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ItemCard(item: item),
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text(r'$ 1.00'), findsOneWidget);
      expect(find.text('1.0 grams'), findsOneWidget);
      expect(find.text('+tax'), findsNothing);
    });

    testWidgets('item with tax', (tester) async {
      final item = Item(
        details: 'Item 1',
        price: 1.00,
        unit: Unit.gram,
        quantity: 1,
        taxIncluded: false,
      );

      final sheet = Sheet(
        uuid: '1',
        items: [item],
      );

      calculatorCubit = CalculatorCubit(
        authCubit,
        _purchasesCubit,
        storageService,
        initialState: CalculatorState(
          sheets: [sheet],
          activeSheetId: sheet.uuid,
          activeSheet: sheet,
          result: const <Item>[],
        ),
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<CalculatorCubit>.value(value: calculatorCubit),
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ItemCard(item: item),
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text(r'$ 1.00'), findsOneWidget);
      expect(find.text('1.0 grams'), findsOneWidget);
      expect(find.text('+tax'), findsOneWidget);
    });
  });
}
