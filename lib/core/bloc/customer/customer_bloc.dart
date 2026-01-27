import 'package:bloc/bloc.dart';
import '../../repositories/customer_repository.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository _customerRepository;

  CustomerBloc(this._customerRepository) : super(const CustomerInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<SearchCustomers>(_onSearchCustomers);
    on<AddCustomer>(_onAddCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);
    on<SelectCustomer>(_onSelectCustomer);
    on<LoadCustomersWithDebt>(_onLoadCustomersWithDebt);
  }

  Future<void> _onLoadCustomers(
    LoadCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    emit(const CustomerLoading());
    try {
      final customers = await _customerRepository.getAllCustomers();
      emit(CustomerLoaded(customers: customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onSearchCustomers(
    SearchCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    if (state is CustomerLoaded) {
      final currentState = state as CustomerLoaded;
      emit(currentState.copyWith(searchQuery: event.query));
      try {
        final customers = await _customerRepository.searchCustomers(event.query);
        emit(currentState.copyWith(customers: customers, searchQuery: event.query));
      } catch (e) {
        emit(CustomerError(e.toString()));
      }
    }
  }

  Future<void> _onAddCustomer(
    AddCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      await _customerRepository.createCustomer(event.customer);
      add(const LoadCustomers()); // Reload customers after adding
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onUpdateCustomer(
    UpdateCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      await _customerRepository.updateCustomer(event.id, event.customer);
      add(const LoadCustomers()); // Reload customers after updating
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      await _customerRepository.deleteCustomer(event.id);
      add(const LoadCustomers()); // Reload customers after deleting
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  void _onSelectCustomer(
    SelectCustomer event,
    Emitter<CustomerState> emit,
  ) {
    if (state is CustomerLoaded) {
      final currentState = state as CustomerLoaded;
      emit(currentState.copyWith(selectedCustomer: event.customer));
    }
  }

  Future<void> _onLoadCustomersWithDebt(
    LoadCustomersWithDebt event,
    Emitter<CustomerState> emit,
  ) async {
    emit(const CustomerLoading());
    try {
      final customers = await _customerRepository.getCustomersWithDebt();
      emit(CustomerLoaded(customers: customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }
}
