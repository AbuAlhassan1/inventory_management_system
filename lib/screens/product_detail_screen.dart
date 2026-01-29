import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/database/database.dart';
import '../core/theme/app_theme.dart';
import '../widgets/ui_components/app_button.dart';
import '../widgets/ui_components/status_indicator.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedTimeRange = '30';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: 'د.ع', decimalDigits: 0);

    // Mock product data - in real app, fetch from repository
    final product = Product(
      id: widget.productId,
      nameAr: 'لوحة مفاتيح ميكانيكية لاسلكية - الإصدار 2',
      nameEn: 'Wireless Mechanical Keyboard - Version 2',
      barcode: 'WMK-BLK-2024',
      categoryId: 1,
      costPriceUsd: 58.95,
      sellPriceIqd: 117900,
      sellPriceUsd: 117.90,
      quantity: 142,
      sku: 'SKU-WMK-2024',
      description: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return Row(
      children: [
        // Main Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    AppButton(
                      label: 'تعديل المخزون',
                      type: ButtonType.primary,
                      icon: Icons.edit,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.print_outlined),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {},
                    ),
                    const Spacer(),
                    Text(
                      'المخزون > إلكترونيات > لوحات المفاتيح >',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                product.nameAr,
                                style: theme.textTheme.headlineMedium,
                              ),
                              const SizedBox(width: 12),
                              StatusIndicator(
                                type: StatusType.available,
                                label: 'متوفر',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'SKU: ${product.sku}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            'رمز الصنف: ${product.barcode}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // User Profile
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'مسؤول النظام',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'مدير المخزون',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppTheme.primaryTeal.withOpacity(0.2),
                          child: Icon(
                            Icons.person,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // KPI Cards
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'المبيعات الشهرية',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '458',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'قيمة المخزون',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currencyFormat.format(product.sellPriceIqd * product.quantity),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'إجمالي المخزون',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${product.quantity}',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Inventory Levels Log
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
                                  'سجل مستويات المخزون',
                                  style: theme.textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'تتبع المخزون في الوقت الفعلي',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _TimeRangeChip(
                                  label: '7 أيام',
                                  isSelected: _selectedTimeRange == '7',
                                  onTap: () {
                                    setState(() {
                                      _selectedTimeRange = '7';
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                _TimeRangeChip(
                                  label: '30 يوم',
                                  isSelected: _selectedTimeRange == '30',
                                  onTap: () {
                                    setState(() {
                                      _selectedTimeRange = '30';
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                _TimeRangeChip(
                                  label: '3 أشهر',
                                  isSelected: _selectedTimeRange == '90',
                                  onTap: () {
                                    setState(() {
                                      _selectedTimeRange = '90';
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                _TimeRangeChip(
                                  label: 'سنة',
                                  isSelected: _selectedTimeRange == '365',
                                  onTap: () {
                                    setState(() {
                                      _selectedTimeRange = '365';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 300,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 50,
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
                                      final now = DateTime.now();
                                      final dates = [
                                        now.subtract(const Duration(days: 30)),
                                        now.subtract(const Duration(days: 24)),
                                        now.subtract(const Duration(days: 18)),
                                        now.subtract(const Duration(days: 12)),
                                        now.subtract(const Duration(days: 6)),
                                        now,
                                      ];
                                      if (value.toInt() >= 0 && value.toInt() < dates.length) {
                                        final date = dates[value.toInt()];
                                        return Text(
                                          DateFormat('d MMM', 'ar').format(date),
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
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12,
                                        ),
                                      );
                                    },
                                  ),
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
                                    const FlSpot(0, 59),
                                    const FlSpot(1, 62),
                                    const FlSpot(2, 65),
                                    const FlSpot(3, 159),
                                    const FlSpot(4, 144),
                                    const FlSpot(5, 142),
                                  ],
                                  isCurved: true,
                                  color: AppTheme.primaryTeal,
                                  barWidth: 3,
                                  dotData: FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: AppTheme.primaryTeal.withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Inventory Movement Log
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: AppTheme.textSecondary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'سجل حركات المخزون',
                                  style: theme.textTheme.titleLarge,
                                ),
                              ],
                            ),
                            AppButton(
                              label: 'عرض كل السجل',
                              type: ButtonType.transparent,
                              onPressed: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        DataTable(
                          columns: [
                            DataColumn(
                              label: Text(
                                'التاريخ والوقت',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'المستخدم',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'الإجراء',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'التغيير',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'الرصيد',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          rows: [
                            _buildMovementLogRow(
                              context,
                              date: DateTime.now().subtract(const Duration(days: 1)),
                              user: 'John Doe JD',
                              action: 'صرف',
                              change: -2,
                              balance: 142,
                            ),
                            _buildMovementLogRow(
                              context,
                              date: DateTime.now().subtract(const Duration(days: 2)),
                              user: 'النظام (API) SYS',
                              action: 'صرف',
                              change: -15,
                              balance: 144,
                            ),
                            _buildMovementLogRow(
                              context,
                              date: DateTime.now().subtract(const Duration(days: 5)),
                              user: 'John Doe JD',
                              action: 'إعادة تزويد',
                              change: 100,
                              balance: 159,
                            ),
                            _buildMovementLogRow(
                              context,
                              date: DateTime.now().subtract(const Duration(days: 6)),
                              user: 'Alex M AM',
                              action: 'تعديل',
                              change: -3,
                              balance: 59,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right Sidebar - Product Specifications
        Container(
          width: 350,
          decoration: BoxDecoration(
            color: AppTheme.darkSurface,
            border: Border(
              left: BorderSide(
                color: AppTheme.darkSurfaceVariant,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Navigation
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.darkSurfaceVariant,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    _NavItem(
                      label: 'لوحة المعلومات',
                      icon: Icons.dashboard_outlined,
                      isSelected: false,
                    ),
                    _NavItem(
                      label: 'المخزون',
                      icon: Icons.inventory_2_outlined,
                      isSelected: true,
                    ),
                    _NavItem(
                      label: 'الطلبات',
                      icon: Icons.shopping_cart_outlined,
                      isSelected: false,
                    ),
                    _NavItem(
                      label: 'التحليلات',
                      icon: Icons.analytics_outlined,
                      isSelected: false,
                    ),
                  ],
                ),
              ),

              // Product Image
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppTheme.darkBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.keyboard,
                        size: 64,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'منظر أمامي',
                            type: ButtonType.secondary,
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppButton(
                            label: 'منظر علوي',
                            type: ButtonType.secondary,
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Specifications
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.primaryTeal,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'المواصفات',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _SpecItem(
                        label: 'الفئة',
                        value: 'ملحقات',
                      ),
                      _SpecItem(
                        label: 'الموقع',
                        value: 'مستودع أ، ممرع',
                        icon: Icons.location_on_outlined,
                      ),
                      _SpecItem(
                        label: 'تكلفة الوحدة',
                        value: currencyFormat.format(product.costPriceUsd * 1500), // Convert USD to IQD
                      ),
                      _SpecItem(
                        label: 'سعر البيع',
                        value: currencyFormat.format(product.sellPriceIqd),
                      ),
                      _SpecItem(
                        label: 'نقطة إعادة الطلب',
                        value: '20 وحدة',
                        icon: Icons.warning_outlined,
                        iconColor: AppTheme.warningOrange,
                      ),
                      _SpecItem(
                        label: 'المورد',
                        value: 'شركة التوريدات التقنية',
                      ),
                      _SpecItem(
                        label: 'الوزن',
                        value: '1.2 كجم',
                      ),
                      _SpecItem(
                        label: 'الأبعاد',
                        value: '35 × 12 × 4 سم',
                      ),
                    ],
                  ),
                ),
              ),

              // Settings
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.darkSurfaceVariant,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'الإعدادات',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeRangeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeRangeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal : AppTheme.darkSurfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

DataRow _buildMovementLogRow(
  BuildContext context, {
  required DateTime date,
  required String user,
  required String action,
  required int change,
  required int balance,
}) {
  final theme = Theme.of(context);
  final dateFormat = DateFormat('d MMMM، h:mm a', 'ar');
  final isPositive = change > 0;

  return DataRow(
    cells: [
      DataCell(
        Text(
          dateFormat.format(date),
          style: theme.textTheme.bodySmall,
        ),
      ),
      DataCell(Text(user)),
      DataCell(Text(action)),
      DataCell(
        Text(
          '${isPositive ? '+' : ''}$change',
          style: TextStyle(
            color: isPositive ? AppTheme.successGreen : AppTheme.errorRed,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      DataCell(
        Text(
          balance.toString(),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppTheme.primaryTeal : AppTheme.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? AppTheme.primaryTeal : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;

  const _SpecItem({
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: iconColor ?? AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
