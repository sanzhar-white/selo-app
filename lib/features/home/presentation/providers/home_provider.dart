import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/home/data/datasources/home_interface.dart';
import 'package:selo/features/home/data/datasources/firebase_datasource.dart';
import 'package:selo/features/home/data/models/home_model.dart';
import 'package:selo/features/home/data/repositories/home_repository_impl.dart';
import 'package:selo/features/home/domain/repositories/home_repository.dart';
import 'package:selo/features/home/domain/usecases/get_banners_usecase.dart';
import 'package:selo/features/home/domain/usecases/get_all_advertisements_usecase.dart';
import 'package:selo/features/home/domain/usecases/get_filtered_advertisements_usecase.dart';
import 'package:selo/features/home/domain/usecases/view_advert_usecase.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selo/core/services/local_storage_service.dart';

final firebaseDatasourceProvider =
    Provider<HomeScreenRemoteDataSourceInterface>(
      (ref) => FirebaseHomeScreenRemoteDataSource(
        firestore: FirebaseFirestore.instance,
      ),
    );

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepositoryImpl(ref.watch(firebaseDatasourceProvider)),
);

final getBannersUseCaseProvider = Provider<GetBannersUseCase>(
  (ref) => GetBannersUseCase(ref.watch(homeRepositoryProvider)),
);

final getAllAdvertisementsUseCaseProvider =
    Provider<GetAllAdvertisementsUseCase>(
      (ref) => GetAllAdvertisementsUseCase(ref.watch(homeRepositoryProvider)),
    );

final getFilteredAdvertisementsUseCaseProvider = Provider<
  GetFilteredAdvertisementsUseCase
>((ref) => GetFilteredAdvertisementsUseCase(ref.watch(homeRepositoryProvider)));

final viewAdvertUseCaseProvider = Provider<ViewAdvertUseCase>(
  (ref) => ViewAdvertUseCase(ref.watch(homeRepositoryProvider)),
);

class HomeState {
  final List<String>? banners;
  final List<AdvertModel>? allAdvertisements;
  final List<AdvertModel>? filteredAdvertisements;
  final bool isLoading;
  final String? error;
  final int currentPageAll;
  final int currentPageFiltered;
  final bool hasMoreAll;
  final bool hasMoreFiltered;
  final SearchModel? currentFilter;

  const HomeState({
    this.banners,
    this.allAdvertisements = const [],
    this.filteredAdvertisements,
    this.isLoading = false,
    this.error,
    this.currentPageAll = 1,
    this.currentPageFiltered = 1,
    this.hasMoreAll = true,
    this.hasMoreFiltered = true,
    this.currentFilter,
  });

  HomeState copyWith({
    List<String>? banners,
    List<AdvertModel>? allAdvertisements,
    List<AdvertModel>? filteredAdvertisements,
    bool? isLoading,
    String? error,
    int? currentPageAll,
    int? currentPageFiltered,
    bool? hasMoreAll,
    bool? hasMoreFiltered,
    SearchModel? currentFilter,
  }) {
    return HomeState(
      banners: banners ?? this.banners,
      allAdvertisements: allAdvertisements ?? this.allAdvertisements,
      filteredAdvertisements:
          filteredAdvertisements ?? this.filteredAdvertisements,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPageAll: currentPageAll ?? this.currentPageAll,
      currentPageFiltered: currentPageFiltered ?? this.currentPageFiltered,
      hasMoreAll: hasMoreAll ?? this.hasMoreAll,
      hasMoreFiltered: hasMoreFiltered ?? this.hasMoreFiltered,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

final homeNotifierProvider = StateNotifierProvider<HomeNotifier, HomeState>(
  (ref) => HomeNotifier(ref),
);

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier(this.ref) : super(const HomeState());

  final Ref ref;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 10);

  Future<void> clearFilteredCache() async {
    try {
      await LocalStorageService.clearFilteredAdsCache();
      state = state.copyWith(
        filteredAdvertisements: [],
        hasMoreFiltered: true,
        currentPageFiltered: 1,
        error: null,
        currentFilter: null,
      );
      print('🧹 Cleared filtered ads cache');
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear filtered cache: $e');
      print('💥 Error clearing filtered cache: $e');
    }
  }

  Future<void> loadBanners({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await ref.read(getBannersUseCaseProvider)();
      if (result is DataSuccess<List<String>>) {
        state = state.copyWith(banners: result.data, isLoading: false);
        _lastFetchTime = DateTime.now();
      } else if (result is DataFailed) {
        state = state.copyWith(
          error: result.error?.toString() ?? 'Failed to load banners',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load banners: $e',
        isLoading: false,
      );
    }
  }

  Future<void> loadAllAdvertisements({
    bool refresh = false,
    int page = 1,
    int pageSize = 10,
  }) async {
    if (state.isLoading || (!refresh && !state.hasMoreAll && page > 1)) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await ref
          .read(getAllAdvertisementsUseCaseProvider)
          .call(
            params: PaginationModel(
              refresh: refresh,
              currentPage: page,
              pageSize: pageSize,
            ),
          );

      if (result is DataSuccess<List<AdvertModel>>) {
        final newList =
            refresh
                ? result.data
                : [...?state.allAdvertisements, ...result.data!];
        final hasMore = result.data!.length >= pageSize;

        state = state.copyWith(
          allAdvertisements: newList,
          currentPageAll: page,
          hasMoreAll: hasMore,
          isLoading: false,
          currentFilter: null,
        );

        if (result.data!.isNotEmpty) {
          await LocalStorageService.cacheAdvertisements(result.data!, page);
        }
      } else if (result is DataFailed) {
        state = state.copyWith(
          error: result.error?.toString() ?? 'Failed to load advertisements',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load advertisements: $e',
        isLoading: false,
      );
    }
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

    state = state.copyWith(isLoading: true, error: null);

    final appliedFilter =
        filter == null
            ? null
            : filter.copyWith(
              category: filter.category == 0 ? null : filter.category,
            );
    print('Fetching filtered ads with params: $appliedFilter');

    if (refresh || appliedFilter != state.currentFilter) {
      await clearFilteredCache();
    }

    try {
      final result = await ref
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
          );

      if (result is DataSuccess<List<AdvertModel>>) {
        final newList =
            refresh
                ? result.data
                : [...?state.filteredAdvertisements, ...result.data!];
        final hasMore = result.data!.length >= pageSize;

        state = state.copyWith(
          filteredAdvertisements: newList,
          currentPageFiltered: page,
          hasMoreFiltered: hasMore,
          currentFilter: appliedFilter,
          isLoading: false,
        );

        if (result.data!.isNotEmpty && appliedFilter != null) {
          await LocalStorageService.cacheFilteredAds(
            result.data!,
            _createFilterParams(appliedFilter),
          );
        }
        print('Cached ${result.data!.length} filtered ads for page $page');
      } else if (result is DataFailed) {
        state = state.copyWith(
          error: result.error?.toString() ?? 'Failed to load filtered ads',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load filtered ads: $e',
        isLoading: false,
      );
    }
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

  Future<void> viewAdvert(String advertUid) async {
    final result = await ref
        .read(viewAdvertUseCaseProvider)
        .call(params: advertUid);
    if (result is DataSuccess<void>) {
      state = state.copyWith(isLoading: false);
    }
  }
}
