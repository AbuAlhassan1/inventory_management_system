import 'package:equatable/equatable.dart';
import '../../database/database.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomers extends CustomerEvent {
  const LoadCustomers();
}

class SearchCustomers extends CustomerEvent {
  final String query;

  const SearchCustomers(this.query);

  @override
  List<Object?> get props => [query];
}

class AddCustomer extends CustomerEvent {
  final CustomersCompanion customer;

  const AddCustomer(this.customer);

  @override
  List<Object?> get props => [customer];
}

class UpdateCustomer extends CustomerEvent {
  final int id;
  final CustomersCompanion customer;

  const UpdateCustomer(this.id, this.customer);

  @override
  List<Object?> get props => [id, customer];
}

class DeleteCustomer extends CustomerEvent {
  final int id;

  const DeleteCustomer(this.id);

  @override
  List<Object?> get props => [id];
}

class SelectCustomer extends CustomerEvent {
  final Customer? customer;

  const SelectCustomer(this.customer);

  @override
  List<Object?> get props => [customer];
}

class LoadCustomersWithDebt extends CustomerEvent {
  const LoadCustomersWithDebt();
}
