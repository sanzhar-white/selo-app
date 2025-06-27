import 'package:selo/core/resources/data_state.dart';
import 'package:selo/core/services/cache_manager.dart';
import 'package:selo/core/services/local_storage_service.dart';
import 'package:selo/features/home/data/datasources/home_interface.dart';
import 'package:selo/features/home/data/models/home_model.dart';
import 'package:selo/features/home/domain/repositories/home_repository.dart';
import 'package:selo/shared/models/advert_model.dart';

class HomeRepositoryImpl extends HomeRepository {
  HomeRepositoryImpl(this._homeInterface, this._cacheManager);
  final HomeScreenRemoteDataSourceInterface _homeInterface;
  final CacheManager _cacheManager;

  @override
  Future<DataState<List<String>>> getBanners() async {
    try {
      if (!_cacheManager.shouldRefresh()) {
        final cachedBanners = await LocalStorageService.getCachedBanners();
        if (cachedBanners != null && cachedBanners.isNotEmpty) {
          final bannerUrls = cachedBanners.map((e) => e.imageUrl).toList();
          return DataSuccess(bannerUrls);
        }
      }

      final result = await _homeInterface.getBanners();
      if (result is DataSuccess) {
        final banners = result.data ?? [];
        final bannerModels =
            banners.map((e) => BannerModel(imageUrl: e)).toList();
        await LocalStorageService.cacheBanners(bannerModels);
        _cacheManager.updateLastFetchTime();
        return DataSuccess(banners);
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
      if (!_cacheManager.shouldRefresh()) {
        final cachedAds = await LocalStorageService.getCachedAdvertisements(
          paginationModel.currentPage,
        );
        if (cachedAds != null && cachedAds.isNotEmpty) {
          return DataSuccess(cachedAds);
        }
      }

      final result = await _homeInterface.getAllAdvertisements(paginationModel);
      if (result is DataSuccess) {
        await LocalStorageService.cacheAdvertisements(
          result.data!,
          paginationModel.currentPage,
        );
        _cacheManager.updateLastFetchTime();
      }
      return result;
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
            searchModel.categories == null &&
            searchModel.district == null &&
            searchModel.region == null &&
            searchModel.priceFrom == null &&
            searchModel.priceTo == null &&
            searchModel.sortBy == null)) {
      return getAllAdvertisements(paginationModel);
    }

    try {
      final filterParams = searchModel.toMap().map(
        (key, value) => MapEntry(key, value.toString()),
      );
      if (!_cacheManager.shouldRefresh()) {
        final cachedFilteredAds =
            await LocalStorageService.getCachedFilteredAds(
              filterParams,
            );
        if (cachedFilteredAds != null && cachedFilteredAds.isNotEmpty) {
          return DataSuccess(cachedFilteredAds);
        }
      }

      final result = await _homeInterface.getFilteredAdvertisements(
        searchModel.copyWith(
          categories: searchModel.categories,
        ),
        paginationModel,
      );

      if (result is DataSuccess) {
        await LocalStorageService.cacheFilteredAds(result.data!, filterParams);
        _cacheManager.updateLastFetchTime();
      }
      return result;
    } catch (e, stackTrace) {
      return DataFailed(Exception(e), stackTrace);
    }
  }

  @override
  Future<DataState<void>> viewAdvert(String advertUid) {
    return _homeInterface.viewAdvert(advertUid);
  }
}
