import 'package:drift/drift.dart';
import 'categories.dart';

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  TextColumn get nameAr => text()();
  TextColumn get nameEn => text()();
  TextColumn get barcode => text().unique()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  RealColumn get costPriceUsd => real()();
  RealColumn get sellPriceIqd => real()();
  RealColumn get sellPriceUsd => real()();
  IntColumn get quantity => integer().withDefault(const Constant(0))();
  TextColumn get sku => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
