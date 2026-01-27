import 'package:equatable/equatable.dart';
import '../../database/database.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {
  const LoadCategories();
}

class SearchCategories extends CategoryEvent {
  final String query;

  const SearchCategories(this.query);

  @override
  List<Object?> get props => [query];
}

class AddCategory extends CategoryEvent {
  final CategoriesCompanion category;

  const AddCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateCategory extends CategoryEvent {
  final int id;
  final CategoriesCompanion category;

  const UpdateCategory(this.id, this.category);

  @override
  List<Object?> get props => [id, category];
}

class DeleteCategory extends CategoryEvent {
  final int id;

  const DeleteCategory(this.id);

  @override
  List<Object?> get props => [id];
}

class SelectCategory extends CategoryEvent {
  final Category? category;

  const SelectCategory(this.category);

  @override
  List<Object?> get props => [category];
}
