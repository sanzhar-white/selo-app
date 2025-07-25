import 'package:selo/core/models/category.dart';

class CategoriesState {

  const CategoriesState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });
  final List<AdCategory> categories;
  final bool isLoading;
  final String? error;

  CategoriesState copyWith({
    List<AdCategory>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
