import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/home/data/datasources/home_interface.dart';
import 'package:selo/features/home/data/models/home_model.dart';
import 'package:selo/features/home/domain/repositories/home_repository.dart';
import 'package:selo/shared/models/advert_model.dart';

class HomeRepositoryImpl extends HomeRepository
    implements HomeScreenRemoteDataSourceInterface {
  final HomeScreenRemoteDataSourceInterface _homeInterface;

  HomeRepositoryImpl(this._homeInterface);

  @override
  Future<DataState<List<String>>> getBanners() async {
    try {
      final result = await _homeInterface.getBanners();
      if (result is DataSuccess) {
        final banners = result.data?.map((banner) => banner).toList();
        return DataSuccess(banners ?? []);
      }
      return result;
    } catch (e, stackTrace) {
      return DataFailed(Exception(e), stackTrace);
    }
  }

  @override
  Future<DataState<List<AdvertModel>>> getAllAdvertisements(
    PaginationModel paginationModel,
  ) async {
    try {
      return await _homeInterface.getAllAdvertisements(paginationModel);
    } catch (e, stackTrace) {
      return DataFailed(Exception(e), stackTrace);
    }
  }

  @override
  Future<DataState<List<AdvertModel>>> getFilteredAdvertisements(
    SearchModel? searchModel,
    PaginationModel paginationModel,
  ) async {
    if (searchModel == null ||
        (searchModel.searchQuery == null &&
            searchModel.category == null &&
            searchModel.district == null &&
            searchModel.region == null &&
            searchModel.priceFrom == null &&
            searchModel.priceTo == null &&
            searchModel.sortBy == null)) {
      return getAllAdvertisements(paginationModel);
    }

    try {
      return await _homeInterface.getFilteredAdvertisements(
        searchModel.copyWith(
          category: searchModel.category == null ? null : searchModel.category,
        ),
        paginationModel,
      );
    } catch (e, stackTrace) {
      return DataFailed(Exception(e), stackTrace);
    }
  }

  @override
  Future<DataState<void>> viewAdvert(String advertUid) {
    return _homeInterface.viewAdvert(advertUid);
  }
}
