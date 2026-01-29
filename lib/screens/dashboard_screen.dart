import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/repositories/product_repository.dart';
import '../core/repositories/sale_repository.dart';
import '../core/repositories/customer_repository.dart';
import '../core/database/database.dart';
import '../core/theme/app_theme.dart';
import '../widgets/ui_components/kpi_card.dart';
import '../widgets/ui_components/app_button.dart';

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
    double totalInventoryValue = 0;

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

    // Calculate total inventory value
    for (final product in products) {
      totalInventoryValue += product.sellPriceIqd * product.quantity;
    }

    // Calculate return rate (mock data for now)
    final returnRate = 1.8;
    final previousReturnRate = 2.2;

    // Calculate on-time delivery (mock data)
    final onTimeDelivery = 98.2;

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
      'totalInventoryValue': totalInventoryValue,
      'returnRate': returnRate,
      'previousReturnRate': previousReturnRate,
      'onTimeDelivery': onTimeDelivery,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: 'د.ع', decimalDigits: 0);

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
                AppButton(
                  label: 'إعادة المحاولة',
                  onPressed: _loadDashboardData,
                ),
              ],
            ),
          );
        }

        final data = snapshot.data!;
        final lowStockCount = data['lowStockCount'] as int;
        final lowStockProducts = data['lowStockProducts'] as List<Product>;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.help_outline, color: AppTheme.textSecondary, size: 20),
                  const SizedBox(width: 8),
                  Icon(Icons.notifications_outlined, color: AppTheme.textSecondary, size: 20),
                  const Spacer(),
                  SizedBox(
                    width: 400,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'بحث عن صنف، رقم طلب...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: AppTheme.darkSurfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'نظام المخزون',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        'المؤسسة v2.4',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.list, color: AppTheme.textSecondary),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'الرئيسية > لوحة القيادة',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // KPI Cards Row
              Row(
                children: [
                  // Low Stock Alert Card
                  Expanded(
                    flex: 2,
                    child: Card(
                      color: AppTheme.warningOrange.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: AppTheme.warningOrange,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'تنبيه انخفاض المخزون',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'يوجد $lowStockCount صنف حالياً تحت مستويات الأمان. أعد الطلب فوراً لتجنب تعطل سلسلة التوريد',
                              style: theme.textTheme.bodyMedium,
                            ),
                            if (lowStockProducts.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: lowStockProducts.take(2).map((product) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.warningOrange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      product.sku ?? product.barcode,
                                      style: TextStyle(
                                        color: AppTheme.warningOrange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                            const SizedBox(height: 16),
                            AppButton(
                              label: 'عرض الأصناف المنخفضة',
                              type: ButtonType.primary,
                              icon: Icons.arrow_back,
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Return Rate Card
                  Expanded(
                    child: KPICard(
                      title: 'معدل المرتجعات',
                      value: '${data['returnRate']}%',
                      subtitle: 'انخفاض ${((data['previousReturnRate'] as double) - (data['returnRate'] as double)).toStringAsFixed(1)}% عن الشهر الماضي',
                      icon: Icons.trending_down,
                      iconColor: AppTheme.successGreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // On-time Delivery Card
                  Expanded(
                    child: KPICard(
                      title: 'التسليم في الموعد',
                      value: '${data['onTimeDelivery']}%',
                      subtitle: 'النظام يعمل بكفاءة عالية',
                      icon: Icons.check_circle,
                      iconColor: AppTheme.successGreen,
                      trailing: AppButton(
                        label: 'تحقق الهدف',
                        type: ButtonType.transparent,
                        onPressed: () {},
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Active Orders Card
                  Expanded(
                    child: KPICard(
                      title: 'الطلبات النشطة',
                      value: '${data['todaySalesCount']}',
                      subtitle: 'آخر 24 ساعة',
                      icon: Icons.shopping_cart,
                      iconColor: AppTheme.primaryTeal,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Total Inventory Value Card
                  Expanded(
                    child: KPICard(
                      title: 'إجمالي قيمة المخزون',
                      value: currencyFormat.format(data['totalInventoryValue']),
                      subtitle: '+2.4%',
                      icon: Icons.inventory_2,
                      iconColor: AppTheme.primaryTeal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Charts Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Inventory Turnover Rate Chart
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'معدل دوران المخزون',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'حسب موقع المستودع',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 300,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: 100,
                                  barTouchData: BarTouchData(enabled: false),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final labels = ['م-01', 'م-02', 'م-03', 'م-04', 'م-05'];
                                          if (value.toInt() >= 0 && value.toInt() < labels.length) {
                                            return Text(
                                              labels[value.toInt()],
                                              style: TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 12,
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  gridData: FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                  barGroups: [
                                    BarChartGroupData(
                                      x: 0,
                                      barRods: [
                                        BarChartRodData(
                                          toY: 45,
                                          color: AppTheme.darkSurfaceVariant,
                                          width: 20,
                                        ),
                                        BarChartRodData(
                                          toY: 60,
                                          color: AppTheme.primaryTeal,
                                          width: 20,
                                        ),
                                      ],
                                    ),
                                    BarChartGroupData(
                                      x: 1,
                                      barRods: [
                                        BarChartRodData(
                                          toY: 55,
                                          color: AppTheme.darkSurfaceVariant,
                                          width: 20,
                                        ),
                                        BarChartRodData(
                                          toY: 70,
                                          color: AppTheme.primaryTeal,
                                          width: 20,
                                        ),
                                      ],
                                    ),
                                    BarChartGroupData(
                                      x: 2,
                                      barRods: [
                                        BarChartRodData(
                                          toY: 40,
                                          color: AppTheme.darkSurfaceVariant,
                                          width: 20,
                                        ),
                                        BarChartRodData(
                                          toY: 50,
                                          color: AppTheme.primaryTeal,
                                          width: 20,
                                        ),
                                      ],
                                    ),
                                    BarChartGroupData(
                                      x: 3,
                                      barRods: [
                                        BarChartRodData(
                                          toY: 50,
                                          color: AppTheme.darkSurfaceVariant,
                                          width: 20,
                                        ),
                                        BarChartRodData(
                                          toY: 65,
                                          color: AppTheme.primaryTeal,
                                          width: 20,
                                        ),
                                      ],
                                    ),
                                    BarChartGroupData(
                                      x: 4,
                                      barRods: [
                                        BarChartRodData(
                                          toY: 60,
                                          color: AppTheme.darkSurfaceVariant,
                                          width: 20,
                                        ),
                                        BarChartRodData(
                                          toY: 75,
                                          color: AppTheme.primaryTeal,
                                          width: 20,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _LegendItem(
                                  color: AppTheme.darkSurfaceVariant,
                                  label: 'وارد',
                                ),
                                const SizedBox(width: 24),
                                _LegendItem(
                                  color: AppTheme.primaryTeal,
                                  label: 'صادر',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Inventory Value Trends Chart
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'اتجاهات قيمة المخزون',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'آخر 6 أشهر (د.ع)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 300,
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 1000000,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: AppTheme.darkSurfaceVariant,
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final labels = ['شباط', 'آذار', 'نيسان', 'أيار', 'حزيران'];
                                          if (value.toInt() >= 0 && value.toInt() < labels.length) {
                                            return Text(
                                              labels[value.toInt()],
                                              style: TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 12,
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: [
                                        const FlSpot(0, 3.5),
                                        const FlSpot(1, 3.8),
                                        const FlSpot(2, 4.0),
                                        const FlSpot(3, 4.2),
                                        const FlSpot(4, 4.1),
                                        const FlSpot(5, 4.285),
                                      ],
                                      isCurved: true,
                                      color: AppTheme.primaryTeal,
                                      barWidth: 3,
                                      dotData: FlDotData(show: false),
                                      belowBarData: BarAreaData(show: false),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Shipments Table
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الشحنات الأخيرة',
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'مراقبة الواردات والصادرات المباشرة',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              AppButton(
                                label: 'تصفية',
                                type: ButtonType.secondary,
                                icon: Icons.filter_list,
                                onPressed: () {},
                              ),
                              const SizedBox(width: 8),
                              AppButton(
                                label: 'تصدير',
                                type: ButtonType.secondary,
                                icon: Icons.download,
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      DataTable(
                        columns: [
                          DataColumn(
                            label: Text(
                              'رقم الشحنة',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'الوجهة',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'العناصر',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'الحالة',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'الوصول المتوقع',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'القيمة',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        rows: [
                          DataRow(
                            cells: [
                              DataCell(Text('SHP-0012')),
                              DataCell(Text('مستودع أ')),
                              DataCell(Text('إلكترونيات')),
                              DataCell(
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: AppTheme.warningOrange,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('في الطريق'),
                                  ],
                                ),
                              ),
                              DataCell(Text('٢٤ تشرين ۱ ۲۰۲۳')),
                              DataCell(Text(currencyFormat.format(18500000))),
                            ],
                          ),
                        ],
                      ),
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

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
