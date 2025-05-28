import 'package:selo/core/models/category.dart';
import 'package:selo/core/resources/data_state.dart';

abstract class CategoriesInteface {
  Future<DataState<List<AdCategory>>> getCategories();
}
