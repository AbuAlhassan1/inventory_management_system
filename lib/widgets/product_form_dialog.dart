import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' hide Column;
import '../core/bloc/product/product_bloc.dart';
import '../core/bloc/product/product_event.dart';
import '../core/bloc/product/product_state.dart';
import '../core/bloc/category/category_bloc.dart';
import '../core/bloc/category/category_event.dart';
import '../core/bloc/category/category_state.dart';
import '../core/repositories/category_repository.dart';
import '../core/repositories/exchange_rate_repository.dart';
import '../core/database/database.dart';

class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({super.key});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameArController;
  late final TextEditingController _nameEnController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _costPriceUsdController;
  late final TextEditingController _sellPriceIqdController;
  late final TextEditingController _sellPriceUsdController;
  late final TextEditingController _quantityController;
  late final TextEditingController _skuController;
  late final TextEditingController _descriptionController;
  
  int? _categoryId;
  bool _isLoading = false;
  double _exchangeRate = 1500.0; // Default exchange rate
  bool _autoCalculateIqd = true;

  @override
  void initState() {
    super.initState();
    _nameArController = TextEditingController();
    _nameEnController = TextEditingController();
    _barcodeController = TextEditingController();
    _costPriceUsdController = TextEditingController();
    _sellPriceIqdController = TextEditingController();
    _sellPriceUsdController = TextEditingController();
    _quantityController = TextEditingController(text: '0');
    _skuController = TextEditingController();
    _descriptionController = TextEditingController();

    // Load exchange rate
    _loadExchangeRate();

    // Add listener for auto-calculation
    _sellPriceUsdController.addListener(_onSellPriceUsdChanged);
  }

  Future<void> _loadExchangeRate() async {
    try {
      final repository = RepositoryProvider.of<ExchangeRateRepository>(context);
      final rate = await repository.getCurrentRate();
      if (rate != null && mounted) {
        setState(() {
          _exchangeRate = rate.rateUsdToIqd;
        });
      }
    } catch (e) {
      // Use default rate
    }
  }

  void _onSellPriceUsdChanged() {
    if (!_autoCalculateIqd) return;
    
    if (_sellPriceUsdController.text.isNotEmpty) {
      final usdPrice = double.tryParse(_sellPriceUsdController.text);
      if (usdPrice != null && usdPrice > 0) {
        final iqdPrice = (usdPrice * _exchangeRate).round();
        // Update IQD price automatically (only if different to avoid infinite loop)
        if (_sellPriceIqdController.text != iqdPrice.toString()) {
          _sellPriceIqdController.text = iqdPrice.toString();
        }
      }
    }
  }

  void _initializeFields(Product? product) {
    if (product != null) {
      _nameArController.text = product.nameAr;
      _nameEnController.text = product.nameEn;
      _barcodeController.text = product.barcode;
      _costPriceUsdController.text = product.costPriceUsd.toString();
      _sellPriceIqdController.text = product.sellPriceIqd.toString();
      _sellPriceUsdController.text = product.sellPriceUsd.toString();
      _quantityController.text = product.quantity.toString();
      _skuController.text = product.sku ?? '';
      _descriptionController.text = product.description ?? '';
      _categoryId = product.categoryId;
    }
  }

  @override
  void dispose() {
    _sellPriceUsdController.removeListener(_onSellPriceUsdChanged);
    _nameArController.dispose();
    _nameEnController.dispose();
    _barcodeController.dispose();
    _costPriceUsdController.dispose();
    _sellPriceIqdController.dispose();
    _sellPriceUsdController.dispose();
    _quantityController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bloc = context.read<ProductBloc>();
      final state = bloc.state;
      final selectedProduct = state is ProductLoaded ? state.selectedProduct : null;

      final product = ProductsCompanion(
        nameAr: Value(_nameArController.text.trim()),
        nameEn: Value(_nameEnController.text.trim()),
        barcode: Value(_barcodeController.text.trim()),
        categoryId: Value(_categoryId ?? 0),
        costPriceUsd: Value(double.parse(_costPriceUsdController.text)),
        sellPriceIqd: Value(double.parse(_sellPriceIqdController.text)),
        sellPriceUsd: Value(double.parse(_sellPriceUsdController.text)),
        quantity: Value(int.parse(_quantityController.text)),
        sku: Value(_skuController.text.trim().isEmpty ? null : _skuController.text.trim()),
        description: Value(_descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim()),
      );

      if (selectedProduct != null) {
        bloc.add(UpdateProduct(selectedProduct.id, product));
      } else {
        bloc.add(AddProduct(product));
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء حفظ المنتج: $e'),
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
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        final selectedProduct = state is ProductLoaded ? state.selectedProduct : null;
        final isEditing = selectedProduct != null;
        final theme = Theme.of(context);
        
        // Initialize fields when product is selected
        if (isEditing && _nameArController.text.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeFields(selectedProduct);
          });
        }

        return AlertDialog(
          title: Text(isEditing ? 'تعديل منتج' : 'إضافة منتج جديد'),
          content: SizedBox(
            width: 600,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nameArController,
                              decoration: const InputDecoration(
                                labelText: 'الاسم (عربي) *',
                                hintText: 'أدخل الاسم بالعربية',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'يرجى إدخال الاسم بالعربية';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _nameEnController,
                              decoration: const InputDecoration(
                                labelText: 'الاسم (إنجليزي) *',
                                hintText: 'أدخل الاسم بالإنجليزية',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'يرجى إدخال الاسم بالإنجليزية';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Category selection
                      BlocProvider(
                        create: (context) => CategoryBloc(
                          RepositoryProvider.of<CategoryRepository>(context),
                        )..add(const LoadCategories()),
                        child: BlocBuilder<CategoryBloc, CategoryState>(
                          builder: (context, categoryState) {
                            List<Category> categories = [];
                            if (categoryState is CategoryLoaded) {
                              categories = categoryState.categories;
                            }

                            return DropdownButtonFormField<int>(
                              initialValue: _categoryId,
                              decoration: const InputDecoration(
                                labelText: 'الفئة *',
                                border: OutlineInputBorder(),
                              ),
                              items: categories.map((category) {
                                final locale = Localizations.localeOf(context);
                                final isRTL = locale.languageCode == 'ar';
                                return DropdownMenuItem<int>(
                                  value: category.id,
                                  child: Text(isRTL ? category.nameAr : category.nameEn),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _categoryId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'يرجى اختيار فئة';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _barcodeController,
                        decoration: const InputDecoration(
                          labelText: 'الباركود *',
                          hintText: 'أدخل الباركود',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال الباركود';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _costPriceUsdController,
                              decoration: const InputDecoration(
                                labelText: 'سعر التكلفة (USD) *',
                                hintText: '0.00',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'يرجى إدخال سعر التكلفة';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'يرجى إدخال رقم صحيح';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _sellPriceIqdController,
                                        decoration: InputDecoration(
                                          labelText: 'سعر البيع (IQD) *',
                                          hintText: '0',
                                          border: const OutlineInputBorder(),
                                          suffixIcon: _autoCalculateIqd
                                              ? Tooltip(
                                                  message: 'يتم الحساب تلقائياً من سعر USD',
                                                  child: const Icon(Icons.auto_fix_high, size: 18),
                                                )
                                              : null,
                                        ),
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'يرجى إدخال سعر البيع';
                                          }
                                          if (double.tryParse(value) == null) {
                                            return 'يرجى إدخال رقم صحيح';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _autoCalculateIqd,
                                      onChanged: (value) {
                                        setState(() {
                                          _autoCalculateIqd = value ?? true;
                                        });
                                      },
                                    ),
                                    Text(
                                      'حساب تلقائي من USD',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _sellPriceUsdController,
                              decoration: const InputDecoration(
                                labelText: 'سعر البيع (USD) *',
                                hintText: '0.00',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'يرجى إدخال سعر البيع';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'يرجى إدخال رقم صحيح';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              decoration: const InputDecoration(
                                labelText: 'الكمية *',
                                hintText: '0',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'يرجى إدخال الكمية';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'يرجى إدخال رقم صحيح';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _skuController,
                              decoration: const InputDecoration(
                                labelText: 'SKU',
                                hintText: 'أدخل SKU (اختياري)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'الوصف',
                          hintText: 'أدخل وصف المنتج (اختياري)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 5,
                        minLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _saveProduct(context),
              child: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Text(isEditing ? 'حفظ التعديلات' : 'إضافة'),
            ),
          ],
        );
      },
    );
  }
}
