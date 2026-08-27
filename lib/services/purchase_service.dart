import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:memo_granja/models/store_product.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum StorePurchaseStatus { purchased, restored, pending, canceled, error }

class StorePurchaseUpdate {
  const StorePurchaseUpdate({
    required this.productId,
    required this.status,
    this.pendingCompletePurchase = false,
    this.platformPurchase,
  });

  final String productId;
  final StorePurchaseStatus status;
  final bool pendingCompletePurchase;
  final Object? platformPurchase;
}

class StoreProductDetails {
  const StoreProductDetails({
    required this.definition,
    required this.title,
    required this.description,
    required this.price,
    this.platformProduct,
  });

  final StoreProduct definition;
  final String title;
  final String description;
  final String price;
  final Object? platformProduct;
}

abstract interface class PurchaseGateway {
  Stream<List<StorePurchaseUpdate>> get purchaseUpdates;

  Future<bool> isAvailable();

  Future<List<StoreProductDetails>> queryProducts(Set<String> productIds);

  Future<bool> buyNonConsumable(StoreProductDetails product);

  Future<void> restorePurchases();

  Future<void> completePurchase(StorePurchaseUpdate purchase);
}

class InAppPurchaseGateway implements PurchaseGateway {
  InAppPurchaseGateway({required StoreCatalog catalog, InAppPurchase? billing})
      : _catalog = catalog,
        _billing = billing ?? InAppPurchase.instance;

  final StoreCatalog _catalog;
  final InAppPurchase _billing;

  @override
  Stream<List<StorePurchaseUpdate>> get purchaseUpdates {
    return _billing.purchaseStream.map(
      (purchases) => purchases.map(_mapPurchase).toList(growable: false),
    );
  }

  @override
  Future<bool> isAvailable() => _billing.isAvailable();

  @override
  Future<List<StoreProductDetails>> queryProducts(
      Set<String> productIds) async {
    final response = await _billing.queryProductDetails(productIds);
    if (response.error != null) return const [];
    return response.productDetails
        .map((product) {
          final definition = _catalog.find(product.id);
          if (definition == null) return null;
          return StoreProductDetails(
            definition: definition,
            title: product.title,
            description: product.description,
            price: product.price,
            platformProduct: product,
          );
        })
        .whereType<StoreProductDetails>()
        .toList(growable: false);
  }

  @override
  Future<bool> buyNonConsumable(StoreProductDetails product) {
    final platformProduct = product.platformProduct;
    if (platformProduct is! ProductDetails) return Future.value(false);
    return _billing.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: platformProduct),
    );
  }

  @override
  Future<void> restorePurchases() => _billing.restorePurchases();

  @override
  Future<void> completePurchase(StorePurchaseUpdate purchase) async {
    final platformPurchase = purchase.platformPurchase;
    if (platformPurchase is PurchaseDetails) {
      await _billing.completePurchase(platformPurchase);
    }
  }

  StorePurchaseUpdate _mapPurchase(PurchaseDetails purchase) {
    return StorePurchaseUpdate(
      productId: purchase.productID,
      status: switch (purchase.status) {
        PurchaseStatus.purchased => StorePurchaseStatus.purchased,
        PurchaseStatus.restored => StorePurchaseStatus.restored,
        PurchaseStatus.pending => StorePurchaseStatus.pending,
        PurchaseStatus.canceled => StorePurchaseStatus.canceled,
        PurchaseStatus.error => StorePurchaseStatus.error,
      },
      pendingCompletePurchase: purchase.pendingCompletePurchase,
      platformPurchase: purchase,
    );
  }
}

abstract interface class EntitlementCache {
  Future<Set<String>> read();

  Future<void> write(Set<String> productIds);
}

class SharedPreferencesEntitlementCache implements EntitlementCache {
  const SharedPreferencesEntitlementCache();

  static const key = 'memo_granja_entitlements_v1';

  @override
  Future<Set<String>> read() async {
    final preferences = await SharedPreferences.getInstance();
    return (preferences.getStringList(key) ?? const []).toSet();
  }

