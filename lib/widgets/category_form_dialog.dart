import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' hide Column;
import '../core/bloc/category/category_bloc.dart';
import '../core/bloc/category/category_event.dart';
import '../core/bloc/category/category_state.dart';
import '../core/database/database.dart';

class CategoryFormDialog extends StatefulWidget {
  const CategoryFormDialog({super.key});

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameArController;
  late final TextEditingController _nameEnController;
  late final TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameArController = TextEditingController();
    _nameEnController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  void _initializeFields(Category? category) {
    if (category != null) {
      _nameArController.text = category.nameAr;
      _nameEnController.text = category.nameEn;
      _descriptionController.text = category.description ?? '';
    }
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bloc = context.read<CategoryBloc>();
      final state = bloc.state;
      final selectedCategory = state is CategoryLoaded ? state.selectedCategory : null;

      final category = CategoriesCompanion(
        nameAr: Value(_nameArController.text.trim()),
        nameEn: Value(_nameEnController.text.trim()),
        description: Value(_descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim()),
      );

      if (selectedCategory != null) {
        bloc.add(UpdateCategory(selectedCategory.id, category));
      } else {
        bloc.add(AddCategory(category));
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء حفظ الفئة: $e'),
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
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final selectedCategory = state is CategoryLoaded ? state.selectedCategory : null;
        final isEditing = selectedCategory != null;
        final theme = Theme.of(context);

        // Initialize fields when category is selected
        if (isEditing && _nameArController.text.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeFields(selectedCategory);
          });
        }

        return AlertDialog(
          title: Text(isEditing ? 'تعديل فئة' : 'إضافة فئة جديدة'),
          content: SizedBox(
            width: 500,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameArController,
                        decoration: const InputDecoration(
                          labelText: 'الاسم (عربي) *',
                          hintText: 'أدخل اسم الفئة بالعربية',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال اسم الفئة بالعربية';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameEnController,
                        decoration: const InputDecoration(
                          labelText: 'الاسم (إنجليزي) *',
                          hintText: 'أدخل اسم الفئة بالإنجليزية',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال اسم الفئة بالإنجليزية';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'الوصف',
                          hintText: 'أدخل وصف الفئة (اختياري)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
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
              onPressed: _isLoading ? null : () => _saveCategory(context),
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
