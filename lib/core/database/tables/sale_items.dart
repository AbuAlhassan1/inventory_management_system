import 'package:drift/drift.dart';
import 'products.dart';
import 'sales.dart';

class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer().references(Sales, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get quantity => integer()();
  RealColumn get priceAtSaleIqd => real()();
  RealColumn get priceAtSaleUsd => real()();
  RealColumn get subtotalIqd => real()();
  RealColumn get subtotalUsd => real()();
}
