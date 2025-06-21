import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/constants/error_message.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/utils/utils.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/features/add/presentation/providers/categories_provider.dart';
import 'package:selo/shared/models/user_model.dart';
import 'package:selo/features/authentication/presentation/provider/index.dart';
import 'package:selo/features/favourites/data/model/favourites_model.dart';
import 'package:selo/features/favourites/presentation/providers/index.dart';
import 'package:selo/features/home/data/models/home_model.dart';
import 'package:selo/features/home/presentation/providers/index.dart';
import 'package:selo/features/home/presentation/widgets/advert_detail_card.dart';
import 'package:selo/features/home/presentation/widgets/filter_show_bottom.dart';
import 'package:selo/features/home/presentation/widgets/search_appbar.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:selo/shared/widgets/shimmer_effect.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/core/di/di.dart';
import 'package:talker_flutter/talker_flutter.dart';

class FilterPage extends ConsumerStatefulWidget {
  const FilterPage({
    super.key,
    required this.searchQueryText,
    this.initialCategoryId,
  });

  final String searchQueryText;
  final int? initialCategoryId;

  @override
  ConsumerState<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends ConsumerState<FilterPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  SearchModel? currentFilters;
  bool isAnonymous = false;
  String? _lastError;
  bool _isRefreshing = false;

  PaginationModel _paginationModel = PaginationModel(
    pageSize: 10,
    currentPage: 1,
    refresh: true,
  );

  Talker get _talker => di<Talker>();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQueryText;
    if ((widget.initialCategoryId != null && widget.initialCategoryId! >= -1) ||
        widget.searchQueryText.isNotEmpty) {
      currentFilters = SearchModel(
        category:
            widget.initialCategoryId == null ? null : widget.initialCategoryId,
        searchQuery:
            widget.searchQueryText.isNotEmpty ? widget.searchQueryText : null,
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _talker.info('🔄 Initializing FilterPage with filters: $currentFilters');
      _initializeData();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    _talker.info('🔄 Calling _refreshContent from _initializeData');
    await _refreshContent();
  }

  Future<void> _refreshContent() async {
    if (!mounted || _isRefreshing) return;
    setState(() => _isRefreshing = true);

    _talker.info(
      '🔄 Refreshing content with filters: $currentFilters, pagination: $_paginationModel',
    );

    final homeNotifier = ref.read(homeNotifierProvider.notifier);
    final categoriesNotifier = ref.read(categoriesNotifierProvider.notifier);
    final favouritesNotifier = ref.read(favouritesNotifierProvider.notifier);
    final userNotifier = ref.read(userNotifierProvider.notifier);

    await categoriesNotifier.loadCategories();

    // Reset pagination and clear cache
    setState(() {
      _paginationModel = _paginationModel.copyWith(
        refresh: true,
        currentPage: 1,
      );
    });
    await homeNotifier.clearFilteredCache(); // Clear cache before loading

    if (_isFilterEmpty(currentFilters)) {
      currentFilters = null;
      _talker.info('🌐 Loading all advertisements (no filters)');
      await homeNotifier.loadAllAdvertisements(
        refresh: true,
        page: _paginationModel.currentPage,
        pageSize: _paginationModel.pageSize,
      );
    } else {
      _talker.info('🔍 Loading filtered advertisements: $currentFilters');
      await homeNotifier.loadFilteredAdvertisements(
        filter: currentFilters,
        refresh: true,
        page: _paginationModel.currentPage,
        pageSize: _paginationModel.pageSize,
      );
    }

    final user = ref.read(userNotifierProvider).user;
    if (user != null) {
      _talker.debug('⭐ Loading favourites for user: ${user.uid}');
      await favouritesNotifier.getFavourites(UserUidModel(uid: user.uid));
    }
    isAnonymous = await userNotifier.isAnonymous();

    if (mounted) {
      setState(() {
        _paginationModel = _paginationModel.copyWith(refresh: false);
        _isRefreshing = false;
      });
    }

    _talker.info(
      '✅ Refresh completed. Current filters: $currentFilters, pagination: $_paginationModel',
    );
  }

  bool _isFilterEmpty(SearchModel? filters) {
    if (filters == null) return true;
    return filters.searchQuery == null &&
        filters.category == null &&
        filters.priceFrom == null &&
        filters.priceTo == null &&
        filters.district == null &&
        filters.region == null &&
        filters.sortBy == null;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !ref.read(homeNotifierProvider).isLoading &&
        !_isRefreshing) {
      final homeState = ref.read(homeNotifierProvider);
      _talker.debug(
        '🖱️ User scrolled near end. homeState: $homeState, currentFilters: $currentFilters',
      );
      if (currentFilters != null && homeState.hasMoreFiltered) {
        setState(() {
          _paginationModel = _paginationModel.copyWith(
            currentPage: homeState.currentPageFiltered + 1,
          );
        });
        _talker.info(
          '🔄 Loading more filtered advertisements. Page: ${_paginationModel.currentPage}, Filters: $currentFilters',
        );
        ref
            .read(homeNotifierProvider.notifier)
            .loadFilteredAdvertisements(
              filter: currentFilters,
              refresh: false,
              page: _paginationModel.currentPage,
              pageSize: _paginationModel.pageSize,
            );
      } else if (homeState.hasMoreAll) {
        setState(() {
          _paginationModel = _paginationModel.copyWith(
            currentPage: homeState.currentPageAll + 1,
          );
        });
        _talker.info(
          '🔄 Loading more all advertisements. Page: ${_paginationModel.currentPage}',
        );
        ref
            .read(homeNotifierProvider.notifier)
            .loadAllAdvertisements(
              refresh: false,
              page: _paginationModel.currentPage,
              pageSize: _paginationModel.pageSize,
            );
      }
    }
  }

