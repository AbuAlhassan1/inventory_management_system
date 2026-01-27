import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' hide Column;
import '../core/bloc/customer/customer_bloc.dart';
import '../core/bloc/customer/customer_event.dart';
import '../core/bloc/customer/customer_state.dart';
import '../core/database/database.dart';

class CustomerFormDialog extends StatefulWidget {
  const CustomerFormDialog({super.key});

  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameArController;
  late final TextEditingController _nameEnController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameArController = TextEditingController();
    _nameEnController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  void _initializeFields(Customer? customer) {
    if (customer != null) {
      _nameArController.text = customer.nameAr;
      _nameEnController.text = customer.nameEn ?? '';
      _phoneController.text = customer.phone ?? '';
      _addressController.text = customer.address ?? '';
    }
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bloc = context.read<CustomerBloc>();
      final state = bloc.state;
      final selectedCustomer = state is CustomerLoaded ? state.selectedCustomer : null;

      final customer = CustomersCompanion(
        nameAr: Value(_nameArController.text.trim()),
        nameEn: Value(_nameEnController.text.trim().isEmpty
            ? null
            : _nameEnController.text.trim()),
        phone: Value(_phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim()),
        address: Value(_addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim()),
      );

      if (selectedCustomer != null) {
        bloc.add(UpdateCustomer(selectedCustomer.id, customer));
      } else {
        bloc.add(AddCustomer(customer));
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء حفظ العميل: $e'),
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
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        final selectedCustomer = state is CustomerLoaded ? state.selectedCustomer : null;
        final isEditing = selectedCustomer != null;
        final theme = Theme.of(context);

        // Initialize fields when customer is selected
        if (isEditing && _nameArController.text.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeFields(selectedCustomer);
          });
        }

        return AlertDialog(
          title: Text(isEditing ? 'تعديل عميل' : 'إضافة عميل جديد'),
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
                          hintText: 'أدخل اسم العميل بالعربية',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال اسم العميل بالعربية';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameEnController,
                        decoration: const InputDecoration(
                          labelText: 'الاسم (إنجليزي)',
                          hintText: 'أدخل اسم العميل بالإنجليزية (اختياري)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'رقم الهاتف',
                          hintText: 'أدخل رقم الهاتف (اختياري)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'العنوان',
                          hintText: 'أدخل العنوان (اختياري)',
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
              onPressed: _isLoading ? null : () => _saveCustomer(context),
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
