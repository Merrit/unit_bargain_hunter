import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../storage/storage_service.dart';

part 'demonstration_state.dart';

late final DemonstrationCubit demonstrationCubit;

/// Keeps track of whether or not feature demos have been shown yet.
///
/// Demonstrations show the user how to interact with the app.
///
/// Example: Sheet list uses slidable list tiles on mobile, but this is not
/// obvious if you don't already know about this. Therefore the first time the
/// user opens the drawer the first sheet tile will briefly open then close the
/// slidable to show the user how to access it.
class DemonstrationCubit extends Cubit<DemonstrationState> {
  final StorageService _storageService;

  DemonstrationCubit(
    this._storageService, {
    required DemonstrationState initialState,
  }) : super(initialState) {
    demonstrationCubit = this;
  }

  static Future<DemonstrationCubit> initialize(
    StorageService storageService,
  ) async {
    Future<bool> savedValue(String value) async {
      final bool? retrievedValue = await storageService.getValue(
        value,
        storageArea: 'demonstration',
      );
      return retrievedValue ?? false;
    }

    return DemonstrationCubit(
      storageService,
      initialState: DemonstrationState(
        slidableDemoShown: await savedValue('slidableDemoShown'),
      ),
    );
  }

  Future<void> _saveValue(String key, bool value) async {
    await _storageService.saveValue(
      key: key,
      value: value,
      storageArea: 'demonstration',
    );
  }

  void setSlidableDemoShown() {
    emit(state.copyWith(slidableDemoShown: true));
    _saveValue('slidableDemoShown', true);
  }
}
