import 'package:bloc/bloc.dart';
import 'package:drift/drift.dart';
import '../../database/database.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/sale_repository.dart';
import '../../repositories/sale_item_repository.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/exchange_rate_repository.dart';
import 'pos_event.dart';
import 'pos_state.dart';

class POSBloc extends Bloc<POSEvent, POSState> {
  final ProductRepository _productRepository;
  final SaleRepository _saleRepository;
  final SaleItemRepository _saleItemRepository;
  final CustomerRepository _customerRepository;
  final ExchangeRateRepository _exchangeRateRepository;

  POSBloc(
    this._productRepository,
    this._saleRepository,
    this._saleItemRepository,
    this._customerRepository,
    this._exchangeRateRepository,
  ) : super(const POSReady()) {
    on<ScanBarcode>(_onScanBarcode);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartItemQuantity>(_onUpdateCartItemQuantity);
    on<ClearCart>(_onClearCart);
    on<SetPaymentMethod>(_onSetPaymentMethod);
    on<SetCustomer>(_onSetCustomer);
    on<SetReceivedAmount>(_onSetReceivedAmount);
    on<ProcessCheckout>(_onProcessCheckout);
    on<ToggleCurrency>(_onToggleCurrency);
    on<LoadExchangeRate>(_onLoadExchangeRate);
    // Load exchange rate on initialization
    add(const LoadExchangeRate());
  }

  Future<void> _onLoadExchangeRate(
    LoadExchangeRate event,
    Emitter<POSState> emit,
  ) async {
    if (state is! POSReady) return;
    
    try {
      final rate = await _exchangeRateRepository.getCurrentRate();
      if (rate != null) {
        final currentState = state as POSReady;
        emit(currentState.copyWith(exchangeRate: rate.rateUsdToIqd));
      }
    } catch (e) {
      // Use default rate if error
    }
  }

  Future<void> _onScanBarcode(
    ScanBarcode event,
    Emitter<POSState> emit,
  ) async {
    if (state is! POSReady) return;

    final currentState = state as POSReady;
    
    // Set searching state
    emit(currentState.copyWith(isSearching: true, searchError: null));

    try {
      final product = await _productRepository.getProductByBarcode(event.barcode);
      if (product != null) {
        // Product found, add to cart and clear searching state
        emit(currentState.copyWith(isSearching: false, searchError: null));
        add(AddToCart(product));
      } else {
        // Product not found, show error but keep cart intact
        emit(currentState.copyWith(
          isSearching: false,
          searchError: 'المنتج غير موجود',
        ));
        // Clear error after 3 seconds
        await Future.delayed(const Duration(seconds: 3));
        if (!emit.isDone && state is POSReady) {
          final updatedState = state as POSReady;
          if (updatedState.searchError == 'المنتج غير موجود') {
            emit(updatedState.copyWith(searchError: null));
          }
        }
      }
    } catch (e) {
      // Error occurred, show error but keep cart intact
      emit(currentState.copyWith(
        isSearching: false,
        searchError: 'حدث خطأ أثناء البحث عن المنتج',
      ));
      // Clear error after 3 seconds
      await Future.delayed(const Duration(seconds: 3));
      if (!emit.isDone && state is POSReady) {
        final updatedState = state as POSReady;
        if (updatedState.searchError == 'حدث خطأ أثناء البحث عن المنتج') {
          emit(updatedState.copyWith(searchError: null));
        }
      }
    }
  }

  void _onAddToCart(
    AddToCart event,
    Emitter<POSState> emit,
  ) {
    if (state is! POSReady) return;

    final currentState = state as POSReady;
    final existingItemIndex = currentState.cartItems
        .indexWhere((item) => item.product.id == event.product.id);

    List<CartItem> newCartItems;

    if (existingItemIndex >= 0) {
      // Update existing item quantity
      final existingItem = currentState.cartItems[existingItemIndex];
      final newQuantity = existingItem.quantity + event.quantity;
      newCartItems = List.from(currentState.cartItems);
      newCartItems[existingItemIndex] = existingItem.copyWith(quantity: newQuantity);
    } else {
      // Add new item
      final newItem = CartItem(
        product: event.product,
        quantity: event.quantity,
        priceIqd: event.product.sellPriceIqd,
        priceUsd: event.product.sellPriceUsd,
      );
      newCartItems = [...currentState.cartItems, newItem];
    }

    emit(currentState.copyWith(cartItems: newCartItems));
  }

  void _onRemoveFromCart(
    RemoveFromCart event,
    Emitter<POSState> emit,
  ) {
    if (state is! POSReady) return;

    final currentState = state as POSReady;
    final newCartItems = currentState.cartItems
        .where((item) => item.product.id != event.productId)
        .toList();

    emit(currentState.copyWith(cartItems: newCartItems));
  }

