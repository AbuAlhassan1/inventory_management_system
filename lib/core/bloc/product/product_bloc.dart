import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;

  ProductBloc(this.repository) : super(const ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<SearchProducts>(_onSearchProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<SelectProduct>(_onSelectProduct);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      final products = await repository.getAllProducts();
      emit(ProductLoaded(products: products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductState> emit,
  ) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      emit(currentState.copyWith(searchQuery: event.query));
    }
    
    try {
      final products = await repository.searchProducts(event.query);
      emit(ProductLoaded(products: products, searchQuery: event.query));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onAddProduct(
    AddProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await repository.insertProduct(event.product);
      final products = await repository.getAllProducts();
      emit(ProductLoaded(products: products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await repository.updateProduct(event.id, event.product);
      final products = await repository.searchProducts(
        state is ProductLoaded ? (state as ProductLoaded).searchQuery : '',
      );
      emit(ProductLoaded(
        products: products,
        searchQuery: state is ProductLoaded ? (state as ProductLoaded).searchQuery : '',
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await repository.deleteProduct(event.id);
      final products = await repository.searchProducts(
        state is ProductLoaded ? (state as ProductLoaded).searchQuery : '',
      );
      emit(ProductLoaded(
        products: products,
        searchQuery: state is ProductLoaded ? (state as ProductLoaded).searchQuery : '',
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void _onSelectProduct(
    SelectProduct event,
    Emitter<ProductState> emit,
  ) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      emit(currentState.copyWith(selectedProduct: event.product));
    }
  }
}
