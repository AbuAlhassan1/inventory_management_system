import 'package:drift/drift.dart';
import '../database/database.dart';

class CustomerRepository {
  final AppDatabase _db;

  CustomerRepository(this._db);

  // Create customer
  Future<int> createCustomer(CustomersCompanion customer) async {
    return await _db.into(_db.customers).insert(customer);
  }

  // Get all customers
  Future<List<Customer>> getAllCustomers() async {
    return await (_db.select(_db.customers)
          ..orderBy([(c) => OrderingTerm.asc(c.nameAr)]))
        .get();
  }

  // Get customer by ID
  Future<Customer?> getCustomerById(int id) async {
    return await (_db.select(_db.customers)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  // Search customers
  Future<List<Customer>> searchCustomers(String query) async {
    final lowerQuery = query.toLowerCase();
    return await (_db.select(_db.customers)
          ..where((c) =>
              c.nameAr.like('%$lowerQuery%') |
              c.nameEn.like('%$lowerQuery%') |
              (c.phone.isNotNull() & c.phone.like('%$lowerQuery%'))))
        .get();
  }

  // Update customer
  Future<bool> updateCustomer(int id, CustomersCompanion customer) async {
    final result = await (_db.update(_db.customers)..where((c) => c.id.equals(id))).write(customer);
    return result > 0;
  }

  // Delete customer
  Future<bool> deleteCustomer(int id) async {
    return await (_db.delete(_db.customers)..where((c) => c.id.equals(id))).go() > 0;
  }

  // Update customer debt
  Future<bool> updateCustomerDebt(int customerId, double debtIqd, double debtUsd) async {
    final result = await (_db.update(_db.customers)
          ..where((c) => c.id.equals(customerId)))
        .write(CustomersCompanion(
          totalDebtIqd: Value(debtIqd),
          totalDebtUsd: Value(debtUsd),
          updatedAt: Value(DateTime.now()),
        ));
    return result > 0;
  }

  // Get customers with debt
  Future<List<Customer>> getCustomersWithDebt() async {
    return await (_db.select(_db.customers)
          ..where((c) => c.totalDebtIqd.isBiggerThanValue(0) | c.totalDebtUsd.isBiggerThanValue(0))
          ..orderBy([(c) => OrderingTerm.desc(c.totalDebtIqd)]))
        .get();
  }
}
