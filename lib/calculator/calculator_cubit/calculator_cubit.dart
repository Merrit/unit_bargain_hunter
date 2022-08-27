import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import '../../app/cubit/app_cubit.dart';
import '../../purchases/cubit/purchases_cubit.dart';
import '../../storage/storage_service.dart';
import '../calculator.dart';
import '../calculator_page.dart';
import '../models/models.dart';

part 'calculator_state.dart';

/// Globally accessible variable for the [CalculatorCubit].
///
/// There is only ever one cubit, so this eases access.
late CalculatorCubit calcCubit;

class CalculatorCubit extends Cubit<CalculatorState> {
  final PurchasesCubit _purchasesCubit;
  final StorageService _storageService;

  CalculatorCubit(
    this._purchasesCubit,
    this._storageService, {
    required CalculatorState initialState,
  }) : super(initialState) {
    calcCubit = this;
    _saveAllSheets(); // In case the order was fixed on load.
  }

  static Future<CalculatorCubit> initialize(
    PurchasesCubit purchasesCubit,
    StorageService storageService,
  ) async {
    final bool? showSidePanel = await storageService.getValue('showSidePanel');
    final storedSheets = await storageService.getStorageAreaValues('sheets');

    List<Sheet> sheets;
    if (storedSheets.isEmpty) {
      sheets = [Sheet()];
    } else {
      sheets = storedSheets.map((e) => Sheet.fromJson(e)).toList();
    }

    sheets = putSheetsInOrder(sheets);

    return CalculatorCubit(
      purchasesCubit,
      storageService,
      initialState: CalculatorState(
        showSidePanel: showSidePanel ?? true,
        sheets: sheets,
        activeSheetId: sheets.first.uuid,
        activeSheet: sheets.first,
        result: const <Item>[],
      ),
    );
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
  void compare() {
    assert(state.activeSheet != null);
    emit(state.copyWith(result: [])); // Reset result.
    final result = const Calculator().compare(items: state.activeSheet!.items);
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

  void updateItem({
    required Item item,
    String? price,
    String? quantity,
    Unit? unit,
  }) {
    assert(state.activeSheet != null);
    double? validatedPrice;
    double? validatedQuantity;
    if (price != null) validatedPrice = double.tryParse(price);
    if (quantity != null) validatedQuantity = double.tryParse(quantity);
    final updatedItem = item.copyWith(
      price: validatedPrice,
      quantity: validatedQuantity,
      unit: unit,
    );
    resetResult();
    final updatedSheet = state.activeSheet!.updateItem(updatedItem);
    updateActiveSheet(updatedSheet);
  }

  /// Reset the results if user changes values.
  void resetResult() {
    if (state.result.isEmpty) return;
    emit(state.copyWith(result: []));
  }

  /// Toggle show/hide for the side panel that holds
  /// the drawer contents on large screen devices.
  void toggleShowSidePanel() {
    emit(state.copyWith(showSidePanel: !state.showSidePanel));
    _storageService.saveValue(key: 'showSidePanel', value: state.showSidePanel);
  }

  Future<void> addSheet() async {
    if (state.sheets.length >= 5 && !_purchasesCubit.state.proPurchased) {
      appCubit.promptForProUpgrade();
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
      showSidePanel: state.showSidePanel,
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
}
