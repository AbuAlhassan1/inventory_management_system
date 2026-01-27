import 'package:equatable/equatable.dart';
import '../../database/database.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  const LoadProducts();
}

class SearchProducts extends ProductEvent {
  final String query;
  
  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

class AddProduct extends ProductEvent {
  final ProductsCompanion product;
  
  const AddProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProduct extends ProductEvent {
  final int id;
  final ProductsCompanion product;
  
  const UpdateProduct(this.id, this.product);

  @override
  List<Object?> get props => [id, product];
}

class DeleteProduct extends ProductEvent {
  final int id;
  
  const DeleteProduct(this.id);

  @override
  List<Object?> get props => [id];
}

class SelectProduct extends ProductEvent {
  final Product? product;
  
  const SelectProduct(this.product);

  @override
  List<Object?> get props => [product];
}
