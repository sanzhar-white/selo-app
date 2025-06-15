import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:selo/core/models/category.dart';

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
    await _refreshContent();
  }

  Future<void> _refreshContent() async {
    if (!mounted || _isRefreshing) return;
    setState(() => _isRefreshing = true);

    print('🔄 Refreshing content with filters: $currentFilters');

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

      await homeNotifier.loadAllAdvertisements(
        refresh: true,
        page: _paginationModel.currentPage,
        pageSize: _paginationModel.pageSize,
      );
      print('🌐 Loaded all advertisements');
    } else {
      await homeNotifier.loadFilteredAdvertisements(
        filter: currentFilters,
        refresh: true,
        page: _paginationModel.currentPage,
        pageSize: _paginationModel.pageSize,
      );
      print('🔍 Loaded filtered advertisements');
    }

    final user = ref.read(userNotifierProvider).user;
    if (user != null) {
      await favouritesNotifier.getFavourites(UserUidModel(uid: user.uid));
    }
    isAnonymous = await userNotifier.isAnonymous();

    if (mounted) {
      setState(() {
        _paginationModel = _paginationModel.copyWith(refresh: false);
        _isRefreshing = false;
      });
    }

    print('✅ Refresh completed. Current filters: $currentFilters');
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
      if (currentFilters != null && homeState.hasMoreFiltered) {
        setState(() {
          _paginationModel = _paginationModel.copyWith(
            currentPage: homeState.currentPageFiltered + 1,
          );
        });
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

    Future.microtask(() {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error.contains('failed-precondition') || error.contains('Failed')
                ? S.of(context).error
                : error,
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
    if (!uiCategories.contains(S.of(context).all_ads)) {
      uiCategories.add(S.of(context).all_ads);
    }

    final adverts =
        (currentFilters != null || _searchController.text.isNotEmpty)
            ? homeState.filteredAdvertisements ?? []
            : homeState.allAdvertisements ?? [];

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshContent,
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
            if (currentFilters != null || _searchController.text.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.04,
                    vertical: screenSize.height * 0.01,
                  ),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        Chip(
                          label: Text(_searchController.text),
                          backgroundColor: colorScheme.primary,
                          labelStyle: TextStyle(color: colorScheme.onPrimary),
                          deleteIcon: Icon(
                            Icons.close,
                            size: 16,
                            color: colorScheme.onPrimary,
                          ),
                          onDeleted:
                              _isRefreshing
                                  ? null
                                  : () {
                                    setState(() {
                                      _searchController.clear();
                                      currentFilters = currentFilters?.copyWith(
                                        searchQuery: null,
                                      );
                                      if (_isFilterEmpty(currentFilters)) {
                                        currentFilters = null;
                                      }
                                    });
                                    print(
                                      '🗑️ Cleared search query. Filters: $currentFilters',
                                    );
                                    _refreshContent();
                                  },
                        ),
                      if (currentFilters != null &&
                          currentFilters!.category != null &&
                          currentFilters!.category! >= -1)
                        Chip(
                          label: Text(
                            getLocalizedCategory(
                              categoriesList.firstWhere(
                                (cat) => cat.id == currentFilters!.category!,
                                orElse: () {
                                  print(
                                    '⚠️ Category not found for ID: ${currentFilters!.category}',
                                  );
                                  return AdCategory(
                                    id: -1,
                                    nameEn: S.of(context).unknown,
                                    nameRu: S.of(context).unknown,
                                    nameKk: S.of(context).unknown,
                                    imageUrl: '',
                                    settings: {},
                                  );
                                },
                              ),
                              context,
                            ),
                            style: TextStyle(color: colorScheme.onPrimary),
                          ),
                          backgroundColor: colorScheme.primary,
                          deleteIcon: Icon(
                            Icons.close,
                            size: 16,
                            color: colorScheme.onPrimary,
                          ),
                          onDeleted:
                              _isRefreshing
                                  ? null
                                  : () {
                                    setState(() {
                                      currentFilters = currentFilters!.copyWith(
                                        category: null,
                                      );
                                      if (_isFilterEmpty(currentFilters)) {
                                        currentFilters = null;
                                      }
                                    });
                                    print(
                                      '🗑️ Cleared category. Filters: $currentFilters',
                                    );
                                    _refreshContent();
                                  },
                        ),
                      if (currentFilters?.priceFrom != null)
                        Chip(
                          label: Text(
                            '${S.of(context).from} ${currentFilters!.priceFrom}',
                            style: TextStyle(color: colorScheme.onPrimary),
                          ),
                          backgroundColor: colorScheme.primary,
                          deleteIcon: Icon(
                            Icons.close,
                            size: 16,
                            color: colorScheme.onPrimary,
                          ),
                          onDeleted:
                              _isRefreshing
                                  ? null
                                  : () {
                                    setState(() {
                                      currentFilters = currentFilters!.copyWith(
                                        priceFrom: null,
                                      );
                                      if (_isFilterEmpty(currentFilters)) {
                                        currentFilters = null;
                                      }
                                    });
                                    print(
                                      '🗑️ Cleared priceFrom. Filters: $currentFilters',
                                    );
                                    _refreshContent();
                                  },
                        ),
                      if (currentFilters?.priceTo != null)
                        Chip(
                          label: Text(
                            '${S.of(context).to} ${currentFilters!.priceTo}',
                            style: TextStyle(color: colorScheme.onPrimary),
                          ),
                          backgroundColor: colorScheme.primary,
                          deleteIcon: Icon(
                            Icons.close,
                            size: 16,
                            color: colorScheme.onPrimary,
                          ),
                          onDeleted:
                              _isRefreshing
                                  ? null
                                  : () {
                                    setState(() {
                                      currentFilters = currentFilters!.copyWith(
                                        priceTo: null,
                                      );
                                      if (_isFilterEmpty(currentFilters)) {
                                        currentFilters = null;
                                      }
                                    });
                                    print(
                                      '🗑️ Cleared priceTo. Filters: $currentFilters',
                                    );
                                    _refreshContent();
                                  },
                        ),
                    ],
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.04,
                  vertical: screenSize.height * 0.02,
                ),
                child: Text(
                  S.of(context).all_ads,
                  style: contrastBoldL(context),
                ),
              ),
            ),
            if (adverts.isEmpty && !homeState.isLoading)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(screenSize.width * 0.04),
                    child: Text(
                      S.of(context).no_ads_found,
                      style: contrastBoldM(context),
                    ),
                  ),
                ),
              ),
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
                  return Container(
                    decoration: BoxDecoration(
                      color: colorScheme.secondary,
                      borderRadius: ResponsiveRadius.screenBased(context),
                    ),
                    child: AdvertDetailCard(
                      advert: advert,
                      isLoading: homeState.isLoading,
                    ),
                  );
                }, childCount: adverts.length),
              ),
            ),
            if (homeState.isLoading && adverts.isNotEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(screenSize.width * 0.04),
                    child: const CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
