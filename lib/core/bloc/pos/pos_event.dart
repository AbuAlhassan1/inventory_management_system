import 'package:equatable/equatable.dart';
import '../../database/database.dart';

abstract class POSEvent extends Equatable {
  const POSEvent();

  @override
  List<Object?> get props => [];
}

class ScanBarcode extends POSEvent {
  final String barcode;

  const ScanBarcode(this.barcode);

  @override
  List<Object?> get props => [barcode];
}

class AddToCart extends POSEvent {
  final Product product;
  final int quantity;

  const AddToCart(this.product, {this.quantity = 1});

  @override
  List<Object?> get props => [product, quantity];
}

class RemoveFromCart extends POSEvent {
  final int productId;

  const RemoveFromCart(this.productId);

  @override
  List<Object?> get props => [productId];
}

class UpdateCartItemQuantity extends POSEvent {
  final int productId;
  final int quantity;

  const UpdateCartItemQuantity(this.productId, this.quantity);

  @override
  List<Object?> get props => [productId, quantity];
}

class ClearCart extends POSEvent {
  const ClearCart();
}

class SetPaymentMethod extends POSEvent {
  final String paymentMethod; // Cash, Card, Debt

  const SetPaymentMethod(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}

class SetReceivedAmount extends POSEvent {
  final double receivedAmountIqd;

  const SetReceivedAmount(this.receivedAmountIqd);

  @override
  List<Object?> get props => [receivedAmountIqd];
}

class SetCustomer extends POSEvent {
  final Customer? customer;

  const SetCustomer(this.customer);

  @override
  List<Object?> get props => [customer];
}

class ProcessCheckout extends POSEvent {
  final double receivedAmountIqd;

  const ProcessCheckout({this.receivedAmountIqd = 0.0});

  @override
  List<Object?> get props => [receivedAmountIqd];
}

class ToggleCurrency extends POSEvent {
  const ToggleCurrency();
}

class LoadExchangeRate extends POSEvent {
  const LoadExchangeRate();
}
