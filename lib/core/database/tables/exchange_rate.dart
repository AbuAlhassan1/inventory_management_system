import 'package:drift/drift.dart';

class ExchangeRate extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get rateUsdToIqd => real()();
  DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime)();
  TextColumn get source => text().nullable()();
}
