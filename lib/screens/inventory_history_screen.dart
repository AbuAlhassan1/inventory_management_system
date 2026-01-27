import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../core/repositories/product_repository.dart';
import '../core/repositories/category_repository.dart';
import '../core/database/database.dart';

class InventoryHistoryScreen extends StatefulWidget {
  const InventoryHistoryScreen({super.key});

  @override
  State<InventoryHistoryScreen> createState() => _InventoryHistoryScreenState();
}

class _InventoryHistoryScreenState extends State<InventoryHistoryScreen> {
  late Future<List<Product>> _productsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'createdAt'; // createdAt, updatedAt, name
  bool _sortDescending = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      _productsFuture = _fetchProducts();
    });
  }

  Future<List<Product>> _fetchProducts() async {
    final repository = RepositoryProvider.of<ProductRepository>(context);
    
    List<Product> products;
    if (_searchController.text.trim().isEmpty) {
      products = await repository.getAllProducts();
    } else {
      products = await repository.searchProducts(_searchController.text.trim());
    }

    // Sort products
    products.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.nameAr.compareTo(b.nameAr);
          break;
        case 'updatedAt':
          comparison = a.updatedAt.compareTo(b.updatedAt);
          break;
        case 'createdAt':
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }
      return _sortDescending ? -comparison : comparison;
    });

    return products;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'ar';
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm', 'ar');

    return Column(
      children: [
        // Header with search and sort
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
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'سجل المخزن',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  // Sort dropdown
                  DropdownButton<String>(
                    value: _sortBy,
                    items: const [
                      DropdownMenuItem(value: 'createdAt', child: Text('تاريخ الإضافة')),
                      DropdownMenuItem(value: 'updatedAt', child: Text('تاريخ التعديل')),
                      DropdownMenuItem(value: 'name', child: Text('الاسم')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _sortBy = value;
                          _loadProducts();
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(_sortDescending ? Icons.arrow_downward : Icons.arrow_upward),
                    tooltip: 'ترتيب',
                    onPressed: () {
                      setState(() {
                        _sortDescending = !_sortDescending;
                        _loadProducts();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'بحث عن منتج...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Products list
        Expanded(
          child: FutureBuilder<List<Product>>(
            future: _productsFuture,
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
                    ],
                  ),
                );
              }

              final products = snapshot.data ?? [];

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
                        'لا توجد منتجات',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _ProductHistoryCard(
                    product: product,
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

class _ProductHistoryCard extends StatelessWidget {
  final Product product;
  final DateFormat dateFormat;
  final bool isRTL;

  const _ProductHistoryCard({
    required this.product,
    required this.dateFormat,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryRepo = RepositoryProvider.of<CategoryRepository>(context);
    final isNew = product.createdAt.difference(product.updatedAt).abs().inSeconds < 5;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isNew
              ? Colors.green.withOpacity(0.2)
              : Colors.blue.withOpacity(0.2),
          child: Icon(
            isNew ? Icons.add : Icons.edit,
            color: isNew ? Colors.green : Colors.blue,
          ),
        ),
        title: Text(
          isRTL ? product.nameAr : (product.nameEn.isNotEmpty ? product.nameEn : product.nameAr),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            FutureBuilder<Category?>(
              future: categoryRepo.getCategoryById(product.categoryId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final category = snapshot.data;
                  if (category != null) {
                    final categoryName = isRTL 
                        ? category.nameAr 
                        : (category.nameEn.isNotEmpty ? category.nameEn : category.nameAr);
                    return Text(
                      'الفئة: $categoryName',
                      style: theme.textTheme.bodySmall,
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 4),
            Text(
              'الكمية: ${product.quantity}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14),
                const SizedBox(width: 4),
                Text(
                  isNew
                      ? 'تم الإضافة: ${dateFormat.format(product.createdAt)}'
                      : 'تم التعديل: ${dateFormat.format(product.updatedAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${product.sellPriceIqd.toStringAsFixed(0)} د.ع',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '\$${product.sellPriceUsd.toStringAsFixed(2)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
