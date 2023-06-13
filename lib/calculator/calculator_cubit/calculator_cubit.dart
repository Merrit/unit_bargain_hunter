import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import '../../app/cubit/app_cubit.dart';
import '../../authentication/authentication.dart';
import '../../logs/logs.dart';
import '../../purchases/cubit/purchases_cubit.dart';
import '../../storage/storage_service.dart';
import '../../sync/sync.dart';
import '../calculator.dart';
import '../calculator_page.dart';
import '../models/models.dart';

part 'calculator_state.dart';

class CalculatorCubit extends Cubit<CalculatorState> {
  final AppCubit _appCubit;
  final AuthenticationCubit _authCubit;
  final PurchasesCubit _purchasesCubit;
  final StorageService _storageService;

  CalculatorCubit(
    this._appCubit,
    this._authCubit,
    this._purchasesCubit,
    this._storageService, {
    required CalculatorState initialState,
  }) : super(initialState) {
    _saveAllSheets(); // In case the order was fixed on load.
    syncData();
  }

  static Future<CalculatorCubit> initialize(
    AppCubit appCubit,
    AuthenticationCubit authCubit,
    PurchasesCubit purchasesCubit,
    StorageService storageService,
  ) async {
    final storedSheets = await storageService.getStorageAreaValues('sheets');

    List<Sheet> sheets;
    if (storedSheets.isEmpty) {
      sheets = [Sheet()];
    } else {
      sheets = storedSheets.map((e) => Sheet.fromJson(e)).toList();
    }

    sheets = putSheetsInOrder(sheets);

    return CalculatorCubit(
      appCubit,
      authCubit,
      purchasesCubit,
      storageService,
      initialState: CalculatorState(
        sheets: sheets,
        activeSheetId: sheets.first.uuid,
        activeSheet: sheets.first,
        result: const <Item>[],
        lastSync: DateTime.tryParse(
          await storageService.getValue('lastSynced') ?? '',
        ),
      ),
    );
  }

  /// Timer that will sync data with the cloud every 5 minutes.
  Timer? _syncTimer;

