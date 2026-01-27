import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/bloc/customer/customer_bloc.dart';
import '../core/bloc/customer/customer_event.dart';
import '../core/bloc/customer/customer_state.dart';
import '../core/repositories/customer_repository.dart';
import '../core/database/database.dart';
import 'customer_form_dialog.dart';
import 'package:intl/intl.dart';

class CustomerSelectionDialog extends StatefulWidget {
  const CustomerSelectionDialog({super.key});

  @override
  State<CustomerSelectionDialog> createState() => _CustomerSelectionDialogState();
}

class _CustomerSelectionDialogState extends State<CustomerSelectionDialog> {
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

    return BlocProvider(
      create: (context) => CustomerBloc(
        RepositoryProvider.of<CustomerRepository>(context),
      )..add(const LoadCustomers()),
      child: Builder(
        builder: (builderContext) => Dialog(
          child: SizedBox(
          width: 600,
          height: 600,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
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
                      'اختر عميل',
                      style: theme.textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Search
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'بحث عن عميل...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    builderContext.read<CustomerBloc>().add(SearchCustomers(value));
                  },
                ),
              ),

              // Customers list
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
                                Icons.person_outline,
                                size: 64,
                                color: theme.colorScheme.onSurface.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد عملاء',
                                style: theme.textTheme.headlineSmall,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final customer = customers[index];
                          final hasDebt = customer.totalDebtIqd > 0 || customer.totalDebtUsd > 0;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                isRTL ? customer.nameAr : customer.nameEn ?? customer.nameAr,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (customer.phone != null)
                                    Text('الهاتف: ${customer.phone}'),
                                  if (hasDebt) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'الدين: ${currencyFormat.format(customer.totalDebtIqd)} / ${usdFormat.format(customer.totalDebtUsd)}',
                                      style: TextStyle(
                                        color: theme.colorScheme.error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(customer);
                                },
                                child: const Text('اختر'),
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),

              // Add new customer button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Builder(
                    builder: (buttonContext) => OutlinedButton.icon(
                      onPressed: () async {
                        final customerBloc = buttonContext.read<CustomerBloc>();
                        customerBloc.add(const SelectCustomer(null));
                        final customer = await showDialog<Customer>(
                          context: buttonContext,
                          builder: (dialogContext) => BlocProvider.value(
                            value: customerBloc,
                            child: const CustomerFormDialog(),
                          ),
                        );
                        if (customer != null && mounted) {
                          Navigator.of(context).pop(customer);
                        }
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('إضافة عميل جديد'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
