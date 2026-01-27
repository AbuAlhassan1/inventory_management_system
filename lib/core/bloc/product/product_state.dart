import 'package:equatable/equatable.dart';
import '../../database/database.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final String searchQuery;
  final Product? selectedProduct;

  const ProductLoaded({
    required this.products,
    this.searchQuery = '',
    this.selectedProduct,
  });

  @override
  List<Object?> get props => [products, searchQuery, selectedProduct];

  ProductLoaded copyWith({
    List<Product>? products,
    String? searchQuery,
    Product? selectedProduct,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedProduct: selectedProduct ?? this.selectedProduct,
    );
  }
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}