  /// Set the sync timer.
  void _setSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => syncData(),
    );
  }

  /// Sync with remote storage using the [SyncService].
  Future<void> syncData() async {
    if (!_authCubit.state.signedIn) {
      log.i('Not signed in, not syncing.');
      return;
    }

    assert(SyncService.instance != null);
    if (_syncTimer == null) _setSyncTimer();
    emit(state.copyWith(syncing: true));
    log.v('Syncing data...');

    final List<Sheet>? sheets;
    try {
      sheets = await SyncService.instance?.syncSheets(state.sheets);
    } catch (e) {
      log.e('Error syncing', e);
      emit(state.copyWith(syncing: false));
      return;
    }

    emit(state.copyWith(syncing: false));

    if (sheets == null) {
      log.w('No sheets returned from sync.');
      return;
    }

    emit(state.copyWith(lastSync: DateTime.now(), sheets: sheets));
    log.v('Sync complete.');
    await _saveAllSheets();
  }

  /// Reset sync status.
  Future<void> resetSync() async {
    await _storageService.deleteValue('lastSynced');
    emit(state.copyWith(clearLastSync: true));
  }

  /// Verify's the index of the sheets and returns them in order.
  static List<Sheet> putSheetsInOrder(List<Sheet> sheets) {
    List<Sheet> unorderedSheets = [];
    List<Sheet> orderedSheets = List.filled(sheets.length, Sheet());

    for (var sheet in sheets) {
      final bool hasNoIndex = (sheet.index == -1);
      final bool indexOutOfRange = (sheet.index >= sheets.length);
      if (hasNoIndex || indexOutOfRange) {
        unorderedSheets.add(sheet);
      } else {
        orderedSheets[sheet.index] = sheet;
      }
    }

    orderedSheets = List<Sheet>.from(orderedSheets)
      ..removeWhere((element) => element.index == -1)
      ..addAll(unorderedSheets);

    for (var i = 0; i < orderedSheets.length; i++) {
      orderedSheets[i] = orderedSheets[i].copyWith(index: i);
    }

    return orderedSheets;
  }

  /// Compare all items to find the best value.
  Future<void> compare() async {
    assert(state.activeSheet != null);
    emit(state.copyWith(result: [])); // Reset result.
    final result = const Calculator().compare(
      items: state.activeSheet!.items,
      taxRate: await _storageService.getValue('taxRate') ?? 0.0,
    );
    emit(state.copyWith(result: result));
  }

  /// The user has chosen a new compare unit; weight, volume, or item.
  Future<void> updateCompareBy(Unit unit) async {
    assert(state.activeSheet != null);
    resetResult();
    final updatedSheet = state.activeSheet!.updateCompareBy(unit);
    updateActiveSheet(updatedSheet);
  }

  void addItem() {
    assert(state.activeSheet != null);
    resetResult();
    final updatedSheet = state.activeSheet!.addItem();
    updateActiveSheet(updatedSheet);
  }

  void removeItem(String uuid) {
    assert(state.activeSheet != null);
    resetResult();
    final updatedSheet = state.activeSheet!.removeItem(uuid);
    updateActiveSheet(updatedSheet);
  }

  void updateItem({required Item item}) {
    assert(state.activeSheet != null);
    resetResult();
    final updatedSheet = state.activeSheet!.updateItem(item);
    updateActiveSheet(updatedSheet);
  }

  /// Reset the results if user changes values.
  void resetResult() {
    if (state.result.isEmpty) return;
    emit(state.copyWith(result: []));
  }

  Future<void> addSheet() async {
    if (state.sheets.length >= 5 && !_purchasesCubit.state.proPurchased) {
      _appCubit.promptForProUpgrade();
      return;
    }

    final sheets = List<Sheet>.from(state.sheets);
    final newSheet = Sheet(index: sheets.length);
    sheets.add(newSheet);
    emit(state.copyWith(sheets: sheets, activeSheet: newSheet));
    await _saveSheet(newSheet);
  }

  /// Update the contents of the active sheet, by replacing with [sheet].
  Future<void> updateActiveSheet(Sheet sheet) async {
    assert(state.activeSheet != null);
    final activeSheetIndex = state.sheets.indexOf(state.activeSheet!);
    final sheets = List<Sheet>.from(state.sheets) //
      ..[activeSheetIndex] = sheet;
    emit(state.copyWith(sheets: sheets, activeSheet: sheet));
    await _saveSheet(sheet);
  }

  /// Persist sheet data to disk.
  Future<void> _saveSheet(Sheet sheet) async {
    await _storageService.saveValue(
      key: sheet.uuid,
      value: sheet.toJson(),
      storageArea: 'sheets',
    );
  }

  Future<void> _saveAllSheets() async {
    for (var sheet in state.sheets) {
      await _saveSheet(sheet);
    }
  }

  Future<void> removeSheet(Sheet sheet) async {
    List<Sheet> sheets = List<Sheet>.from(state.sheets) //
      ..remove(sheet);
    sheets = putSheetsInOrder(sheets);
    final Sheet? activeSheet = (sheet == state.activeSheet) //
        ? sheets.firstOrNull
        : null;
    emit(CalculatorState(
      sheets: sheets,
      activeSheetId: activeSheet?.uuid,
      activeSheet: activeSheet,
      result: state.result,
    ));
    await _storageService.deleteValue(sheet.uuid, storageArea: 'sheets');
    await _saveAllSheets();
  }

  /// Set [sheet] as the active sheet that is seen in the [CalculatorView].
  void selectSheet(Sheet sheet) {
    emit(state.copyWith(activeSheet: sheet));
    compare();
  }

  /// Called when the user is reordering the list of sheets.
  Future<void> reorderSheets(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex -= 1;
    List<Sheet> sheets = List<Sheet>.from(state.sheets)
      ..removeAt(oldIndex)
      ..insert(newIndex, state.sheets[oldIndex]);
    for (var i = 0; i < sheets.length; i++) {
      sheets[i] = sheets[i].copyWith(index: i);
    }
    // sheets = putSheetsInOrder(sheets);
    final activeSheetId = state.activeSheet?.uuid;
    emit(state.copyWith(
      sheets: sheets,
      activeSheet: sheets.singleWhere((e) => e.uuid == activeSheetId),
    ));
    await _saveAllSheets();
  }

  Timer? _delayedSyncOnSaveTimer;

  /// Sets the [_delayedSyncOnSaveTimer] to trigger after a short delay.
  ///
  /// This is to prevent the sync from triggering too often.
  ///
  /// The timer is cancelled if the user makes another change before the timer
  /// triggers.
  void _setDelayedSyncOnSaveTimer() {
    _delayedSyncOnSaveTimer?.cancel();
    _delayedSyncOnSaveTimer = Timer(const Duration(seconds: 5), () {
      syncData();
    });
  }

  @override
  void onChange(Change<CalculatorState> change) {
    if (change.nextState.sheets != change.currentState.sheets) {
      _setDelayedSyncOnSaveTimer();
    }

    super.onChange(change);
  }

  @override
  Future<void> close() async {
    _syncTimer?.cancel();
    _delayedSyncOnSaveTimer?.cancel();
    await _saveAllSheets();
    return super.close();
  }
}
