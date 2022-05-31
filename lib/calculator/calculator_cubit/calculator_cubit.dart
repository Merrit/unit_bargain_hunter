import 'package:bloc/bloc.dart';
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
  }

  static Future<CalculatorCubit> initialize(
    PurchasesCubit purchasesCubit,
    StorageService storageService,
  ) async {
    final bool? showSidePanel = await storageService.getValue('showSidePanel');
    final storedSheets = await storageService.getStorageAreaValues('sheets');

    final List<Sheet> sheets;
    if (storedSheets.isEmpty) {
      sheets = [Sheet()];
    } else {
      sheets = storedSheets.map((e) => Sheet.fromJson(e)).toList();
    }

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

  /// Compare all items to find the best value.
  void compare() {
    emit(state.copyWith(result: [])); // Reset result.
    final result = const Calculator().compare(items: state.activeSheet.items);
    emit(state.copyWith(result: result));
  }

  /// The user has chosen a new compare unit; weight, volume, or item.
  Future<void> updateCompareBy(Unit unit) async {
    resetResult();
    final updatedSheet = state.activeSheet.updateCompareBy(unit);
    updateActiveSheet(updatedSheet);
  }

  void addItem() {
    resetResult();
    final updatedSheet = state.activeSheet.addItem();
    updateActiveSheet(updatedSheet);
  }

  void removeItem(String uuid) {
    resetResult();
    final updatedSheet = state.activeSheet.removeItem(uuid);
    updateActiveSheet(updatedSheet);
  }

  void updateItem({
    required Item item,
    String? price,
    String? quantity,
    Unit? unit,
  }) {
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
    final updatedSheet = state.activeSheet.updateItem(updatedItem);
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
    final newSheet = Sheet();
    sheets.insert(0, newSheet);
    emit(state.copyWith(sheets: sheets, activeSheet: newSheet));
    await _saveSheet(newSheet);
  }

  /// Update the contents of the active sheet, by replacing with [sheet].
  Future<void> updateActiveSheet(Sheet sheet) async {
    final activeSheetIndex = state.sheets.indexOf(state.activeSheet);
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

  Future<void> removeSheet(Sheet sheet) async {
    assert(state.sheets.length != 1);
    final sheets = List<Sheet>.from(state.sheets) //
      ..remove(sheet);
    final activeSheet = (sheet == state.activeSheet) ? sheets.first : null;
    emit(state.copyWith(sheets: sheets, activeSheet: activeSheet));
    await _storageService.deleteValue(sheet.uuid, storageArea: 'sheets');
  }

  /// Set [sheet] as the active sheet that is seen in the [CalculatorView].
  void selectSheet(Sheet sheet) {
    emit(state.copyWith(activeSheet: sheet));
    compare();
  }
}
