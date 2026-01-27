import 'package:drift/drift.dart';
import '../database/database.dart';

class ExchangeRateRepository {
  final AppDatabase _db;

  ExchangeRateRepository(this._db);

  // Get current exchange rate
  Future<ExchangeRateData?> getCurrentRate() async {
    return await (_db.select(_db.exchangeRate)
          ..orderBy([(e) => OrderingTerm.desc(e.lastUpdated)])
          ..limit(1))
        .getSingleOrNull();
  }

  // Create or update exchange rate
  Future<int> setExchangeRate(double rateUsdToIqd, {String? source}) async {
    final existing = await getCurrentRate();
    
    if (existing != null) {
      // Update existing rate
      await (_db.update(_db.exchangeRate)
            ..where((e) => e.id.equals(existing.id)))
          .write(ExchangeRateCompanion(
            rateUsdToIqd: Value(rateUsdToIqd),
            lastUpdated: Value(DateTime.now()),
            source: Value(source),
          ));
      return existing.id;
    } else {
      // Create new rate
      return await _db.into(_db.exchangeRate).insert(
            ExchangeRateCompanion(
              rateUsdToIqd: Value(rateUsdToIqd),
              source: Value(source),
            ),
          );
    }
  }

  // Get exchange rate history
  Future<List<ExchangeRateData>> getRateHistory({int limit = 10}) async {
    return await (_db.select(_db.exchangeRate)
          ..orderBy([(e) => OrderingTerm.desc(e.lastUpdated)])
          ..limit(limit))
        .get();
  }
}