  @override
  Future<void> write(Set<String> productIds) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(key, productIds.toList()..sort());
  }
}

enum PurchaseVerificationStatus {
  valid,
  pending,
  canceled,
  invalid,
  unavailable,
}

abstract interface class PurchaseVerifier {
  Future<PurchaseVerificationStatus> verify(StorePurchaseUpdate purchase);
}

class LocalPurchaseVerifier implements PurchaseVerifier {
  LocalPurchaseVerifier({required StoreCatalog catalog}) : _catalog = catalog;

  final StoreCatalog _catalog;

  @override
  Future<PurchaseVerificationStatus> verify(
      StorePurchaseUpdate purchase) async {
    if (_catalog.find(purchase.productId) == null) {
      return PurchaseVerificationStatus.invalid;
    }
    return switch (purchase.status) {
      StorePurchaseStatus.purchased ||
      StorePurchaseStatus.restored =>
        PurchaseVerificationStatus.valid,
      StorePurchaseStatus.pending => PurchaseVerificationStatus.pending,
      StorePurchaseStatus.canceled => PurchaseVerificationStatus.canceled,
      StorePurchaseStatus.error => PurchaseVerificationStatus.unavailable,
    };
  }
}

enum PurchaseState { loading, free, premium, pending, unavailable, error }

class PurchaseService extends ChangeNotifier {
  PurchaseService({
    StoreCatalog? catalog,
    PurchaseGateway? gateway,
    EntitlementCache? cache,
    PurchaseVerifier? verifier,
  })  : _catalog = catalog ?? const StoreCatalog.defaultCatalog(),
        _gateway = gateway ??
            InAppPurchaseGateway(
              catalog: catalog ?? const StoreCatalog.defaultCatalog(),
            ),
        _cache = cache ?? const SharedPreferencesEntitlementCache(),
        _verifier = verifier ??
            LocalPurchaseVerifier(
              catalog: catalog ?? const StoreCatalog.defaultCatalog(),
            );

  static final PurchaseService instance = PurchaseService();

  final StoreCatalog _catalog;
  final PurchaseGateway _gateway;
  final EntitlementCache _cache;
  final PurchaseVerifier _verifier;

  PurchaseState _state = PurchaseState.loading;
  Set<String> _ownedProductIds = <String>{};
  List<StoreProductDetails> _products = <StoreProductDetails>[];
  StreamSubscription<List<StorePurchaseUpdate>>? _subscription;
  Timer? _restoreTimer;
  Completer<void>? _restoreCompleter;
  bool _initialized = false;
  bool _disposed = false;
  bool _restoreInProgress = false;
  bool _restoreSawBatch = false;
  bool _restoreSawActive = false;
  bool _restoreSawPending = false;

  PurchaseState get state => _state;
  bool get hasAccess =>
      _ownedProductIds.any((productId) => _catalog.find(productId) != null);
  bool get hasLifetime => _ownedProductIds.contains(lifetimeProductId);
  Set<String> get ownedProductIds => Set.unmodifiable(_ownedProductIds);
  List<StoreProductDetails> get products => List.unmodifiable(_products);

  bool canAccessPack(String packId, {bool included = false}) {
    return EntitlementSnapshot(_ownedProductIds).canAccessPack(
      packId,
      included: included,
      catalog: _catalog,
    );
  }

  Future<void> initialize() async {
    if (_initialized || _disposed) return;
    _initialized = true;
    try {
      _ownedProductIds = await _cache.read();
      if (hasAccess) _setState(PurchaseState.premium);
    } on Object {
      _ownedProductIds = <String>{};
    }
    if (_disposed) return;
    _subscription = _gateway.purchaseUpdates.listen(
      _handlePurchases,
      onError: (_) {
        if (!hasAccess) _setState(PurchaseState.error);
      },
    );
    await refreshStore();
  }

