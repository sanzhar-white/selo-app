import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/home/data/models/home_model.dart';
import 'package:selo/shared/models/advert_model.dart';

/// Интерфейс для удаленного источника данных (Remote Data Source)
/// Абстрагирует работу с удаленным API (Firebase, REST API и т.д.)
abstract class HomeScreenRemoteDataSourceInterface {
  /// Получает список баннеров
  Future<DataState<List<String>>> getBanners();

  /// Получает список объявлений с пагинацией
  Future<DataState<List<AdvertModel>>> getAllAdvertisements(
    PaginationModel paginationModel,
  );

  /// Получает отфильтрованные объявления
  Future<DataState<List<AdvertModel>>> getFilteredAdvertisements(
    SearchModel? searchModel,
    PaginationModel paginationModel,
  );

  /// Помечает объявление как просмотренное
  Future<DataState<void>> viewAdvert(String advertUid);
}
