import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:memo_granja/models/store_product.dart';
import 'package:memo_granja/services/purchase_service.dart';

void main() {
  const ocean = StoreProduct.pack(
    productId: 'pack_ocean',
    packId: 'ocean',
  );
  const catalog = StoreCatalog(
    products: [StoreProduct.lifetime(), ocean],
  );

  test('restored products become local entitlements and are acknowledged',
      () async {
    final gateway = _FakePurchaseGateway(
      catalog: catalog,
      restoreBatch: [
        const StorePurchaseUpdate(
          productId: lifetimeProductId,
          status: StorePurchaseStatus.restored,
          pendingCompletePurchase: true,
        ),
      ],
    );
    final cache = _MemoryEntitlementCache();
    final service = PurchaseService(
      catalog: catalog,
      gateway: gateway,
      cache: cache,
    );

    await service.initialize();

    expect(service.state, PurchaseState.premium);
    expect(service.hasLifetime, isTrue);
    expect(cache.productIds, contains(lifetimeProductId));
    expect(gateway.completed, hasLength(1));
    service.dispose();
    await gateway.close();
  });

  test('an empty successful restore clears the local entitlement cache',
      () async {
    final gateway = _FakePurchaseGateway(catalog: catalog);
    final cache = _MemoryEntitlementCache({lifetimeProductId});
    final service = PurchaseService(
      catalog: catalog,
      gateway: gateway,
      cache: cache,
    );

    await service.initialize();

    expect(service.state, PurchaseState.free);
    expect(cache.productIds, isEmpty);
    service.dispose();
    await gateway.close();
  });

  test('store unavailability preserves a cached entitlement offline', () async {
    final gateway = _FakePurchaseGateway(catalog: catalog, available: false);
    final service = PurchaseService(
      catalog: catalog,
      gateway: gateway,
      cache: _MemoryEntitlementCache({lifetimeProductId}),
    );

    await service.initialize();

    expect(service.state, PurchaseState.premium);
    expect(service.hasLifetime, isTrue);
    service.dispose();
    await gateway.close();
  });

  test('a pending package never grants access or completes the purchase',
      () async {
    final gateway = _FakePurchaseGateway(catalog: catalog);
    final service = PurchaseService(
      catalog: catalog,
      gateway: gateway,
      cache: _MemoryEntitlementCache(),
    );

    await service.initialize();
    gateway.emit(const [
      StorePurchaseUpdate(
        productId: 'pack_ocean',
        status: StorePurchaseStatus.pending,
        pendingCompletePurchase: true,
      ),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(service.hasAccess, isFalse);
    expect(service.state, PurchaseState.pending);
    expect(gateway.completed, isEmpty);
    service.dispose();
    await gateway.close();
  });

  test('buying a listed package starts a pending store transaction', () async {
    final gateway = _FakePurchaseGateway(catalog: catalog);
    final service = PurchaseService(
      catalog: catalog,
      gateway: gateway,
      cache: _MemoryEntitlementCache(),
    );

    await service.initialize();
    final started = await service.buy(ocean);

    expect(started, isTrue);
    expect(service.state, PurchaseState.pending);
    expect(gateway.boughtProduct?.definition.productId, 'pack_ocean');
    expect(service.hasAccess, isFalse);
    service.dispose();
    await gateway.close();
  });
}

class _MemoryEntitlementCache implements EntitlementCache {
  _MemoryEntitlementCache([Set<String>? initial]) : productIds = {...?initial};

  Set<String> productIds;

  @override
  Future<Set<String>> read() async => {...productIds};

  @override
  Future<void> write(Set<String> next) async {
    productIds = {...next};
  }
}

class _FakePurchaseGateway implements PurchaseGateway {
  _FakePurchaseGateway({
    required this.catalog,
    this.available = true,
    this.restoreBatch = const [],
  });

  final StoreCatalog catalog;
  final bool available;
  final List<StorePurchaseUpdate> restoreBatch;
  final StreamController<List<StorePurchaseUpdate>> _updates =
      StreamController<List<StorePurchaseUpdate>>.broadcast();
  final List<StorePurchaseUpdate> completed = [];
  StoreProductDetails? boughtProduct;

  void emit(List<StorePurchaseUpdate> purchases) => _updates.add(purchases);

  Future<void> close() => _updates.close();

  @override
  Stream<List<StorePurchaseUpdate>> get purchaseUpdates => _updates.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<List<StoreProductDetails>> queryProducts(
      Set<String> productIds) async {
    return catalog.products
        .where((product) => productIds.contains(product.productId))
        .map(
          (product) => StoreProductDetails(
            definition: product,
            title: product.productId,
            description: product.productId,
            price: r'$1.00',
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<bool> buyNonConsumable(StoreProductDetails product) async {
    boughtProduct = product;
    return true;
  }

  @override
  Future<void> restorePurchases() async => _updates.add(restoreBatch);

  @override
  Future<void> completePurchase(StorePurchaseUpdate purchase) async {
    completed.add(purchase);
  }
}
