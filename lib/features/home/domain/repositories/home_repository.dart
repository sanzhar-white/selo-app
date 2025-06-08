import 'package:selo/core/resources/data_state.dart';
import 'package:selo/shared/models/advert_model.dart';
import '../../data/models/home_model.dart';

abstract class HomeRepository {
  Future<DataState<List<String>>> getBanners();
  Future<DataState<List<AdvertModel>>> getAllAdvertisements(
    PaginationModel paginationModel,
  );
  Future<DataState<List<AdvertModel>>> getFilteredAdvertisements(
    SearchModel? searchModel,
    PaginationModel paginationModel,
  );
  Future<DataState<void>> viewAdvert(String advertUid);
}
