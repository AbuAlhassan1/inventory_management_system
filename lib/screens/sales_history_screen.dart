import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../core/repositories/sale_repository.dart';
import '../core/repositories/sale_item_repository.dart';
import '../core/repositories/customer_repository.dart';
import '../core/database/database.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  late Future<List<Sale>> _salesFuture;
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadSales() {
    setState(() {
      _salesFuture = _fetchSales();
    });
  }

  Future<List<Sale>> _fetchSales() async {
    final repository = RepositoryProvider.of<SaleRepository>(context);
    final sales = await repository.getAllSales();
    
    // Filter by date range if selected
    if (_selectedStartDate != null || _selectedEndDate != null) {
      return sales.where((sale) {
        final saleDate = sale.createdAt;
        if (_selectedStartDate != null && saleDate.isBefore(_selectedStartDate!)) {
          return false;
        }
        if (_selectedEndDate != null) {
          final endDate = DateTime(
            _selectedEndDate!.year,
            _selectedEndDate!.month,
            _selectedEndDate!.day,
            23,
            59,
            59,
          );
          if (saleDate.isAfter(endDate)) {
            return false;
          }
        }
        return true;
      }).toList();
    }
    
    return sales;
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedStartDate != null && _selectedEndDate != null
          ? DateTimeRange(start: _selectedStartDate!, end: _selectedEndDate!)
          : null,
      locale: const Locale('ar', 'IQ'),
    );
    
    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
        _loadSales();
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedStartDate = null;
      _selectedEndDate = null;
      _loadSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'ar';
    final currencyFormat = NumberFormat.currency(symbol: 'د.ع', decimalDigits: 0);
    final usdFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm', 'ar');

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                'سجل المبيعات',
                style: theme.textTheme.headlineSmall,
              ),
              const Spacer(),
              // Date filter
              if (_selectedStartDate != null && _selectedEndDate != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Chip(
                    label: Text(
                      '${dateFormat.format(_selectedStartDate!)} - ${dateFormat.format(_selectedEndDate!)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onDeleted: _clearDateFilter,
                    deleteIcon: const Icon(Icons.close, size: 18),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.date_range),
                tooltip: 'تصفية حسب التاريخ',
                onPressed: _selectDateRange,
              ),
            ],
          ),
        ),

        // Sales list
        Expanded(
          child: FutureBuilder<List<Sale>>(
            future: _salesFuture,
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
                        'حدث خطأ أثناء تحميل البيانات',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(snapshot.error.toString()),
                    ],
                  ),
                );
              }

              final sales = snapshot.data ?? [];

              if (sales.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد مبيعات',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sales.length,
                itemBuilder: (context, index) {
                  final sale = sales[index];
                  return _SaleCard(
                    sale: sale,
                    currencyFormat: currencyFormat,
                    usdFormat: usdFormat,
                    dateFormat: dateFormat,
                    isRTL: isRTL,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SaleCard extends StatelessWidget {
  final Sale sale;
  final NumberFormat currencyFormat;
  final NumberFormat usdFormat;
  final DateFormat dateFormat;
  final bool isRTL;

  const _SaleCard({
    required this.sale,
    required this.currencyFormat,
    required this.usdFormat,
    required this.dateFormat,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final saleItemRepo = RepositoryProvider.of<SaleItemRepository>(context);
    final customerRepo = RepositoryProvider.of<CustomerRepository>(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.receipt,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Row(
          children: [
            Text(
              'فاتورة #${sale.id}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text(
                sale.paymentMethod == 'Cash'
                    ? 'نقدي'
                    : sale.paymentMethod == 'Card'
                        ? 'بطاقة'
                        : 'دين',
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: sale.paymentMethod == 'Cash'
                  ? Colors.green.withOpacity(0.2)
                  : sale.paymentMethod == 'Card'
                      ? Colors.blue.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(dateFormat.format(sale.createdAt)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${currencyFormat.format(sale.totalIqd)} / ${usdFormat.format(sale.totalUsd)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          FutureBuilder<Customer?>(
            future: sale.customerId != null
                ? customerRepo.getCustomerById(sale.customerId!)
                : Future.value(null),
            builder: (context, customerSnapshot) {
              if (sale.customerId != null && customerSnapshot.hasData) {
                final customer = customerSnapshot.data;
                if (customer != null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.person, size: 16),
                        const SizedBox(width: 8),
                        Text('العميل: ${isRTL ? customer.nameAr : customer.nameEn ?? customer.nameAr}'),
                      ],
                    ),
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
          FutureBuilder<List<SaleItemWithProduct>>(
            future: saleItemRepo.getSaleItemsWithProducts(sale.id),
            builder: (context, itemsSnapshot) {
              if (itemsSnapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (!itemsSnapshot.hasData || itemsSnapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('لا توجد عناصر'),
                );
              }

              final items = itemsSnapshot.data!;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'العناصر:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${isRTL ? item.product.nameAr : item.product.nameEn} × ${item.saleItem.quantity}',
                                ),
                              ),
                              Text(
                                '${currencyFormat.format(item.saleItem.subtotalIqd)} / ${usdFormat.format(item.saleItem.subtotalUsd)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )),
                    const Divider(),
                    if (sale.paymentMethod == 'Cash') ...[
                      if (sale.receivedAmountIqd != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('المبلغ المستلم:'),
                            Text(currencyFormat.format(sale.receivedAmountIqd!)),
                          ],
                        ),
                      if (sale.changeGivenIqd != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('الباقي:'),
                            Text(currencyFormat.format(sale.changeGivenIqd!)),
                          ],
                        ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
