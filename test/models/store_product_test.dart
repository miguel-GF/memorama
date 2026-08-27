import 'package:flutter_test/flutter_test.dart';
import 'package:memo_granja/models/store_product.dart';

void main() {
  const ocean = StoreProduct.pack(
    productId: 'pack_ocean',
    packId: 'ocean',
  );
  const catalog = StoreCatalog(
    products: [StoreProduct.lifetime(), ocean],
  );

  test('lifetime access grants current and future packs', () {
    final entitlements = EntitlementSnapshot(const [lifetimeProductId]);

    expect(entitlements.hasLifetime, isTrue);
    expect(
      entitlements.canAccessPack('farm', catalog: catalog),
      isTrue,
    );
    expect(
      entitlements.canAccessPack('ocean', catalog: catalog),
      isTrue,
    );
  });

  test('a package entitlement grants only its own pack', () {
    final entitlements = EntitlementSnapshot(const ['pack_ocean']);

    expect(entitlements.canAccessPack('ocean', catalog: catalog), isTrue);
    expect(entitlements.canAccessPack('forest', catalog: catalog), isFalse);
    expect(
      entitlements.canAccessPack('farm', included: true, catalog: catalog),
      isTrue,
    );
  });

  test('unknown cached products never grant content', () {
    final entitlements = EntitlementSnapshot(const ['future_unknown_product']);

    expect(entitlements.hasLifetime, isFalse);
    expect(entitlements.canAccessPack('ocean', catalog: catalog), isFalse);
  });
}