  void _showError(String? error) {
    if (error == null || !mounted || error == _lastError) return;

    _lastError = error;
    _talker.error('${ErrorMessages.showingErrorToUser} $error');

    Future.microtask(() {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error.contains('failed-precondition') || error.contains('Failed')
                ? S.of(context)!.error
                : error,

            style: contrastBoldM(context),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final homeState = ref.watch(homeNotifierProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showError(homeState.error);
    });

    final categoriesList = categoriesAsync.value ?? [];
    final uiCategories =
        categoriesList.map((e) => getLocalizedCategory(e, context)).toList();
    if (!uiCategories.contains(S.of(context)!.all_ads)) {
      uiCategories.add(S.of(context)!.all_ads);
    }

    final adverts =
        (currentFilters != null || _searchController.text.isNotEmpty)
            ? homeState.filteredAdvertisements ?? []
            : homeState.allAdvertisements ?? [];

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          _talker.info('🔄 User triggered pull-to-refresh');
          return _refreshContent();
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SearchAppBarWidget(
              searchQuery: _searchController,
              backIcon: true,
              pinned: true,
              floating: false,
              onSearchSubmitted: (value) {
                _talker.info('🔍 User submitted search: $value');
                setState(() {
                  currentFilters =
                      currentFilters?.copyWith(
                        searchQuery: value.isNotEmpty ? value : null,
                      ) ??
                      SearchModel(searchQuery: value.isNotEmpty ? value : null);
                  _searchController.text = value;
                });
                _refreshContent();
              },
              onFilterPressed: (value) async {
                _talker.info('🔽 User opened filter bottom sheet');
                _searchController.text = value;
                await ref
                    .read(categoriesNotifierProvider.notifier)
                    .loadCategories();
                if (!mounted) return;

                showCategoryFilterBottomSheet(
                  context: context,
                  categories: categoriesList,
                  currentFilters: currentFilters,
                  onApply: (result) {
                    _talker.info('✅ User applied filter: $result');
                    setState(() {
                      currentFilters = result?.copyWith(
                        category:
                            result.category == null ? null : result.category,
                      );
                      if (_isFilterEmpty(currentFilters)) {
                        currentFilters = null;
                      }
                    });
                    _refreshContent();
                  },
                );
              },
            ),
            SliverToBoxAdapter(
              child: FilterChipsBar(
                key: const Key('filter_chips_bar'),
                searchController: _searchController,
                currentFilters: currentFilters,
                categoriesList: categoriesList,
                isRefreshing: _isRefreshing,
                onClearSearch: () {
                  _talker.info(
                    '🗑️ User cleared search query. Filters before: $currentFilters',
                  );
                  setState(() {
                    _searchController.clear();
                    currentFilters = currentFilters?.copyWith(
                      searchQuery: null,
                    );
                    if (_isFilterEmpty(currentFilters)) currentFilters = null;
                  });
                  _refreshContent();
                },
                onClearCategory: () {
                  _talker.info(
                    '🗑️ User cleared category. Filters before: $currentFilters',
                  );
                  setState(() {
                    currentFilters = currentFilters!.copyWith(category: null);
                    if (_isFilterEmpty(currentFilters)) currentFilters = null;
                  });
                  _refreshContent();
                },
                onClearPriceFrom: () {
                  _talker.info(
                    '🗑️ User cleared priceFrom. Filters before: $currentFilters',
                  );
                  setState(() {
                    currentFilters = currentFilters!.copyWith(priceFrom: null);
                    if (_isFilterEmpty(currentFilters)) currentFilters = null;
                  });
                  _refreshContent();
                },
                onClearPriceTo: () {
                  _talker.info(
                    '🗑️ User cleared priceTo. Filters before: $currentFilters',
                  );
                  setState(() {
                    currentFilters = currentFilters!.copyWith(priceTo: null);
                    if (_isFilterEmpty(currentFilters)) currentFilters = null;
                  });
                  _refreshContent();
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.04,
                  vertical: screenSize.height * 0.02,
                ),
                child: Text(
                  S.of(context)!.all_ads,
                  style: contrastBoldL(context),
                ),
              ),
            ),
            if (homeState.isLoading && adverts.isEmpty)
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.05,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: screenSize.height * 0.03,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Container(
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        borderRadius: ResponsiveRadius.screenBased(context),
                      ),
                      child: const ShimmerAdvertDetailCard(),
                    ),
                    childCount: 6,
                  ),
                ),
              )
            else if (adverts.isEmpty && !homeState.isLoading)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(screenSize.width * 0.04),
                    child: Text(
                      S.of(context)!.no_ads_found,
                      style: contrastBoldM(context),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.05,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: screenSize.height * 0.03,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final advert = adverts[index];
                    _talker.debug('🖼️ Rendering advert card: ${advert.uid}');
                    return RepaintBoundary(
                      key: Key('advert_card_${advert.uid}'),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          borderRadius: ResponsiveRadius.screenBased(context),
                        ),
                        child: AdvertDetailCard(advert: advert),
                      ),
                    );
                  }, childCount: adverts.length),
                ),
              ),
            if (homeState.isLoading && adverts.isNotEmpty)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Метод для шиммера (перенесен из AdvertDetailCard)
  Widget _buildShimmerCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = ResponsiveRadius.screenBased(context);

    _talker.debug('✨ Showing shimmer card (loading placeholder)');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerEffect(
          width: double.infinity,
          height: 250,
          borderRadius: radius.topLeft.x,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ShimmerEffect(width: 160, height: 26, borderRadius: 4),
              const SizedBox(height: 8),
              ShimmerEffect(width: 120, height: 24, borderRadius: 4),
              const SizedBox(height: 8),
              ShimmerEffect(width: 80, height: 26, borderRadius: 4),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ShimmerEffect(
                      width: 100,
                      height: 32,
                      borderRadius: radius.bottomLeft.x,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ShimmerEffect(
                    width: 32,
                    height: 32,
                    borderRadius: radius.bottomRight.x,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 1. Новый виджет shimmer-карточки
class ShimmerAdvertDetailCard extends StatelessWidget {
  const ShimmerAdvertDetailCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = ResponsiveRadius.screenBased(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerEffect(
          width: double.infinity,
          height: 250,
          borderRadius: radius.topLeft.x,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: const [
              ShimmerEffect(width: 160, height: 26, borderRadius: 4),
              SizedBox(height: 8),
              ShimmerEffect(width: 120, height: 24, borderRadius: 4),
              SizedBox(height: 8),
              ShimmerEffect(width: 80, height: 26, borderRadius: 4),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ShimmerEffect(
                      width: 100,
                      height: 32,
                      borderRadius: 12,
                    ),
                  ),
                  SizedBox(width: 8),
                  ShimmerEffect(width: 32, height: 32, borderRadius: 12),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 2. Новый виджет для фильтр-чипов
class FilterChipsBar extends StatelessWidget {
  final TextEditingController searchController;
  final SearchModel? currentFilters;
  final List<AdCategory> categoriesList;
  final bool isRefreshing;
  final void Function()? onClearSearch;
  final void Function()? onClearCategory;
  final void Function()? onClearPriceFrom;
  final void Function()? onClearPriceTo;

  const FilterChipsBar({
    super.key,
    required this.searchController,
    required this.currentFilters,
    required this.categoriesList,
    required this.isRefreshing,
    this.onClearSearch,
    this.onClearCategory,
    this.onClearPriceFrom,
    this.onClearPriceTo,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final S s = S.of(context)!;
    List<Widget> chips = [];
    if (searchController.text.isNotEmpty) {
      chips.add(
        Chip(
          label: Text(searchController.text),
          backgroundColor: colorScheme.primary,
          labelStyle: TextStyle(color: colorScheme.onPrimary),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: isRefreshing ? null : onClearSearch,
        ),
      );
    }
    if (currentFilters != null &&
        currentFilters!.category != null &&
        currentFilters!.category! >= -1) {
      final category = categoriesList.firstWhere(
        (cat) => cat.id == currentFilters!.category!,
        orElse:
            () => AdCategory(
              id: -1,
              nameEn: s.unknown,
              nameRu: s.unknown,
              nameKk: s.unknown,
              imageUrl: '',
              settings: {},
            ),
      );
      chips.add(
        Chip(
          label: Text(
            getLocalizedCategory(category, context),
            style: TextStyle(color: colorScheme.onPrimary),
          ),
          backgroundColor: colorScheme.primary,
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: isRefreshing ? null : onClearCategory,
        ),
      );
    }
    if (currentFilters?.priceFrom != null) {
      chips.add(
        Chip(
          label: Text(
            '${s.from} ${currentFilters!.priceFrom}',
            style: TextStyle(color: colorScheme.onPrimary),
          ),
          backgroundColor: colorScheme.primary,
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: isRefreshing ? null : onClearPriceFrom,
        ),
      );
    }
    if (currentFilters?.priceTo != null) {
      chips.add(
        Chip(
          label: Text(
            '${s.to} ${currentFilters!.priceTo}',
            style: TextStyle(color: colorScheme.onPrimary),
          ),
          backgroundColor: colorScheme.primary,
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: isRefreshing ? null : onClearPriceTo,
        ),
      );
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
        vertical: MediaQuery.of(context).size.height * 0.01,
      ),
      child: Wrap(spacing: 8, children: chips),
    );
  }
}
