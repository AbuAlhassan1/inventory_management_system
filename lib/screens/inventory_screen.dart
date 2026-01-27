import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../core/bloc/product/product_bloc.dart';
import '../core/bloc/product/product_event.dart';
import '../core/bloc/product/product_state.dart';
import '../core/bloc/category/category_bloc.dart';
import '../core/bloc/category/category_event.dart';
import '../core/repositories/product_repository.dart';
import '../core/repositories/category_repository.dart';
import '../core/database/database.dart';
import '../widgets/product_form_dialog.dart';
import 'package:intl/intl.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductBloc(
        RepositoryProvider.of<ProductRepository>(context),
      )..add(const LoadProducts()),
      child: const _InventoryView(),
    );
  }
}

class _InventoryView extends StatefulWidget {
  const _InventoryView();

  @override
  State<_InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<_InventoryView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                'المخزن',
                style: theme.textTheme.headlineSmall,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: 'سجل المخزن',
                onPressed: () {
                  context.go('/inventory/history');
                },
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'بحث...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    context.read<ProductBloc>().add(SearchProducts(value));
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final bloc = context.read<ProductBloc>();
                  bloc.add(const SelectProduct(null));
                  await showDialog(
                    context: context,
                    builder: (dialogContext) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: bloc),
                        BlocProvider(
                          create: (context) => CategoryBloc(
                            RepositoryProvider.of<CategoryRepository>(context),
                          )..add(const LoadCategories()),
                        ),
                      ],
                      child: const ProductFormDialog(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة منتج'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        
        // Content
        Expanded(
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ProductError) {
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

              if (state is ProductLoaded) {
                final products = state.products;
                final searchQuery = state.searchQuery;

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty
                              ? 'لا توجد منتجات'
                              : 'لا توجد نتائج للبحث',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          searchQuery.isEmpty
                              ? 'اضغط على زر الإضافة لإضافة منتج جديد'
                              : 'جرب البحث بكلمات مختلفة',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return _ProductsTable(products: products);
              }

              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }
}

class _ProductsTable extends StatelessWidget {
  final List<Product> products;

  const _ProductsTable({required this.products});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'د.ع', decimalDigits: 0);
    final usdFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final theme = Theme.of(context);

    final headers = [
      'الباركود',
      'الاسم (عربي)',
      'الاسم (إنجليزي)',
      'سعر التكلفة (USD)',
      'سعر البيع (IQD)',
      'سعر البيع (USD)',
      'الكمية',
      'الإجراءات',
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columns: headers.map((h) => DataColumn(
              label: Text(
                h,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            )).toList(),
            rows: products.map((product) {
              return DataRow(
                cells: [
                  DataCell(Text(product.barcode)),
                  DataCell(Text(product.nameAr)),
                  DataCell(Text(product.nameEn)),
                  DataCell(Text(usdFormat.format(product.costPriceUsd))),
                  DataCell(Text(currencyFormat.format(product.sellPriceIqd))),
                  DataCell(Text(usdFormat.format(product.sellPriceUsd))),
                  DataCell(
                    Text(
                      product.quantity.toString(),
                      style: product.quantity < 10
                          ? TextStyle(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            )
                          : null,
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () async {
                            final bloc = context.read<ProductBloc>();
                            bloc.add(SelectProduct(product));
                            await showDialog(
                              context: context,
                              builder: (dialogContext) => MultiBlocProvider(
                                providers: [
                                  BlocProvider.value(value: bloc),
                                  BlocProvider(
                                    create: (context) => CategoryBloc(
                                      RepositoryProvider.of<CategoryRepository>(context),
                                    )..add(const LoadCategories()),
                                  ),
                                ],
                                child: const ProductFormDialog(),
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
                                content: Text('هل أنت متأكد من حذف "${product.nameAr}"؟'),
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
                              context.read<ProductBloc>().add(DeleteProduct(product.id));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
