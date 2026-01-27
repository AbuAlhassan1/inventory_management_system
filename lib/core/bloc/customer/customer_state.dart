import 'package:equatable/equatable.dart';
import '../../database/database.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {
  const CustomerInitial();
}

class CustomerLoading extends CustomerState {
  const CustomerLoading();
}

class CustomerLoaded extends CustomerState {
  final List<Customer> customers;
  final String searchQuery;
  final Customer? selectedCustomer;

  const CustomerLoaded({
    this.customers = const [],
    this.searchQuery = '',
    this.selectedCustomer,
  });

  CustomerLoaded copyWith({
    List<Customer>? customers,
    String? searchQuery,
    Customer? selectedCustomer,
  }) {
    return CustomerLoaded(
      customers: customers ?? this.customers,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCustomer: selectedCustomer,
    );
  }

  @override
  List<Object?> get props => [customers, searchQuery, selectedCustomer];
}

class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}
