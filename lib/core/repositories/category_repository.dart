import 'package:drift/drift.dart';
import '../database/database.dart';

class CategoryRepository {
  final AppDatabase _db;

  CategoryRepository(this._db);

  // Get all categories
  Future<List<Category>> getAllCategories() async {
    return await (_db.select(_db.categories)
          ..orderBy([(c) => OrderingTerm.asc(c.nameAr)]))
        .get();
  }

  // Get category by ID
  Future<Category?> getCategoryById(int id) async {
    return await (_db.select(_db.categories)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  // Search categories
  Future<List<Category>> searchCategories(String query) async {
    final lowerQuery = query.toLowerCase();
    return await (_db.select(_db.categories)
          ..where((c) =>
              c.nameAr.like('%$lowerQuery%') |
              c.nameEn.like('%$lowerQuery%')))
        .get();
  }

  // Create category
  Future<int> createCategory(CategoriesCompanion category) async {
    return await _db.into(_db.categories).insert(category);
  }

  // Update category
  Future<bool> updateCategory(int id, CategoriesCompanion category) async {
    final result = await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(category);
    return result > 0;
  }

  // Delete category
  Future<bool> deleteCategory(int id) async {
    // Check if category is used by any products
    final products = await (_db.select(_db.products)
          ..where((p) => p.categoryId.equals(id))
          ..limit(1))
        .get();
    
    if (products.isNotEmpty) {
      throw Exception('لا يمكن حذف الفئة لأنها مستخدمة في منتجات');
    }
    
    return await (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go() > 0;
  }
}
