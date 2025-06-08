import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/features/add/presentation/providers/categories_provider.dart';
import 'package:selo/features/authentication/data/models/user_model.dart';
import 'package:selo/features/authentication/presentation/provider/authentication_provider.dart';
import 'package:selo/features/favourites/data/model/favourites_model.dart';
import 'package:selo/features/favourites/presentation/providers/favourites_provider.dart';
import 'package:selo/features/home/data/models/home_model.dart';
import 'package:selo/features/home/presentation/providers/home_provider.dart';
import 'package:selo/features/home/presentation/widgets/advert_mini_card.dart';
import 'package:selo/features/home/presentation/widgets/banners_body.dart';
import 'package:selo/features/home/presentation/widgets/category_card.dart';
import 'package:selo/features/home/presentation/widgets/search_appbar.dart';
import 'package:selo/features/home/presentation/widgets/shimmers/shimmer_page.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/shared/models/advert_model.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool isAnonymous = false;
  final TextEditingController searchQuery = TextEditingController();
  String? _lastError;

  PaginationModel _paginationModel = PaginationModel(
    pageSize: 10,
    currentPage: 1,
    refresh: false,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    searchQuery.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    final homeNotifier = ref.read(homeNotifierProvider.notifier);

    await homeNotifier.loadAllAdvertisements(
      refresh: false,
      page: _paginationModel.currentPage,
      pageSize: _paginationModel.pageSize,
    );
    await homeNotifier.loadBanners();
    await ref.read(categoriesNotifierProvider.notifier).loadCategories();

    if (!mounted) return;

    final user = ref.read(userNotifierProvider).user;
    if (user != null) {
      await ref
          .read(favouritesNotifierProvider.notifier)
          .getFavourites(UserUidModel(uid: user.uid));
    }

    isAnonymous = await ref.read(userNotifierProvider.notifier).isAnonymous();
    if (mounted) setState(() {});

    if (ref.read(homeNotifierProvider).allAdvertisements == null ||
        ref.read(homeNotifierProvider).allAdvertisements!.isEmpty) {
      await _refreshContent();
    }
  }

  Future<void> _refreshContent() async {
    final homeNotifier = ref.read(homeNotifierProvider.notifier);

    setState(() {
      _paginationModel = _paginationModel.copyWith(
        refresh: true,
        currentPage: 1,
      );
    });

    await homeNotifier.loadAllAdvertisements(
      refresh: true,
      page: _paginationModel.currentPage,
      pageSize: _paginationModel.pageSize,
    );
    await homeNotifier.loadBanners();
    await ref.read(categoriesNotifierProvider.notifier).loadCategories();

    if (!mounted) return;

    final user = ref.read(userNotifierProvider).user;
    if (user != null) {
      await ref
          .read(favouritesNotifierProvider.notifier)
          .getFavourites(UserUidModel(uid: user.uid));
    }

    setState(() {
      _paginationModel = _paginationModel.copyWith(refresh: false);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !ref.read(homeNotifierProvider).isLoading) {
      final homeState = ref.read(homeNotifierProvider);
      if (homeState.hasMoreAll) {
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
    if (error != null && mounted && error != _lastError) {
      _lastError = error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final homeState = ref.watch(homeNotifierProvider);
    final categories = ref.watch(categoriesNotifierProvider);

    _showError(homeState.error);

    if (homeState.isLoading && homeState.allAdvertisements == null) {
      return const HomePageShimmer();
    }

    final adverts = homeState.allAdvertisements ?? [];

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshContent,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SearchAppBarWidget(
              searchQuery: searchQuery,
              onSearchSubmitted: (value) {
                if (value.isNotEmpty) {
                  context.push(
                    Routes.nestedFilterPage,
                    extra: {'searchQuery': value, 'initialCategoryId': null},
                  );
                }
              },
              onFilterPressed: (value) {
                context.push(
                  Routes.nestedFilterPage,
                  extra: {'searchQuery': value, 'initialCategoryId': null},
                );
              },
            ),
            BannersBodyWidget(
              banners:
                  homeState.banners
                      ?.map((banner) => BannerModel(imageUrl: banner))
                      .toList() ??
                  [],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.04,
                  vertical: screenSize.height * 0.02,
                ),
                child: Text(
                  S.of(context).all_categories,
                  style: contrastBoldL(context),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.04,
                vertical: screenSize.height * 0.001,
              ),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => CategoryCard(
                    category:
                        categories.valueOrNull?[index] ??
                        AdCategory(
                          id: 0,
                          nameEn: '',
                          nameRu: '',
                          nameKk: '',
                          imageUrl: '',
                          settings: {},
                        ),
                  ),
                  childCount: categories.valueOrNull?.length ?? 0,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenSize.width > 600 ? 3 : 2,
                  mainAxisSpacing: screenSize.width * 0.05,
                  crossAxisSpacing: screenSize.width * 0.05,
                  childAspectRatio: 1.8,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  left: screenSize.width * 0.04,
                  top: screenSize.height * 0.02,
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
            if (adverts.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.02,
                  vertical: screenSize.height * 0.02,
                ),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final advert = adverts[index];
                    return AdvertMiniCard(advert: advert);
                  }, childCount: adverts.length),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenSize.width > 600 ? 3 : 2,
                    mainAxisSpacing: screenSize.width * 0.02,
                    crossAxisSpacing: screenSize.width * 0.02,
                    childAspectRatio: 0.7,
                  ),
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
