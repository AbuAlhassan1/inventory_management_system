import 'package:equatable/equatable.dart';
import '../../database/database.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  final String searchQuery;
  final Category? selectedCategory;

  const CategoryLoaded({
    this.categories = const [],
    this.searchQuery = '',
    this.selectedCategory,
  });

  CategoryLoaded copyWith({
    List<Category>? categories,
    String? searchQuery,
    Category? selectedCategory,
  }) {
    return CategoryLoaded(
      categories: categories ?? this.categories,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory,
    );
  }

  @override
  List<Object?> get props => [categories, searchQuery, selectedCategory];
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}
