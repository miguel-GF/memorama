enum StoreProductKind { lifetime, contentPack }

/// Stable product metadata owned by the app, not by localized store copy.
class StoreProduct {
  const StoreProduct({
    required this.productId,
    required this.kind,
    this.packId,
  }) : assert(
          (kind == StoreProductKind.lifetime && packId == null) ||
              (kind == StoreProductKind.contentPack && packId != null),
        );

  const StoreProduct.lifetime()
      : productId = lifetimeProductId,
        kind = StoreProductKind.lifetime,
        packId = null;

  const StoreProduct.pack({required String productId, required String packId})
      : productId = productId,
        kind = StoreProductKind.contentPack,
        packId = packId;

  final String productId;
  final StoreProductKind kind;
  final String? packId;

  bool grantsPack(String requestedPackId) {
    return kind == StoreProductKind.lifetime || packId == requestedPackId;
  }
}

const String lifetimeProductId = 'full_access_lifetime';

/// The app-owned catalog. Store prices and localized names come from Google
/// Play; they must not be hard-coded here.
class StoreCatalog {
  const StoreCatalog({required this.products});

  const StoreCatalog.defaultCatalog()
      : products = const [StoreProduct.lifetime()];

  final List<StoreProduct> products;

  Set<String> get productIds =>
      products.map((product) => product.productId).toSet();

  StoreProduct? find(String productId) {
    for (final product in products) {
      if (product.productId == productId) return product;
    }
    return null;
  }

  static String packageProductId(String packId) => 'pack_$packId';
}

class EntitlementSnapshot {
  EntitlementSnapshot(Iterable<String> productIds)
      : productIds = Set.unmodifiable(
          productIds.where((productId) => productId.trim().isNotEmpty),
        );

  final Set<String> productIds;

  bool owns(String productId) => productIds.contains(productId);

  bool get hasLifetime => owns(lifetimeProductId);

  bool canAccessPack(String packId,
      {bool included = false, StoreCatalog? catalog}) {
    if (included || hasLifetime) return true;
    final products = catalog ?? const StoreCatalog.defaultCatalog();
    return productIds.any((productId) {
      final product = products.find(productId);
      return product?.grantsPack(packId) ?? false;
    });
  }
}
