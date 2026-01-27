import 'package:drift/drift.dart';
import 'customers.dart';

class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get customerId => integer().nullable().references(Customers, #id)();
  RealColumn get totalIqd => real()();
  RealColumn get totalUsd => real()();
  RealColumn get receivedAmountIqd => real().nullable()();
  RealColumn get changeGivenIqd => real().nullable()();
  TextColumn get paymentMethod => text()(); // Cash, Card, Debt/Wasl
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
