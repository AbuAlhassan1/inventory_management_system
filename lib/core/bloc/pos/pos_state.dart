import 'package:equatable/equatable.dart';
import '../../database/database.dart';

class CartItem extends Equatable {
  final Product product;
  final int quantity;
  final double priceIqd;
  final double priceUsd;

  const CartItem({
    required this.product,
    required this.quantity,
    required this.priceIqd,
    required this.priceUsd,
  });

  double get subtotalIqd => priceIqd * quantity;
  double get subtotalUsd => priceUsd * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
    double? priceIqd,
    double? priceUsd,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      priceIqd: priceIqd ?? this.priceIqd,
      priceUsd: priceUsd ?? this.priceUsd,
    );
  }

  @override
  List<Object?> get props => [product.id, quantity, priceIqd, priceUsd];
}

abstract class POSState extends Equatable {
  const POSState();

  @override
  List<Object?> get props => [];
}

class POSInitial extends POSState {
  const POSInitial();
}

class POSLoading extends POSState {
  const POSLoading();
}

class POSReady extends POSState {
  final List<CartItem> cartItems;
  final String paymentMethod;
  final Customer? selectedCustomer;
  final bool displayInUsd;
  final double exchangeRate;
  final double receivedAmountIqd;
  final bool isSearching;
  final String? searchError;

  const POSReady({
    this.cartItems = const [],
    this.paymentMethod = 'Cash',
    this.selectedCustomer,
    this.displayInUsd = false,
    this.exchangeRate = 1500.0,
    this.receivedAmountIqd = 0.0,
    this.isSearching = false,
    this.searchError,
  });

  double get totalIqd {
    return cartItems.fold(0.0, (sum, item) => sum + item.subtotalIqd);
  }

  double get totalUsd {
    return cartItems.fold(0.0, (sum, item) => sum + item.subtotalUsd);
  }

  double get changeIqd {
    if (paymentMethod == 'Cash' && receivedAmountIqd > 0) {
      return receivedAmountIqd - totalIqd;
    }
    return 0.0;
  }

  POSReady copyWith({
    List<CartItem>? cartItems,
    String? paymentMethod,
    Customer? selectedCustomer,
    bool? displayInUsd,
    double? exchangeRate,
    double? receivedAmountIqd,
    bool? isSearching,
    String? searchError,
  }) {
    return POSReady(
      cartItems: cartItems ?? this.cartItems,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      displayInUsd: displayInUsd ?? this.displayInUsd,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      receivedAmountIqd: receivedAmountIqd ?? this.receivedAmountIqd,
      isSearching: isSearching ?? this.isSearching,
      searchError: searchError,
    );
  }

  @override
  List<Object?> get props => [
        cartItems,
        paymentMethod,
        selectedCustomer,
        displayInUsd,
        exchangeRate,
        receivedAmountIqd,
        isSearching,
        searchError,
      ];
}

class POSError extends POSState {
  final String message;

  const POSError(this.message);

  @override
  List<Object?> get props => [message];
}

class POSCheckoutSuccess extends POSState {
  final Sale sale;

  const POSCheckoutSuccess(this.sale);

  @override
  List<Object?> get props => [sale];
}
