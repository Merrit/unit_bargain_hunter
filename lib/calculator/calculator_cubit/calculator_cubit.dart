import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

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
  final StorageService _storageService;

  CalculatorCubit(this._storageService, {required CalculatorState initialState})
      : super(initialState) {
    calcCubit = this;
  }

  static Future<CalculatorCubit> initialize(
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
      storageService,
      initialState: CalculatorState(
        showSidePanel: showSidePanel ?? true,
        alwaysShowScrollbar: false,
        comareBy: UnitType.weight,
        sheets: sheets,
        activeSheetId: sheets.first.uuid,
        activeSheet: sheets.first,
        items: _defaultItems,
        result: const <Item>[],
      ),
    );
  }

  static final _defaultItems = [
    Item(price: 0.00, quantity: 0.00, unit: Unit.gram),
    Item(price: 0.00, quantity: 0.00, unit: Unit.gram),
  ];

  /// Compare all items to find the best value.
  void compare() {
    emit(state.copyWith(result: [])); // Reset result.
    final result = const Calculator().compare(items: state.items);
    emit(state.copyWith(result: result));
  }

  /// The user has chosen a new compare unit; weight, volume, or item.
  void updateCompareBy(Unit unit) {
    emit(
      state.copyWith(
        comareBy: unit,
        items: [
          // Populate with 2 default items.
          Item(price: 0.00, quantity: 0.00, unit: unit.baseUnit),
          Item(price: 0.00, quantity: 0.00, unit: unit.baseUnit),
        ],
      ),
    );
  }

  void addItem() {
    final items = List<Item>.from(state.items);
    items.add(
      Item(
        price: 0.00,
        quantity: 0.00,
        unit: state.comareBy.baseUnit,
      ),
    );
    emit(state.copyWith(items: items, result: null));
  }

  void removeItem(String uuid) {
    final items = List<Item>.from(state.items);
    items.removeWhere((element) => element.uuid == uuid);
    emit(state.copyWith(items: items, result: null));
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
    final items = List<Item>.from(state.items);
    final index = items.indexWhere((element) => element.uuid == item.uuid);
    items.removeAt(index);
    items.insert(index, updatedItem);
    emit(state.copyWith(items: items));
  }

  /// Reset the sheet's items to default.
  void reset() => emit(state.copyWith(items: _defaultItems));

  /// Reset the results if user changes values.
  void resetResult() {
    if (state.result.isEmpty) return;
    emit(state.copyWith(result: []));
  }

  void updateShowScrollbar(bool showScrollbar) {
    emit(state.copyWith(alwaysShowScrollbar: showScrollbar));
  }

  /// Toggle show/hide for the side panel that holds
  /// the drawer contents on large screen devices.
  void toggleShowSidePanel() {
    emit(state.copyWith(showSidePanel: !state.showSidePanel));
    _storageService.saveValue(key: 'showSidePanel', value: state.showSidePanel);
  }

  Future<void> addSheet() async {
    final sheets = List<Sheet>.from(state.sheets);
    final newSheet = Sheet();
    sheets.insert(0, newSheet);
    emit(state.copyWith(sheets: sheets, activeSheet: newSheet));
    await _saveSheet(newSheet);
  }

  Future<void> updateSheet(Sheet sheet) async {
    final sheets = List<Sheet>.from(state.sheets);
    final oldSheet = state.sheets.firstWhere((e) => e.uuid == sheet.uuid);
    final index = sheets.indexOf(oldSheet);
    sheets.removeAt(index);
    sheets.insert(index, sheet);
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
  void selectSheet(Sheet sheet) => emit(state.copyWith(activeSheet: sheet));
}
