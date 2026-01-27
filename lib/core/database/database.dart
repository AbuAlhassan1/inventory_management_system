import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables/products.dart';
import 'tables/categories.dart';
import 'tables/exchange_rate.dart';
import 'tables/sales.dart';
import 'tables/sale_items.dart';
import 'tables/customers.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Products, Categories, ExchangeRate, Sales, SaleItems, Customers])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Migration from version 1 to 2: Add Sales, SaleItems, and Customers tables
          // Create Customers table first (no dependencies)
          await m.createTable(customers);
          
          // Create Sales table (depends on Customers)
          await m.createTable(sales);
          
          // Create SaleItems table (depends on Sales and Products)
          await m.createTable(saleItems);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'lips_database.db'));
    return NativeDatabase(file);
  });
}
