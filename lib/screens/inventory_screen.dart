import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../core/bloc/product/product_bloc.dart';
import '../core/bloc/product/product_event.dart';
import '../core/bloc/product/product_state.dart';
import '../core/bloc/category/category_bloc.dart';
import '../core/bloc/category/category_event.dart';
import '../core/bloc/category/category_state.dart';
import '../core/repositories/product_repository.dart';
import '../core/repositories/category_repository.dart';
import '../core/database/database.dart';
import '../widgets/product_form_dialog.dart';
import '../core/theme/app_theme.dart';
import '../widgets/ui_components/filter_chip.dart';
import '../widgets/ui_components/status_indicator.dart';
import '../widgets/ui_components/app_button.dart';
import 'package:intl/intl.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProductBloc(
            RepositoryProvider.of<ProductRepository>(context),
          )..add(const LoadProducts()),
        ),
        BlocProvider(
          create: (context) => CategoryBloc(
            RepositoryProvider.of<CategoryRepository>(context),
          )..add(const LoadCategories()),
        ),
      ],
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
  String _selectedFilter = 'all';
  int? _selectedCategoryId;
  Product? _selectedProduct;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Main Content Area
        Expanded(
          child: Column(
            children: [
              // Header
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
                      width: 500,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'البحث عن طريق الاسم، الرمز (SKU)، أو الفئة...',
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
                          context.read<ProductBloc>().add(SearchProducts(value));
                        },
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.download_outlined),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      label: 'إضافة منتج',
                      type: ButtonType.primary,
                      icon: Icons.add,
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
                    ),
                  ],
                ),
              ),

              // Filters
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                    AppFilterChip(
                      label: 'كل العناصر',
                      isSelected: _selectedFilter == 'all',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'all';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    BlocBuilder<ProductBloc, ProductState>(
                      builder: (context, state) {
                        int lowStockCount = 0;
                        if (state is ProductLoaded) {
                          lowStockCount = state.products.where((p) => p.quantity < 10).length;
                        }
                        return AppFilterChip(
                          label: 'مخزون منخفض',
                          isSelected: _selectedFilter == 'low',
                          badgeCount: lowStockCount > 0 ? lowStockCount : null,
                          onTap: () {
                            setState(() {
                              _selectedFilter = 'low';
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    AppFilterChip(
                      label: 'مسودات',
                      isSelected: _selectedFilter == 'drafts',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'drafts';
                          _selectedCategoryId = null;
                        });
                      },
                    ),
                    // Dynamic category filters
                    BlocBuilder<CategoryBloc, CategoryState>(
                      builder: (context, categoryState) {
                        if (categoryState is CategoryLoaded) {
                          final categories = categoryState.categories;
                          if (categories.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Row(
                            children: [
                              const SizedBox(width: 16),
                              ...categories.take(5).map((category) {
                                final isSelected = _selectedCategoryId == category.id;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: AppFilterChip(
                                    label: category.nameAr,
                                    isSelected: isSelected,
                                    onTap: () {
                                      setState(() {
                                        _selectedFilter = 'category';
                                        _selectedCategoryId = category.id;
                                      });
                                    },
                                  ),
                                );
                              }).toList(),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),

              // Product Table
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
                      var products = state.products;

                      // Apply filters
                      if (_selectedFilter == 'low') {
                        products = products.where((p) => p.quantity < 10).toList();
                      } else if (_selectedFilter == 'category' && _selectedCategoryId != null) {
                        products = products.where((p) => p.categoryId == _selectedCategoryId).toList();
                      }

                      if (products.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: AppTheme.textTertiary,
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

                      return _ProductsTable(
                        products: products,
                        selectedProduct: _selectedProduct,
                        onProductSelected: (product) {
                          setState(() {
                            _selectedProduct = product;
                          });
                        },
                        onProductTap: (product) {
                          context.go('/inventory/product/${product.id}');
                        },
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),

        // Quick Edit Panel
        if (_selectedProduct != null)
          Container(
            width: 400,
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              border: Border(
                right: BorderSide(
                  color: AppTheme.darkSurfaceVariant,
                  width: 1,
                ),
              ),
            ),
            child: _QuickEditPanel(
              product: _selectedProduct!,
              onClose: () {
                setState(() {
                  _selectedProduct = null;
                });
              },
            ),
          ),
      ],
    );
  }
}

class _ProductsTable extends StatelessWidget {
  final List<Product> products;
  final Product? selectedProduct;
  final Function(Product) onProductSelected;
  final Function(Product)? onProductTap;

  const _ProductsTable({
    required this.products,
    required this.selectedProduct,
    required this.onProductSelected,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: DataTable(
        columns: [
          DataColumn(
            label: Text(
              'مستوى المخزون',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'الفئة',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'رمز SKU',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'المنتج',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        rows: products.map((product) {
          final isSelected = selectedProduct?.id == product.id;
          final stockLevel = product.quantity;
          final maxStock = 200; // Assume max stock for visualization
          final stockPercentage = (stockLevel / maxStock).clamp(0.0, 1.0);

          StatusType statusType;
          if (stockLevel == 0) {
            statusType = StatusType.outOfStock;
          } else if (stockLevel < 10) {
            statusType = StatusType.lowStock;
          } else {
            statusType = StatusType.available;
          }

          return DataRow(
            selected: isSelected,
            onSelectChanged: (selected) {
              if (selected == true) {
                onProductSelected(product);
              }
            },
            onLongPress: onProductTap != null
                ? () => onProductTap!(product)
                : null,
            cells: [
              DataCell(
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: LinearProgressIndicator(
                        value: stockPercentage,
                        backgroundColor: AppTheme.darkSurfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          statusType == StatusType.available
                              ? AppTheme.successGreen
                              : statusType == StatusType.lowStock
                                  ? AppTheme.warningOrange
                                  : AppTheme.errorRed,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('$stockLevel'),
                  ],
                ),
              ),
              DataCell(Text(product.categoryId.toString())),
              DataCell(Text(product.sku ?? product.barcode)),
              DataCell(
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.darkSurfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.image_outlined,
                        color: AppTheme.textTertiary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        product.nameAr,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _QuickEditPanel extends StatefulWidget {
  final Product product;
  final VoidCallback onClose;

  const _QuickEditPanel({
    required this.product,
    required this.onClose,
  });

  @override
  State<_QuickEditPanel> createState() => _QuickEditPanelState();
}

class _QuickEditPanelState extends State<_QuickEditPanel> {
  late int _quantity;
  final currencyFormat = NumberFormat.currency(symbol: 'د.ع', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _quantity = widget.product.quantity;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Header
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
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.download_outlined),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              AppButton(
                label: 'إضافة منتج',
                type: ButtonType.primary,
                icon: Icons.add,
                onPressed: () {},
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تعديل سريع',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.product.nameAr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Product Image
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.image_outlined,
                    size: 64,
                    color: AppTheme.textTertiary,
                  ),
                ),
                const SizedBox(height: 24),

                // Status Dropdown
                Text(
                  'الحالة',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: 'available',
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.darkSurfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'available', child: Text('متوفر')),
                    DropdownMenuItem(value: 'low', child: Text('مخزون منخفض')),
                    DropdownMenuItem(value: 'out', child: Text('نفذ')),
                  ],
                  onChanged: (value) {},
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                Text(
                  'الفئة',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, categoryState) {
                    if (categoryState is CategoryLoaded) {
                      final categories = categoryState.categories;
                      return DropdownButtonFormField<int>(
                        value: widget.product.categoryId,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.darkSurfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem<int>(
                            value: category.id,
                            child: Text(category.nameAr),
                          );
                        }).toList(),
                        onChanged: (value) {
                          // Handle category change
                        },
                      );
                    }
                    return DropdownButtonFormField<int>(
                      value: widget.product.categoryId,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.darkSurfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [],
                      onChanged: null,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // SKU
                Text(
                  'رمز SKU',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: TextEditingController(text: widget.product.sku ?? widget.product.barcode),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.darkSurfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Stock Level
                Text(
                  'مستوى المخزون',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (_quantity > 0) {
                          setState(() {
                            _quantity--;
                          });
                        }
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: _quantity.toString()),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.darkSurfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final newQuantity = int.tryParse(value) ?? 0;
                          setState(() {
                            _quantity = newQuantity;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          _quantity++;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'الإجمالي: $_quantity',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Unit Price
                Text(
                  'سعر الوحدة',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: TextEditingController(
                    text: currencyFormat.format(widget.product.sellPriceIqd),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.darkSurfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'إلغاء',
                        type: ButtonType.secondary,
                        onPressed: widget.onClose,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: 'حفظ التغييرات',
                        type: ButtonType.primary,
                        onPressed: () {
                          // Save changes
                          widget.onClose();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