  Future<void> refreshStore({bool restorePurchases = true}) async {
    if (_disposed) return;
    final wasAvailable = hasAccess;
    if (!wasAvailable) _setState(PurchaseState.loading);
    try {
      if (!await _gateway.isAvailable()) {
        if (!wasAvailable) _setState(PurchaseState.unavailable);
        return;
      }
      _products = await _gateway.queryProducts(_catalog.productIds);
      if (_products.isEmpty) {
        if (!wasAvailable) _setState(PurchaseState.unavailable);
        return;
      }
      if (!wasAvailable) _setState(PurchaseState.free);
      if (restorePurchases) await restore();
    } on Object {
      if (!wasAvailable) _setState(PurchaseState.error);
    }
  }

  Future<bool> buy(StoreProduct product) async {
    if (_disposed) return false;
    final details = _products.cast<StoreProductDetails?>().firstWhere(
          (item) => item?.definition.productId == product.productId,
          orElse: () => null,
        );
    if (details == null) return false;
    final started = await _gateway.buyNonConsumable(details);
    if (started) _setState(PurchaseState.pending);
    return started;
  }

  Future<void> restore() async {
    if (_disposed || _restoreInProgress) return;
    final wasAvailable = hasAccess;
    _restoreInProgress = true;
    _restoreSawBatch = false;
    _restoreSawActive = false;
    _restoreSawPending = false;
    if (!wasAvailable) _setState(PurchaseState.loading);
    try {
      await _gateway.restorePurchases();
      await _waitForRestoreBatch();
      if (_restoreSawBatch && !_restoreSawActive && !_restoreSawPending) {
        await _replaceOwned(<String>{});
      }
      if (!hasAccess) _setState(PurchaseState.free);
    } on Object {
      if (!wasAvailable) _setState(PurchaseState.error);
    } finally {
      _restoreInProgress = false;
    }
  }

  Future<void> _handlePurchases(List<StorePurchaseUpdate> purchases) async {
    if (_disposed) return;
    if (_restoreInProgress) _restoreSawBatch = true;
    for (final purchase in purchases) {
      if (_catalog.find(purchase.productId) == null) continue;
      if (_restoreInProgress &&
          purchase.status == StorePurchaseStatus.pending) {
        _restoreSawPending = true;
      }
      final verification = await _verifier.verify(purchase);
      if (_disposed) return;
      switch (verification) {
        case PurchaseVerificationStatus.valid:
          if (_restoreInProgress) _restoreSawActive = true;
          await _addOwned(purchase.productId);
          _setState(PurchaseState.premium);
        case PurchaseVerificationStatus.pending:
          _setState(PurchaseState.pending);
        case PurchaseVerificationStatus.canceled:
          if (!hasAccess) _setState(PurchaseState.free);
        case PurchaseVerificationStatus.invalid:
          await _removeOwned(purchase.productId);
          if (!hasAccess) _setState(PurchaseState.error);
        case PurchaseVerificationStatus.unavailable:
          if (!hasAccess) _setState(PurchaseState.error);
      }
      if (verification == PurchaseVerificationStatus.valid &&
          purchase.pendingCompletePurchase) {
        await _gateway.completePurchase(purchase);
      }
    }
  }

  Future<void> _addOwned(String productId) async {
    if (_ownedProductIds.contains(productId)) return;
    await _replaceOwned({..._ownedProductIds, productId});
  }

  Future<void> _removeOwned(String productId) async {
    if (!_ownedProductIds.contains(productId)) return;
    final next = {..._ownedProductIds}..remove(productId);
    await _replaceOwned(next);
  }

  Future<void> _replaceOwned(Set<String> productIds) async {
    _ownedProductIds = productIds;
    await _cache.write(productIds);
  }

  Future<void> _waitForRestoreBatch() {
    final completer = Completer<void>();
    _restoreCompleter = completer;
    _restoreTimer = Timer(const Duration(milliseconds: 350), () {
      if (!completer.isCompleted) completer.complete();
    });
    return completer.future;
  }

  void _setState(PurchaseState next) {
    if (_disposed || _state == next) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    _restoreTimer?.cancel();
    if (!(_restoreCompleter?.isCompleted ?? true)) {
      _restoreCompleter!.complete();
    }
    super.dispose();
  }
}
