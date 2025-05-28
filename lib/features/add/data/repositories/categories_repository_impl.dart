import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/add/data/datasources/categories_interface.dart';
import 'package:selo/features/add/domain/repositories/categories_repository.dart';
import 'package:selo/core/models/category.dart';

class CategoriesRepositoryImpl extends CategoriesRepository
    implements CategoriesInteface {
  final CategoriesInteface _categoriesInteface;

  CategoriesRepositoryImpl(this._categoriesInteface);

  @override
  Future<DataState<List<AdCategory>>> getCategories() {
    return _categoriesInteface.getCategories();
  }
}
