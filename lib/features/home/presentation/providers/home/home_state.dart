import 'package:selo/features/home/data/models/home_model.dart';
import 'package:selo/shared/models/advert_model.dart';

class HomeState {

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
