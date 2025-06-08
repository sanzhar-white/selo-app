import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/home/data/datasources/home_interface.dart';
import 'package:selo/features/home/data/models/home_model.dart';
import 'package:selo/features/home/domain/repositories/home_repository.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:selo/core/services/local_storage_service.dart';

class HomeRepositoryImpl extends HomeRepository
    implements HomeScreenRemoteDataSourceInterface {
  final HomeScreenRemoteDataSourceInterface _homeInterface;

  HomeRepositoryImpl(this._homeInterface);

  @override
  Future<DataState<List<String>>> getBanners() async {
    try {
      final cachedBanners = await LocalStorageService.getCachedBanners();
      if (cachedBanners != null && cachedBanners.isNotEmpty) {
        print('Returning cached banners: ${cachedBanners.length}');
        return DataSuccess(
          cachedBanners.map((banner) => banner.imageUrl).toList(),
        );
      }

      final result = await _homeInterface.getBanners();
      if (result is DataSuccess) {
        final banners =
            result.data
                ?.map((banner) => BannerModel(imageUrl: banner))
                .toList();
        await LocalStorageService.cacheBanners(banners!);
        print('Cached ${banners.length} banners');
        return DataSuccess(banners.map((banner) => banner.imageUrl).toList());
      }
      return result;
    } catch (e, stackTrace) {
      print('Error getting banners: $e');
      final cachedBanners = await LocalStorageService.getCachedBanners();
      if (cachedBanners != null && cachedBanners.isNotEmpty) {
        print(
          'Returning cached banners due to network error: ${cachedBanners.length}',
        );
        return DataSuccess(
          cachedBanners.map((banner) => banner.imageUrl).toList(),
        );
      }
      return DataFailed(Exception(e), stackTrace);
    }
  }

  @override
  Future<DataState<List<AdvertModel>>> getAllAdvertisements(
    PaginationModel paginationModel,
  ) async {
    try {
      LocalStorageService.debugCache();

      if (!paginationModel.refresh) {
        final cachedAds = await LocalStorageService.getCachedAdvertisements(
          paginationModel.currentPage,
        );
        if (cachedAds != null && cachedAds.isNotEmpty) {
          print(
            'Returning cached ads for page ${paginationModel.currentPage}: ${cachedAds.length}',
          );
          return DataSuccess(cachedAds);
        }
      }

      final result = await _homeInterface.getAllAdvertisements(paginationModel);
      if (result is DataSuccess) {
        try {
          await LocalStorageService.cacheAdvertisements(
            result.data!,
            paginationModel.currentPage,
          );
          print(
            'Cached ${result.data!.length} ads for page ${paginationModel.currentPage}',
          );
        } catch (cacheError) {
          print('Failed to cache advertisements: $cacheError');
        }
        return result;
      }
      return result;
    } catch (e, stackTrace) {
      print('Error getting all advertisements: $e');
      final cachedAds = await LocalStorageService.getCachedAdvertisements(
        paginationModel.currentPage,
      );
      if (cachedAds != null && cachedAds.isNotEmpty) {
        print('Returning cached ads due to network error: ${cachedAds.length}');
        return DataSuccess(cachedAds);
      }
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
            (searchModel.category == null || searchModel.category == 0) &&
            searchModel.district == null &&
            searchModel.region == null &&
            searchModel.priceFrom == null &&
            searchModel.priceTo == null &&
            searchModel.sortBy == null)) {
      print('No filters applied, fetching all advertisements');
      return getAllAdvertisements(paginationModel);
    }

    try {
      final filterParams = {
        'searchQuery': searchModel.searchQuery ?? '',
        'category':
            searchModel.category == 0
                ? ''
                : searchModel.category?.toString() ?? '',
        'district': searchModel.district?.toString() ?? '',
        'region': searchModel.region?.toString() ?? '',
        'priceFrom': searchModel.priceFrom?.toString() ?? '',
        'priceTo': searchModel.priceTo?.toString() ?? '',
        'sortBy': searchModel.sortBy?.toString() ?? '0',
        'page': paginationModel.currentPage.toString(),
      };

      LocalStorageService.debugCache();

      if (!paginationModel.refresh) {
        final cachedAds = await LocalStorageService.getCachedFilteredAds(
          filterParams,
        );
        if (cachedAds != null && cachedAds.isNotEmpty) {
          print(
            'Returning cached filtered ads for page ${paginationModel.currentPage}: ${cachedAds.length}',
          );
          return DataSuccess(cachedAds);
        }
      }

      final result = await _homeInterface.getFilteredAdvertisements(
        searchModel.copyWith(
          category: searchModel.category == 0 ? null : searchModel.category,
        ),
        paginationModel,
      );
      if (result is DataSuccess) {
        try {
          await LocalStorageService.cacheFilteredAds(
            result.data!,
            filterParams,
          );
          print(
            'Cached ${result.data!.length} filtered ads for page ${paginationModel.currentPage}',
          );
        } catch (cacheError) {
          print('Failed to cache filtered advertisements: $cacheError');
        }
        return result;
      }
      return result;
    } catch (e, stackTrace) {
      print('Error getting filtered advertisements: $e');
      final filterParams = {
        'searchQuery': searchModel.searchQuery ?? '',
        'category':
            searchModel.category == 0
                ? ''
                : searchModel.category?.toString() ?? '',
        'district': searchModel.district?.toString() ?? '',
        'region': searchModel.region?.toString() ?? '',
        'priceFrom': searchModel.priceFrom?.toString() ?? '',
        'priceTo': searchModel.priceTo?.toString() ?? '',
        'sortBy': searchModel.sortBy?.toString() ?? '0',
        'page': paginationModel.currentPage.toString(),
      };
      final cachedAds = await LocalStorageService.getCachedFilteredAds(
        filterParams,
      );
      if (cachedAds != null && cachedAds.isNotEmpty) {
        print(
          'Returning cached filtered ads due to network error: ${cachedAds.length}',
        );
        return DataSuccess(cachedAds);
      }
      return DataFailed(Exception(e), stackTrace);
    }
  }

  @override
  Future<DataState<void>> viewAdvert(String advertUid) {
    return _homeInterface.viewAdvert(advertUid);
  }
}
