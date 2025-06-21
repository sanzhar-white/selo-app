import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/constants/error_message.dart';
import 'package:selo/core/di/di.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/home/data/models/home_model.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:talker/talker.dart';
import '../providers.dart';
import 'home_state.dart';

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier(this.ref) : super(const HomeState());

  final Ref ref;
  final talker = di<Talker>();

  Future<void> clearFilteredCache() async {
    try {
      state = state.copyWith(
        filteredAdvertisements: [],
        hasMoreFiltered: true,
        currentPageFiltered: 1,
        error: null,
        currentFilter: null,
      );
      talker.info('Cleared filtered ads');
    } catch (e) {
      talker.error('${ErrorMessages.errorClearingFilteredAds} $e');
      state = state.copyWith(
        error: '${ErrorMessages.failedToClearFilteredAds} $e',
      );
    }
  }

  Future<void> loadBanners({bool forceRefresh = false}) async {
    await _executeUseCase(
      () => ref.read(getBannersUseCaseProvider)(),
      (banners) {
        state = state.copyWith(banners: banners, isLoading: false);
      },
      errorMessage: ErrorMessages.failedToLoadBanners,
    );
  }

  Future<void> loadAllAdvertisements({
    bool refresh = false,
    int page = 1,
    int pageSize = 10,
  }) async {
    if (state.isLoading || (!refresh && !state.hasMoreAll && page > 1)) return;
    await _executeUseCase(
      () => ref
          .read(getAllAdvertisementsUseCaseProvider)
          .call(
            params: PaginationModel(
              refresh: refresh,
              currentPage: page,
              pageSize: pageSize,
            ),
          ),
      (List<AdvertModel> ads) {
        final newList = refresh ? ads : [...?state.allAdvertisements, ...ads];
        final hasMore = ads.length >= pageSize;
        state = state.copyWith(
          allAdvertisements: newList,
          currentPageAll: page,
          hasMoreAll: hasMore,
          isLoading: false,
          currentFilter: null,
        );
      },
      errorMessage: ErrorMessages.failedToLoadAdvertisements,
    );
  }

  Future<void> loadFilteredAdvertisements({
    SearchModel? filter,
    bool refresh = false,
    int page = 1,
    int pageSize = 10,
  }) async {
    if (state.isLoading || (!refresh && !state.hasMoreFiltered && page > 1)) {
      return;
    }
    final appliedFilter = await _applyFilterAndClearCache(filter, refresh);
    await _executeUseCase(
      () => ref
          .read(getFilteredAdvertisementsUseCaseProvider)
          .call(
            params: (
              searchModel: appliedFilter,
              paginationModel: PaginationModel(
                refresh: refresh,
                currentPage: page,
                pageSize: pageSize,
              ),
            ),
          ),
      (List<AdvertModel> ads) {
        final newList =
            refresh ? ads : [...?state.filteredAdvertisements, ...ads];
        final hasMore = ads.length >= pageSize;
        state = state.copyWith(
          filteredAdvertisements: newList,
          currentPageFiltered: page,
          hasMoreFiltered: hasMore,
          currentFilter: appliedFilter,
          isLoading: false,
        );
        talker.info('Loaded ${ads.length} filtered ads for page $page');
      },
      errorMessage: ErrorMessages.failedToLoadFilteredAds,
    );
  }

  Future<void> viewAdvert(String advertUid) async {
    await _executeUseCase(
      () => ref.read(viewAdvertUseCaseProvider).call(params: advertUid),
      (_) => state = state.copyWith(isLoading: false),
      errorMessage: ErrorMessages.failedToViewAdvert,
    );
  }

  Future<void> _executeUseCase<T>(
    Future<DataState<T>> Function() useCase,
    void Function(T) onSuccess, {
    String? errorMessage,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await useCase();
      if (result is DataSuccess<T> && result.data != null) {
        onSuccess(result.data as T);
      } else if (result is DataFailed) {
        state = state.copyWith(
          isLoading: false,
          error:
              result.error?.toString() ??
              errorMessage ??
              ErrorMessages.unknownError,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      talker.error('$errorMessage: $e');
      state = state.copyWith(isLoading: false, error: '$errorMessage: $e');
    }
  }

  Future<SearchModel?> _applyFilterAndClearCache(
    SearchModel? filter,
    bool refresh,
  ) async {
    final appliedFilter =
        filter == null
            ? null
            : filter.copyWith(
              category: filter.category == null ? null : filter.category,
            );
    if (refresh || appliedFilter != state.currentFilter) {
      await clearFilteredCache();
    }
    talker.info('Fetching filtered ads with params: $appliedFilter');
    return appliedFilter;
  }

  Map<String, String> _createFilterParams(SearchModel filter) {
    return {
      'searchQuery': filter.searchQuery ?? '',
      'category': filter.category?.toString() ?? '',
      'district': filter.district?.toString() ?? '',
      'region': filter.region?.toString() ?? '',
      'priceFrom': filter.priceFrom?.toString() ?? '',
      'priceTo': filter.priceTo?.toString() ?? '',
      'sortBy': filter.sortBy?.toString() ?? '0',
      'page': '1',
    };
  }
}
