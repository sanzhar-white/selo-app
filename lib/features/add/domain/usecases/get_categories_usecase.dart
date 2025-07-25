import 'package:selo/core/resources/usecase.dart';
import 'package:selo/features/add/domain/repositories/categories_repository.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/core/resources/data_state.dart';

class GetCategoriesUseCase extends UseCase<DataState<List<AdCategory>>, void> {

  GetCategoriesUseCase(this._categoriesRepository);
  final CategoriesRepository _categoriesRepository;

  @override
  Future<DataState<List<AdCategory>>> call({void params}) {
    return _categoriesRepository.getCategories();
  }
}
