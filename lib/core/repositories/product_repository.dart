import 'package:drift/drift.dart';
import '../database/database.dart';

class ProductRepository {
  final AppDatabase _db;

  ProductRepository(this._db);

  // Get all products
  Future<List<Product>> getAllProducts() async {
    return await (_db.select(_db.products)..orderBy([(p) => OrderingTerm.desc(p.createdAt)])).get();
  }

  // Get product by ID
  Future<Product?> getProductById(int id) async {
    return await (_db.select(_db.products)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  // Get product by barcode
  Future<Product?> getProductByBarcode(String barcode) async {
    return await (_db.select(_db.products)..where((p) => p.barcode.equals(barcode))).getSingleOrNull();
  }

  // Search products
  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) {
      return getAllProducts();
    }
    final lowerQuery = query.toLowerCase();
    return await (_db.select(_db.products)
          ..where((p) => 
            p.nameAr.like('%$lowerQuery%') | 
            p.nameEn.like('%$lowerQuery%') |
            p.barcode.like('%$lowerQuery%')))
        .get();
  }

  // Insert product
  Future<int> insertProduct(ProductsCompanion product) async {
    return await _db.into(_db.products).insert(product);
  }

  // Update product
  Future<bool> updateProduct(int id, ProductsCompanion product) async {
    final result = await (_db.update(_db.products)..where((p) => p.id.equals(id))).write(product);
    return result > 0;
  }

  // Delete product
  Future<bool> deleteProduct(int id) async {
    return await (_db.delete(_db.products)..where((p) => p.id.equals(id))).go() > 0;
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(int categoryId) async {
    return await (_db.select(_db.products)
          ..where((p) => p.categoryId.equals(categoryId))
          ..orderBy([(p) => OrderingTerm.asc(p.nameAr)]))
        .get();
  }
}
