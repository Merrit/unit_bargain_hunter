import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:store_checker/store_checker.dart';

import '../../logs/logs.dart';
import '../../platform/platform.dart';
import '../../storage/storage_service.dart';

part 'purchases_state.dart';

/// The id for the pro unlock product in the app store.
const String kProUnlockId = 'pro_unlock';

const List<String> _kProductIds = [
  kProUnlockId,
];

/// Keep track of the in-app purchases on Android.
class PurchasesCubit extends Cubit<PurchasesState> {
  InAppPurchase? _purchaseService;
  late final StreamSubscription<List<PurchaseDetails>> _subscription;
  final StorageService _storageService;

  PurchasesCubit._(
    this._purchaseService,
    this._storageService, {
    required PurchasesState initialState,
  }) : super(initialState);

  static Future<PurchasesCubit> initialize({
    InAppPurchase? purchaseService,
    StorageService? storageService,
  }) async {
    final cubit = PurchasesCubit._(
      purchaseService,
      storageService ?? StorageService.instance!,
      initialState: const PurchasesState.initial(),
    );

    await cubit._setup();

    return cubit;
  }

  Future<void> _setup() async {
    if (!Platform.isAndroid) {
      _enableForNonIAPPlatforms();
      return;
    }

    if (!await _installedFromPlayStore()) {
      _enableForNonIAPPlatforms();
      return;
    }
    emit(state.copyWith(installedFromPlayStore: true));

    _purchaseService ??= InAppPurchase.instance;

    _subscription = _purchaseService!.purchaseStream.listen(
      (details) => _handlePurchaseUpdate(details),
      onDone: () => _subscription.cancel(),
      onError: (error) {
        log.w('Error listening for InAppPurchase updates: $error');
      },
    );

    await _initStoreInfo();
    await _checkForSavedProPurchase();
  }

  /// For platforms other than Android that don't use the in app purchase
  /// model, the pro features are always enabled.
  void _enableForNonIAPPlatforms() => emit(state.copyWith(proPurchased: true));

  /// If installed from somewhere other than the Play Store,
  /// for example the APK from GitHub releases, in app purchases are not
  /// supported and the pro features will be available by default.
  static Future<bool> _installedFromPlayStore() async {
    if (kDebugMode) return true;

    final Source installationSource = await StoreChecker.getSource;

    return (installationSource == Source.IS_INSTALLED_FROM_PLAY_STORE)
        ? true
        : false;
  }

  Future<void> _initStoreInfo() async {
    final bool isAvailable = await _purchaseService!.isAvailable();
    if (!isAvailable) return;

    final ProductDetailsResponse productDetailsResponse =
        await _purchaseService!.queryProductDetails(_kProductIds.toSet());

    _restorePurchases();

    emit(state.copyWith(
      notFoundIds: productDetailsResponse.notFoundIDs,
      products: productDetailsResponse.productDetails,
      purchaseServiceIsAvailable: isAvailable,
      queryProductError: productDetailsResponse.error?.message,
    ));
  }

  Future<void> _handlePurchaseUpdate(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        /// Mark as purchased for now, without saving to storage.
        /// If the purchase was actually successful, on next run
        /// `_restorePurchases()` will be run and it will be
        /// persisted to local storage at that time.
        emit(state.copyWith(proPurchased: true));
        return;
      }

      if (purchaseDetails.status == PurchaseStatus.error) {
        _handleError(purchaseDetails.error!);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        _deliverProduct(purchaseDetails);
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _purchaseService!.completePurchase(purchaseDetails);
      }
    }
  }

  void _handleError(IAPError error) {
    if (error.message == 'BillingResponse.itemAlreadyOwned') {
      _restorePurchases();
    } else {
      log.w('IAPError message: ${error.message}');
      emit(state.copyWith(purchaseError: error.message));
      emit(state.copyWith(purchaseError: null));
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.productID == kProUnlockId) {
      await _savePurchaseInfo(purchaseDetails);
      emit(state.copyWith(proPurchased: true));
    }
  }

  Future<void> _savePurchaseInfo(PurchaseDetails purchaseDetails) async {
    await _storageService.saveValue(
      key: purchaseDetails.productID,
      value: purchaseDetails.purchaseID,
    );
  }

  Future<void> _checkForSavedProPurchase() async {
    final savedProPurchaseId = await _storageService //
        .getValue(kProUnlockId) as String?;
    if (savedProPurchaseId == null) return;

    // If the service is not available, we go by the saved value alone.
    if (!state.purchaseServiceIsAvailable) {
      emit(state.copyWith(proPurchased: true));
      return;
    }

    final bool valid = await _savedPurchaseIdValid(savedProPurchaseId);
    if (!valid) await _storageService.deleteValue(kProUnlockId);
    emit(state.copyWith(proPurchased: valid));
  }

  /// Verify the saved purchase is valid by comparing with the app store.
  Future<bool> _savedPurchaseIdValid(String savedPurchaseId) async {
    if (Platform.isAndroid) {
      final platformAddition = _purchaseService!
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final response = await platformAddition.queryPastPurchases();
      final bool savedIdMatchesServer = response //
          .pastPurchases
          .where((element) => element.purchaseID == savedPurchaseId)
          .isNotEmpty;
      return savedIdMatchesServer;
    } else {
      return false;
    }
  }

  Future<void> purchasePro() async {
    await _purchaseService!.buyNonConsumable(
      purchaseParam: PurchaseParam(
        productDetails: state //
            .products
            .singleWhere((element) => element.id == kProUnlockId),
      ),
    );
  }

  Future<void> _restorePurchases() async {
    await _purchaseService!.restorePurchases();
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
