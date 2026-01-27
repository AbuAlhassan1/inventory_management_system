// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/bloc/category/category_bloc.dart';
import '../core/bloc/category/category_event.dart';
import '../core/bloc/category/category_state.dart';
import '../core/repositories/category_repository.dart';
import '../core/repositories/exchange_rate_repository.dart';
import '../core/database/database.dart';
import '../widgets/category_form_dialog.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'الإعدادات',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                Expanded(
                  child: const TabBar(
                    tabs: [
                      Tab(text: 'الفئات'),
                      Tab(text: 'سعر الصرف'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _CategoriesTab(),
                _ExchangeRateTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CategoryBloc(
        RepositoryProvider.of<CategoryRepository>(context),
      )..add(const LoadCategories()),
      child: Builder(
        builder: (context) => const _CategoriesView(),
      ),
    );
  }
}

class _CategoriesView extends StatefulWidget {
  const _CategoriesView();

  @override
  State<_CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<_CategoriesView> {
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

    return Column(
      children: [
        // Header with search and add button
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
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'بحث عن فئة...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    if (mounted) {
                      context.read<CategoryBloc>().add(SearchCategories(value));
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final categoryBloc = context.read<CategoryBloc>();
                  categoryBloc.add(const SelectCategory(null));
                  await showDialog(
                    context: context,
                    builder: (dialogContext) => BlocProvider.value(
                      value: categoryBloc,
                      child: const CategoryFormDialog(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة فئة'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),

        // Categories list
        Expanded(
          child: BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              if (state is CategoryLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is CategoryError) {
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

              if (state is CategoryLoaded) {
                final categories = state.categories;

                if (categories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد فئات',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'اضغط على زر الإضافة لإضافة فئة جديدة',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          isRTL ? category.nameAr : category.nameEn,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: category.description != null
                            ? Text(category.description!)
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              onPressed: () async {
                                context.read<CategoryBloc>().add(SelectCategory(category));
                                await showDialog(
                                  context: context,
                                  builder: (context) => BlocProvider.value(
                                    value: context.read<CategoryBloc>(),
                                    child: const CategoryFormDialog(),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                size: 18,
                                color: theme.colorScheme.error,
                              ),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('تأكيد الحذف'),
                                    content: Text(
                                        'هل أنت متأكد من حذف "${isRTL ? category.nameAr : category.nameEn}"؟'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('إلغاء'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: theme.colorScheme.error,
                                        ),
                                        child: const Text('حذف'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true && context.mounted) {
                                  context.read<CategoryBloc>().add(DeleteCategory(category.id));
                                }
                              },
                            ),
                          ],
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
      ],
    );
  }
}

class _ExchangeRateTab extends StatefulWidget {
  const _ExchangeRateTab();

  @override
  State<_ExchangeRateTab> createState() => _ExchangeRateTabState();
}

class _ExchangeRateTabState extends State<_ExchangeRateTab> {
  final _rateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  ExchangeRateData? _currentRate;

  @override
  void initState() {
    super.initState();
    _loadCurrentRate();
  }

  Future<void> _loadCurrentRate() async {
    final repository = RepositoryProvider.of<ExchangeRateRepository>(context);
    final rate = await repository.getCurrentRate();
    setState(() {
      _currentRate = rate;
      if (rate != null) {
        _rateController.text = rate.rateUsdToIqd.toString();
      }
    });
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _saveRate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = RepositoryProvider.of<ExchangeRateRepository>(context);
      final rate = double.parse(_rateController.text);
      await repository.setExchangeRate(rate, source: 'Manual');
      await _loadCurrentRate();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ سعر الصرف بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: 'د.ع', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'سعر الصرف الحالي',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (_currentRate != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1 USD = ${currencyFormat.format(_currentRate!.rateUsdToIqd)}',
                          style: theme.textTheme.headlineSmall,
                        ),
                        if (_currentRate!.source != null)
                          Text(
                            'المصدر: ${_currentRate!.source}',
                            style: theme.textTheme.bodySmall,
                          ),
                        Text(
                          'آخر تحديث: ${DateFormat('yyyy-MM-dd HH:mm').format(_currentRate!.lastUpdated)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('لا يوجد سعر صرف محدد'),
              ),
            ),
          const SizedBox(height: 32),
          Text(
            'تحديث سعر الصرف',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _rateController,
                    decoration: const InputDecoration(
                      labelText: 'سعر الصرف (USD إلى IQD)',
                      hintText: 'مثال: 1500',
                      border: OutlineInputBorder(),
                      prefixText: '1 USD = ',
                      suffixText: ' IQD',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال سعر الصرف';
                      }
                      final rate = double.tryParse(value);
                      if (rate == null || rate <= 0) {
                        return 'يرجى إدخال رقم صحيح أكبر من الصفر';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveRate,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('حفظ'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
