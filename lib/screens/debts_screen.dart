import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../core/bloc/customer/customer_bloc.dart';
import '../core/bloc/customer/customer_event.dart';
import '../core/bloc/customer/customer_state.dart';
import '../core/repositories/customer_repository.dart';
import '../core/repositories/sale_repository.dart';
import '../core/database/database.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustomerBloc(
        RepositoryProvider.of<CustomerRepository>(context),
      )..add(const LoadCustomersWithDebt()),
      child: const _DebtsView(),
    );
  }
}

class _DebtsView extends StatefulWidget {
  const _DebtsView();

  @override
  State<_DebtsView> createState() => _DebtsViewState();
}

class _DebtsViewState extends State<_DebtsView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'ar';
    final currencyFormat = NumberFormat.currency(symbol: 'د.ع', decimalDigits: 0);
    final usdFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

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
                'الديون',
                style: theme.textTheme.headlineSmall,
              ),
              const Spacer(),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'بحث عن عميل...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    context.read<CustomerBloc>().add(SearchCustomers(value));
                  },
                ),
              ),
            ],
          ),
        ),

        // Customers with debts list
        Expanded(
          child: BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              if (state is CustomerLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is CustomerError) {
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
                        'حدث خطأ',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              if (state is CustomerLoaded) {
                final customers = state.customers;

                if (customers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد ديون',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'جميع العملاء متسددون',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Calculate total debts
                double totalDebtIqd = 0;
                double totalDebtUsd = 0;
                for (final customer in customers) {
                  totalDebtIqd += customer.totalDebtIqd;
                  totalDebtUsd += customer.totalDebtUsd;
                }

                return Column(
                  children: [
                    // Summary card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                'إجمالي الديون',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currencyFormat.format(totalDebtIqd),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
                          Column(
                            children: [
                              Text(
                                'إجمالي الديون',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                usdFormat.format(totalDebtUsd),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Customers list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final customer = customers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.error.withOpacity(0.2),
                                child: Icon(
                                  Icons.person,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                              title: Text(
                                isRTL ? customer.nameAr : customer.nameEn ?? customer.nameAr,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (customer.phone != null)
                                    Text('الهاتف: ${customer.phone}'),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'الدين: ',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      Text(
                                        currencyFormat.format(customer.totalDebtIqd),
                                        style: TextStyle(
                                          color: theme.colorScheme.error,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        ' / ${usdFormat.format(customer.totalDebtUsd)}',
                                        style: TextStyle(
                                          color: theme.colorScheme.error,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: ElevatedButton.icon(
                                onPressed: () async {
                                  await _showPaymentDialog(context, customer);
                                },
                                icon: const Icon(Icons.payment, size: 18),
                                label: const Text('تسديد'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'تفاصيل الدين',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      FutureBuilder<List<Sale>>(
                                        future: RepositoryProvider.of<SaleRepository>(context)
                                            .getSalesByCustomer(customer.id),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const Center(
                                                child: CircularProgressIndicator());
                                          }
                                          if (snapshot.hasError || !snapshot.hasData) {
                                            return Text('خطأ في تحميل المبيعات');
                                          }
                                          final sales = snapshot.data!
                                              .where((s) => s.paymentMethod == 'Debt')
                                              .toList();
                                          if (sales.isEmpty) {
                                            return const Text('لا توجد مبيعات بالدين');
                                          }
                                          return Column(
                                            children: sales.map((sale) {
                                              return ListTile(
                                                dense: true,
                                                title: Text(
                                                  'فاتورة #${sale.id}',
                                                  style: theme.textTheme.bodyMedium,
                                                ),
                                                subtitle: Text(
                                                  DateFormat('yyyy-MM-dd HH:mm')
                                                      .format(sale.createdAt),
                                                ),
                                                trailing: Text(
                                                  currencyFormat.format(sale.totalIqd),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: theme.colorScheme.error,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showPaymentDialog(BuildContext context, Customer customer) async {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: 'د.ع', decimalDigits: 0);
    final usdFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final paymentController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('تسديد دين: ${customer.nameAr}'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الدين الحالي:',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${currencyFormat.format(customer.totalDebtIqd)} / ${usdFormat.format(customer.totalDebtUsd)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: paymentController,
                    decoration: InputDecoration(
                      labelText: 'المبلغ المدفوع (IQD)',
                      hintText: '0',
                      prefixText: 'د.ع ',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال المبلغ';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'يرجى إدخال رقم صحيح أكبر من الصفر';
                      }
                      if (amount > customer.totalDebtIqd) {
                        return 'المبلغ أكبر من الدين المتبقي';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;

                      setState(() => isLoading = true);

                      try {
                        final paymentAmount = double.parse(paymentController.text);
                        final newDebtIqd = customer.totalDebtIqd - paymentAmount;
                        final newDebtUsd = customer.totalDebtUsd -
                            (paymentAmount / (customer.totalDebtUsd / customer.totalDebtIqd));

                        await RepositoryProvider.of<CustomerRepository>(context)
                            .updateCustomerDebt(
                          customer.id,
                          newDebtIqd > 0 ? newDebtIqd : 0,
                          newDebtUsd > 0 ? newDebtUsd : 0,
                        );

                        // Reload customers
                        context.read<CustomerBloc>().add(const LoadCustomersWithDebt());

                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم تسديد الدين بنجاح'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('حدث خطأ: $e'),
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
                        }
                      } finally {
                        if (context.mounted) {
                          setState(() => isLoading = false);
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('تسديد'),
            ),
          ],
        ),
      ),
    );
  }
}
