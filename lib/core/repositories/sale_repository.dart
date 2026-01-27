import 'package:drift/drift.dart';
import '../database/database.dart';

class SaleRepository {
  final AppDatabase _db;

  SaleRepository(this._db);

  // Create a new sale
  Future<int> createSale(SalesCompanion sale) async {
    return await _db.into(_db.sales).insert(sale);
  }

  // Get sale by ID
  Future<Sale?> getSaleById(int id) async {
    return await (_db.select(_db.sales)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  // Get all sales
  Future<List<Sale>> getAllSales() async {
    return await (_db.select(_db.sales)
          ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
        .get();
  }

  // Get sales by date range
  Future<List<Sale>> getSalesByDateRange(DateTime start, DateTime end) async {
    return await (_db.select(_db.sales)
          ..where((s) => s.createdAt.isBetweenValues(start, end))
          ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
        .get();
  }

  // Get sales by customer
  Future<List<Sale>> getSalesByCustomer(int customerId) async {
    return await (_db.select(_db.sales)
          ..where((s) => s.customerId.equals(customerId))
          ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
        .get();
  }

  // Update sale
  Future<bool> updateSale(int id, SalesCompanion sale) async {
    final result = await (_db.update(_db.sales)..where((s) => s.id.equals(id))).write(sale);
    return result > 0;
  }

  // Delete sale
  Future<bool> deleteSale(int id) async {
    return await (_db.delete(_db.sales)..where((s) => s.id.equals(id))).go() > 0;
  }
}
