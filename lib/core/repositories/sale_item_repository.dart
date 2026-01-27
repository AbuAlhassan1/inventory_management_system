import 'package:drift/drift.dart';
import '../database/database.dart';

class SaleItemRepository {
  final AppDatabase _db;

  SaleItemRepository(this._db);

  // Create sale item
  Future<int> createSaleItem(SaleItemsCompanion saleItem) async {
    return await _db.into(_db.saleItems).insert(saleItem);
  }

  // Get sale items by sale ID
  Future<List<SaleItem>> getSaleItemsBySaleId(int saleId) async {
    return await (_db.select(_db.saleItems)
          ..where((si) => si.saleId.equals(saleId))
          ..orderBy([(si) => OrderingTerm.asc(si.id)]))
        .get();
  }

  // Get sale items with product details
  Future<List<SaleItemWithProduct>> getSaleItemsWithProducts(int saleId) async {
    final query = _db.select(_db.saleItems).join([
      innerJoin(_db.products, _db.products.id.equalsExp(_db.saleItems.productId)),
    ])..where(_db.saleItems.saleId.equals(saleId))
      ..orderBy([OrderingTerm.asc(_db.saleItems.id)]);

    return await query.get().then((rows) {
      return rows.map((row) {
        return SaleItemWithProduct(
          saleItem: row.readTable(_db.saleItems),
          product: row.readTable(_db.products),
        );
      }).toList();
    });
  }

  // Update sale item
  Future<bool> updateSaleItem(int id, SaleItemsCompanion saleItem) async {
    final result = await (_db.update(_db.saleItems)..where((si) => si.id.equals(id))).write(saleItem);
    return result > 0;
  }

  // Delete sale item
  Future<bool> deleteSaleItem(int id) async {
    return await (_db.delete(_db.saleItems)..where((si) => si.id.equals(id))).go() > 0;
  }

  // Delete all sale items for a sale
  Future<bool> deleteSaleItemsBySaleId(int saleId) async {
    return await (_db.delete(_db.saleItems)..where((si) => si.saleId.equals(saleId))).go() > 0;
  }
}

// Helper class for sale items with product details
class SaleItemWithProduct {
  final SaleItem saleItem;
  final Product product;

  SaleItemWithProduct({required this.saleItem, required this.product});
}
