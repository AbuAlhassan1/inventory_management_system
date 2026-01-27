import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../core/repositories/product_repository.dart';
import '../core/repositories/sale_repository.dart';
import '../core/repositories/customer_repository.dart';
import '../core/database/database.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _dashboardData = _fetchDashboardData();
    });
  }

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    final productRepo = RepositoryProvider.of<ProductRepository>(context);
    final saleRepo = RepositoryProvider.of<SaleRepository>(context);
    final customerRepo = RepositoryProvider.of<CustomerRepository>(context);

    final products = await productRepo.getAllProducts();
    final lowStockProducts = products.where((p) => p.quantity < 10).toList();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final monthStart = DateTime(now.year, now.month, 1);

    final todaySales = await saleRepo.getSalesByDateRange(todayStart, now);
    final monthSales = await saleRepo.getSalesByDateRange(monthStart, now);

    final customersWithDebt = await customerRepo.getCustomersWithDebt();

    double todayRevenueIqd = 0;
    double todayRevenueUsd = 0;
    double monthRevenueIqd = 0;
    double monthRevenueUsd = 0;
    double totalDebtIqd = 0;
    double totalDebtUsd = 0;

    for (final sale in todaySales) {
      todayRevenueIqd += sale.totalIqd;
      todayRevenueUsd += sale.totalUsd;
    }

    for (final sale in monthSales) {
      monthRevenueIqd += sale.totalIqd;
      monthRevenueUsd += sale.totalUsd;
    }

    for (final customer in customersWithDebt) {
      totalDebtIqd += customer.totalDebtIqd;
      totalDebtUsd += customer.totalDebtUsd;
    }

    return {
      'totalProducts': products.length,
      'lowStockCount': lowStockProducts.length,
      'lowStockProducts': lowStockProducts,
      'todayRevenueIqd': todayRevenueIqd,
      'todayRevenueUsd': todayRevenueUsd,
      'monthRevenueIqd': monthRevenueIqd,
      'monthRevenueUsd': monthRevenueUsd,
      'todaySalesCount': todaySales.length,
      'monthSalesCount': monthSales.length,
      'totalDebtIqd': totalDebtIqd,
      'totalDebtUsd': totalDebtUsd,
      'customersWithDebt': customersWithDebt.length,
      'recentSales': todaySales.take(5).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: 'د.ع', decimalDigits: 0);
    final usdFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return FutureBuilder<Map<String, dynamic>>(
      future: _dashboardData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'حدث خطأ في تحميل البيانات',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadDashboardData,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'لوحة التحكم',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),

              // Statistics cards
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _StatCard(
                    title: 'إجمالي المنتجات',
                    value: '${data['totalProducts']}',
                    icon: Icons.inventory_2,
                    color: Colors.blue,
                  ),
                  _StatCard(
                    title: 'منتجات قليلة المخزون',
                    value: '${data['lowStockCount']}',
                    icon: Icons.warning,
                    color: Colors.orange,
                  ),
                  _StatCard(
                    title: 'مبيعات اليوم',
                    value: '${data['todaySalesCount']}',
                    icon: Icons.shopping_cart,
                    color: Colors.green,
                  ),
                  _StatCard(
                    title: 'إيرادات اليوم',
                    value: currencyFormat.format(data['todayRevenueIqd']),
                    icon: Icons.attach_money,
                    color: Colors.teal,
                    subtitle: usdFormat.format(data['todayRevenueUsd']),
                  ),
                  _StatCard(
                    title: 'مبيعات الشهر',
                    value: '${data['monthSalesCount']}',
                    icon: Icons.calendar_month,
                    color: Colors.purple,
                  ),
                  _StatCard(
                    title: 'إيرادات الشهر',
                    value: currencyFormat.format(data['monthRevenueIqd']),
                    icon: Icons.trending_up,
                    color: Colors.indigo,
                    subtitle: usdFormat.format(data['monthRevenueUsd']),
                  ),
                  _StatCard(
                    title: 'إجمالي الديون',
                    value: currencyFormat.format(data['totalDebtIqd']),
                    icon: Icons.account_balance_wallet,
                    color: Colors.red,
                    subtitle: usdFormat.format(data['totalDebtUsd']),
                  ),
                  _StatCard(
                    title: 'عملاء مدينون',
                    value: '${data['customersWithDebt']}',
                    icon: Icons.people,
                    color: Colors.pink,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Low stock alert
              if (data['lowStockCount'] > 0) ...[
                Card(
                  color: Colors.orange.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'تنبيه: منتجات قليلة المخزون',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...(data['lowStockProducts'] as List<Product>).take(5).map((product) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.inventory_2_outlined),
                            title: Text(product.nameAr),
                            trailing: Text(
                              'الكمية: ${product.quantity}',
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Recent sales
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المبيعات الأخيرة',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      if ((data['recentSales'] as List<Sale>).isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'لا توجد مبيعات اليوم',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                        )
                      else
                        ...(data['recentSales'] as List<Sale>).map((sale) {
                          return ListTile(
                            leading: const Icon(Icons.receipt),
                            title: Text('فاتورة #${sale.id}'),
                            subtitle: Text(
                              DateFormat('yyyy-MM-dd HH:mm').format(sale.createdAt),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currencyFormat.format(sale.totalIqd),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  usdFormat.format(sale.totalUsd),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 250,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
