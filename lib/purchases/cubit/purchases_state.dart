part of 'purchases_cubit.dart';

class PurchasesState extends Equatable {
  final bool purchaseServiceIsAvailable;
  final bool installedFromPlayStore;
  final List<String> notFoundIds;
  final List<ProductDetails> products;
  final List<PurchaseDetails> purchases;
  final String? queryProductError;
  final String? purchaseError;

  /// Purchase is considered pending if the user attempted to make a
  /// purchase, but had a slow reponse from their payment method.
  ///
  /// The purchase is considered tentatively successful until the
  /// payment method clears, then is considered permanently successful.
  final bool purchasePending;

  final bool proPurchased;

  const PurchasesState({
    required this.purchaseServiceIsAvailable,
    required this.installedFromPlayStore,
    required this.notFoundIds,
    required this.products,
    required this.purchases,
    this.queryProductError,
    this.purchaseError,
    required this.purchasePending,
    required this.proPurchased,
  });

  const PurchasesState.initial()
      : purchaseServiceIsAvailable = false,
        installedFromPlayStore = false,
        notFoundIds = const [],
        products = const [],
        purchases = const [],
        queryProductError = null,
        purchaseError = null,
        purchasePending = false,
        proPurchased = false;

  PurchasesState copyWith({
    bool? purchaseServiceIsAvailable,
    bool? installedFromPlayStore,
    List<String>? notFoundIds,
    List<ProductDetails>? products,
    List<PurchaseDetails>? purchases,
    String? queryProductError,
    String? purchaseError,
    bool? purchasePending,
    bool? proPurchased,
  }) {
    return PurchasesState(
      purchaseServiceIsAvailable:
          purchaseServiceIsAvailable ?? this.purchaseServiceIsAvailable,
      installedFromPlayStore:
          installedFromPlayStore ?? this.installedFromPlayStore,
      notFoundIds: notFoundIds ?? this.notFoundIds,
      products: products ?? this.products,
      purchases: purchases ?? this.purchases,
      queryProductError: queryProductError ?? this.queryProductError,
      purchaseError: purchaseError ?? this.purchaseError,
      purchasePending: purchasePending ?? this.purchasePending,
      proPurchased: proPurchased ?? this.proPurchased,
    );
  }

  @override
  List<Object?> get props {
    return [
      purchaseServiceIsAvailable,
      installedFromPlayStore,
      notFoundIds,
      products,
      purchases,
      queryProductError,
      purchaseError,
      purchasePending,
      proPurchased,
    ];
  }
}