  void _onUpdateCartItemQuantity(
    UpdateCartItemQuantity event,
    Emitter<POSState> emit,
  ) {
    if (state is! POSReady) return;

    final currentState = state as POSReady;
    if (event.quantity <= 0) {
      add(RemoveFromCart(event.productId));
      return;
    }

    final newCartItems = currentState.cartItems.map((item) {
      if (item.product.id == event.productId) {
        return item.copyWith(quantity: event.quantity);
      }
      return item;
    }).toList();

    emit(currentState.copyWith(cartItems: newCartItems));
  }

  void _onClearCart(
    ClearCart event,
    Emitter<POSState> emit,
  ) {
    if (state is! POSReady) return;

    final currentState = state as POSReady;
    emit(currentState.copyWith(
      cartItems: [],
      selectedCustomer: null,
      paymentMethod: 'Cash',
      receivedAmountIqd: 0.0,
    ));
  }

  void _onSetPaymentMethod(
    SetPaymentMethod event,
    Emitter<POSState> emit,
  ) {
    if (state is! POSReady) return;

    final currentState = state as POSReady;
    emit(currentState.copyWith(paymentMethod: event.paymentMethod));
  }

  void _onSetCustomer(
    SetCustomer event,
    Emitter<POSState> emit,
  ) {
    if (state is! POSReady) return;

    final currentState = state as POSReady;
    emit(currentState.copyWith(selectedCustomer: event.customer));
  }

  void _onSetReceivedAmount(
    SetReceivedAmount event,
    Emitter<POSState> emit,
  ) {
    if (state is! POSReady) return;

    final currentState = state as POSReady;
    emit(currentState.copyWith(receivedAmountIqd: event.receivedAmountIqd));
  }

  Future<void> _onProcessCheckout(
    ProcessCheckout event,
    Emitter<POSState> emit,
  ) async {
    if (state is! POSReady) return;

    final currentState = state as POSReady;

    if (currentState.cartItems.isEmpty) {
      emit(const POSError('السلة فارغة'));
      return;
    }

    emit(const POSLoading());

    try {
      // Create sale
      final sale = SalesCompanion(
        customerId: Value(currentState.selectedCustomer?.id),
        totalIqd: Value(currentState.totalIqd),
        totalUsd: Value(currentState.totalUsd),
        receivedAmountIqd: Value(event.receivedAmountIqd),
        changeGivenIqd: Value(currentState.changeIqd),
        paymentMethod: Value(currentState.paymentMethod),
      );

      final saleId = await _saleRepository.createSale(sale);

      // Create sale items and update product quantities
      for (final cartItem in currentState.cartItems) {
        await _saleItemRepository.createSaleItem(
          SaleItemsCompanion(
            saleId: Value(saleId),
            productId: Value(cartItem.product.id),
            quantity: Value(cartItem.quantity),
            priceAtSaleIqd: Value(cartItem.priceIqd),
            priceAtSaleUsd: Value(cartItem.priceUsd),
            subtotalIqd: Value(cartItem.subtotalIqd),
            subtotalUsd: Value(cartItem.subtotalUsd),
          ),
        );

        // Update product quantity
        final newQuantity = cartItem.product.quantity - cartItem.quantity;
        await _productRepository.updateProduct(
          cartItem.product.id,
          ProductsCompanion(quantity: Value(newQuantity)),
        );
      }

      // Update customer debt if payment method is Debt
      if (currentState.paymentMethod == 'Debt' && currentState.selectedCustomer != null) {
        final customer = currentState.selectedCustomer!;
        final newDebtIqd = customer.totalDebtIqd + currentState.totalIqd;
        final newDebtUsd = customer.totalDebtUsd + currentState.totalUsd;
        await _customerRepository.updateCustomerDebt(
          customer.id,
          newDebtIqd,
          newDebtUsd,
        );
      }

      // Get created sale
      final createdSale = await _saleRepository.getSaleById(saleId);
      if (createdSale != null) {
        emit(POSCheckoutSuccess(createdSale));
        // Clear cart after successful checkout
        await Future.delayed(const Duration(milliseconds: 500));
        if (!emit.isDone) {
          emit(const POSReady());
        }
      }
    } catch (e) {
      emit(POSError('حدث خطأ أثناء معالجة الدفع: $e'));
    }
  }

  void _onToggleCurrency(
    ToggleCurrency event,
    Emitter<POSState> emit,
  ) {
    if (state is! POSReady) return;

    final currentState = state as POSReady;
    emit(currentState.copyWith(displayInUsd: !currentState.displayInUsd));
  }
}
