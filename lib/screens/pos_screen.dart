import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/bloc/pos/pos_bloc.dart';
import '../core/bloc/pos/pos_event.dart';
import '../core/bloc/pos/pos_state.dart';
import '../core/repositories/product_repository.dart';
import '../core/repositories/sale_repository.dart';
import '../core/repositories/sale_item_repository.dart';
import '../core/repositories/customer_repository.dart';
import '../core/repositories/exchange_rate_repository.dart';
import '../core/database/database.dart';
import '../widgets/customer_selection_dialog.dart';

class POSScreen extends StatelessWidget {
  const POSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => POSBloc(
            RepositoryProvider.of<ProductRepository>(context),
            RepositoryProvider.of<SaleRepository>(context),
            RepositoryProvider.of<SaleItemRepository>(context),
            RepositoryProvider.of<CustomerRepository>(context),
            RepositoryProvider.of<ExchangeRateRepository>(context),
          ),
        ),
      ],
      child: const _POSView(),
    );
  }
}

class _POSView extends StatefulWidget {
  const _POSView();

  @override
  State<_POSView> createState() => _POSViewState();
}

class _POSViewState extends State<_POSView> {
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _receivedAmountController = TextEditingController();
  final FocusNode _barcodeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus barcode input for scanning
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _barcodeFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _receivedAmountController.dispose();
    _barcodeFocusNode.dispose();
    super.dispose();
  }

  void _handleBarcodeSubmit(String barcode) {
    if (barcode.trim().isNotEmpty) {
      context.read<POSBloc>().add(ScanBarcode(barcode.trim()));
      _barcodeController.clear();
      // Keep focus on barcode input for continuous scanning
      _barcodeFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'ar';

    return BlocListener<POSBloc, POSState>(
      listener: (context, state) {
        if (state is POSError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        } else if (state is POSCheckoutSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تمت العملية بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          _receivedAmountController.clear();
        }
      },
      child: BlocBuilder<POSBloc, POSState>(
        builder: (context, state) {
          if (state is POSLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is! POSReady) {
            return const Center(child: Text('خطأ في تحميل نقطة البيع'));
          }

          final posState = state;
          final currencyFormat = NumberFormat.currency(symbol: 'د.ع', decimalDigits: 0);
          final usdFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

          return Row(
            children: [
              // Left side - Product search and cart
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Header with barcode input
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
                                'نقطة البيع',
                                style: theme.textTheme.headlineSmall,
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.receipt_long),
                                tooltip: 'سجل المبيعات',
                                onPressed: () {
                                  context.go('/pos/history');
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  posState.displayInUsd ? Icons.attach_money : Icons.currency_exchange,
                                ),
                                tooltip: 'تبديل العملة',
                                onPressed: () {
                                  context.read<POSBloc>().add(const ToggleCurrency());
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _barcodeController,
                            focusNode: _barcodeFocusNode,
                            decoration: InputDecoration(
                              hintText: 'امسح الباركود أو ابحث عن منتج...',
                              prefixIcon: const Icon(Icons.qr_code_scanner),
                              suffixIcon: posState.isSearching
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : posState.searchError != null
                                      ? Icon(
                                          Icons.error_outline,
                                          color: theme.colorScheme.error,
                                        )
                                      : null,
                              errorText: posState.searchError,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                            ),
                            onSubmitted: _handleBarcodeSubmit,
                            autofocus: true,
                            enabled: !posState.isSearching,
                          ),
                        ],
                      ),
                    ),

                    // Cart items
                    Expanded(
                      child: posState.cartItems.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 64,
                                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'السلة فارغة',
                                    style: theme.textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'امسح الباركود أو ابحث عن منتج لإضافته',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: posState.cartItems.length,
                              itemBuilder: (context, index) {
                                final item = posState.cartItems[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    title: Text(
                                      isRTL ? item.product.nameAr : item.product.nameEn,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'الكمية: ${item.quantity} × ${posState.displayInUsd ? usdFormat.format(item.priceUsd) : currencyFormat.format(item.priceIqd)}',
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline),
                                          onPressed: () {
                                            if (item.quantity > 1) {
                                              context.read<POSBloc>().add(
                                                    UpdateCartItemQuantity(
                                                      item.product.id,
                                                      item.quantity - 1,
                                                    ),
                                                  );
                                            } else {
                                              context.read<POSBloc>().add(
                                                    RemoveFromCart(item.product.id),
                                                  );
                                            }
                                          },
                                        ),
                                        Text(
                                          posState.displayInUsd
                                              ? usdFormat.format(item.subtotalUsd)
                                              : currencyFormat.format(item.subtotalIqd),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outline),
                                          onPressed: () {
                                            if (item.quantity < item.product.quantity) {
                                              context.read<POSBloc>().add(
                                                    UpdateCartItemQuantity(
                                                      item.product.id,
                                                      item.quantity + 1,
                                                    ),
                                                  );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('الكمية المتاحة غير كافية'),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline),
                                          color: theme.colorScheme.error,
                                          onPressed: () {
                                            context.read<POSBloc>().add(
                                                  RemoveFromCart(item.product.id),
                                                );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),

              // Right side - Payment and checkout
              Container(
                width: 400,
                decoration: BoxDecoration(
                  border: Border(
                    left: isRTL
                        ? BorderSide.none
                        : BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                            width: 1,
                          ),
                    right: isRTL
                        ? BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                            width: 1,
                          )
                        : BorderSide.none,
                  ),
                ),
                child: Column(
                  children: [
                    // Payment method selection
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'طريقة الدفع',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'Cash',
                                label: Text('نقدي'),
                                icon: Icon(Icons.money, size: 18),
                              ),
                              ButtonSegment(
                                value: 'Card',
                                label: Text('بطاقة'),
                                icon: Icon(Icons.credit_card, size: 18),
                              ),
                              ButtonSegment(
                                value: 'Debt',
                                label: Text('دين'),
                                icon: Icon(Icons.account_balance_wallet, size: 18),
                              ),
                            ],
                            selected: {posState.paymentMethod},
                            onSelectionChanged: (Set<String> newSelection) {
                              context.read<POSBloc>().add(
                                    SetPaymentMethod(newSelection.first),
                                  );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Customer selection (for debt)
                    if (posState.paymentMethod == 'Debt')
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'العميل',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () async {
                                final customer = await showDialog<Customer>(
                                  context: context,
                                  builder: (context) => const CustomerSelectionDialog(),
                                );
                                if (customer != null && mounted) {
                                  context.read<POSBloc>().add(SetCustomer(customer));
                                }
                              },
                              icon: const Icon(Icons.person_add),
                              label: Text(
                                posState.selectedCustomer != null
                                    ? (isRTL
                                        ? posState.selectedCustomer!.nameAr
                                        : posState.selectedCustomer!.nameEn ?? '')
                                    : 'اختر عميل',
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Cash payment input
                    if (posState.paymentMethod == 'Cash')
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المبلغ المستلم',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _receivedAmountController,
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      prefixText: 'د.ع ',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    onChanged: (value) {
                                      final amount = double.tryParse(value) ?? 0.0;
                                      context.read<POSBloc>().add(
                                            SetReceivedAmount(amount),
                                          );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  tooltip: 'ملء بالمبلغ الإجمالي',
                                  onPressed: () {
                                    final total = posState.totalIqd;
                                    _receivedAmountController.text = total.toStringAsFixed(0);
                                    context.read<POSBloc>().add(
                                          SetReceivedAmount(total),
                                        );
                                  },
                                  style: IconButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primaryContainer,
                                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                                    padding: const EdgeInsets.all(12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    // Totals
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الإجمالي',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            _TotalRow(
                              label: 'المجموع الفرعي',
                              amount: posState.displayInUsd
                                  ? posState.totalUsd
                                  : posState.totalIqd,
                              isUsd: posState.displayInUsd,
                            ),
                            if (posState.paymentMethod == 'Cash' &&
                                posState.receivedAmountIqd > 0) ...[
                              const SizedBox(height: 8),
                              _TotalRow(
                                label: 'المبلغ المستلم',
                                amount: posState.receivedAmountIqd,
                                isUsd: false,
                              ),
                              const SizedBox(height: 8),
                              _TotalRow(
                                label: 'الباقي',
                                amount: posState.changeIqd,
                                isUsd: false,
                                isChange: true,
                              ),
                            ],
                            const Spacer(),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: posState.cartItems.isEmpty
                                    ? null
                                    : () {
                                        if (posState.paymentMethod == 'Debt' &&
                                            posState.selectedCustomer == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('يرجى اختيار عميل للدفع بالدين'),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                          return;
                                        }
                                        context.read<POSBloc>().add(
                                              ProcessCheckout(
                                                receivedAmountIqd: posState.receivedAmountIqd,
                                              ),
                                            );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                ),
                                child: Text(
                                  'إتمام البيع',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  context.read<POSBloc>().add(const ClearCart());
                                  _receivedAmountController.clear();
                                },
                                child: const Text('مسح السلة'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isUsd;
  final bool isChange;

  const _TotalRow({
    required this.label,
    required this.amount,
    this.isUsd = false,
    this.isChange = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: 'د.ع', decimalDigits: 0);
    final usdFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge,
        ),
        Text(
          isUsd ? usdFormat.format(amount) : currencyFormat.format(amount),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isChange && amount < 0
                ? theme.colorScheme.error
                : isChange
                    ? Colors.green
                    : null,
          ),
        ),
      ],
    );
  }
}
