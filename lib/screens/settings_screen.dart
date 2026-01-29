import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/bloc/category/category_bloc.dart';
import '../core/bloc/category/category_event.dart';
import '../core/bloc/category/category_state.dart';
import '../core/repositories/category_repository.dart';
import '../core/repositories/exchange_rate_repository.dart';
import '../core/database/database.dart';
import '../widgets/category_form_dialog.dart';
import '../core/theme/app_theme.dart';
import '../widgets/ui_components/app_button.dart';
import '../widgets/ui_components/app_header.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Header
          AppHeader(
            title: 'الإعدادات',
            subtitle: 'إدارة الفئات وإعدادات النظام',
            breadcrumbs: const ['الرئيسية', 'الإعدادات'],
          ),
          
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.darkSurfaceVariant,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              labelColor: AppTheme.primaryTeal,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.primaryTeal,
              tabs: const [
                Tab(
                  icon: Icon(Icons.category_outlined),
                  text: 'الفئات',
                ),
                Tab(
                  icon: Icon(Icons.currency_exchange_outlined),
                  text: 'سعر الصرف',
                ),
              ],
            ),
          ),
          
          // Tab Content
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
            color: AppTheme.darkSurface,
            border: Border(
              bottom: BorderSide(
                color: AppTheme.darkSurfaceVariant,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 400,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'بحث عن فئة...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: AppTheme.darkSurfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
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
              const Spacer(),
              AppButton(
                label: 'إضافة فئة',
                type: ButtonType.primary,
                icon: Icons.add,
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
                          color: AppTheme.textTertiary,
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
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الفئات (${categories.length})',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ...categories.map((category) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryTeal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.category,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                            title: Text(
                              isRTL ? category.nameAr : category.nameEn,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: category.description != null
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      category.description!,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  )
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                    color: AppTheme.textSecondary,
                                  ),
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
                                    Icons.delete_outline,
                                    size: 20,
                                    color: AppTheme.errorRed,
                                  ),
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: AppTheme.darkSurface,
                                        title: Text(
                                          'تأكيد الحذف',
                                          style: theme.textTheme.titleLarge,
                                        ),
                                        content: Text(
                                          'هل أنت متأكد من حذف "${isRTL ? category.nameAr : category.nameEn}"؟',
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: Text(
                                              'إلغاء',
                                              style: TextStyle(color: AppTheme.textSecondary),
                                            ),
                                          ),
                                          AppButton(
                                            label: 'حذف',
                                            type: ButtonType.primary,
                                            onPressed: () => Navigator.of(context).pop(true),
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
                      }).toList(),
                    ],
                  ),
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
          SnackBar(
            content: const Text('تم حفظ سعر الصرف بنجاح'),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'سعر الصرف',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'إدارة سعر صرف الدولار الأمريكي إلى الدينار العراقي',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // Current Rate Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.currency_exchange,
                          color: AppTheme.primaryTeal,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'سعر الصرف الحالي',
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_currentRate != null) ...[
                    Text(
                      '1 USD = ${currencyFormat.format(_currentRate!.rateUsdToIqd)}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        if (_currentRate!.source != null)
                          Text(
                            'المصدر: ${_currentRate!.source}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        if (_currentRate!.source != null) const SizedBox(width: 16),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'آخر تحديث: ${DateFormat('yyyy-MM-dd HH:mm', 'ar').format(_currentRate!.lastUpdated)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ] else
                    Text(
                      'لا يوجد سعر صرف محدد',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Update Rate Form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.warningOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          color: AppTheme.warningOrange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'تحديث سعر الصرف',
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سعر الصرف (USD إلى IQD)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _rateController,
                                decoration: InputDecoration(
                                  hintText: 'مثال: 1500',
                                  filled: true,
                                  fillColor: AppTheme.darkSurfaceVariant,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixText: '1 USD = ',
                                  suffixText: ' IQD',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
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
                            AppButton(
                              label: _isLoading ? 'جاري الحفظ...' : 'حفظ',
                              type: ButtonType.primary,
                              icon: _isLoading ? null : Icons.save_outlined,
                              isDisabled: _isLoading,
                              onPressed: _isLoading ? null : _saveRate,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'سيتم تطبيق سعر الصرف الجديد على جميع العمليات الحسابية',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
