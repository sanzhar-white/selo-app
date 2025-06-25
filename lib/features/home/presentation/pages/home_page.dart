import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/features/add/presentation/providers/categories_provider.dart';
import 'package:selo/shared/models/user_model.dart';
import 'package:selo/features/authentication/presentation/provider/index.dart';
import 'package:selo/features/favourites/data/model/favourites_model.dart';
import 'package:selo/features/favourites/presentation/providers/index.dart';
import 'package:selo/features/home/data/models/home_model.dart';
import 'package:selo/features/home/presentation/providers/index.dart';
import 'package:selo/features/home/presentation/widgets/advert_mini_card.dart';
import 'package:selo/features/home/presentation/widgets/banners_body.dart';
import 'package:selo/features/home/presentation/widgets/category_card.dart';
import 'package:selo/features/home/presentation/widgets/search_appbar.dart';
import 'package:selo/features/home/presentation/widgets/shimmers/shimmer_page.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:collection/collection.dart';
import 'package:selo/core/theme/responsive_radius.dart';

import 'package:selo/core/utils/utils.dart';

class HomePageController extends ChangeNotifier {
  HomePageController(this.ref) {
    scrollController.addListener(_onScroll);
  }
  final WidgetRef ref;
  final ScrollController scrollController = ScrollController();
  PaginationModel paginationModel = const PaginationModel();
  bool isInitialized = false;
  bool isAnonymous = false;
  String? lastError;

  Future<void> initializeData() async {
    final homeNotifier = ref.read(homeNotifierProvider.notifier);
    await Future.wait([
      homeNotifier.loadAllAdvertisements(
        page: paginationModel.currentPage,
        pageSize: paginationModel.pageSize,
      ),
      homeNotifier.loadBanners(),
      ref.read(categoriesNotifierProvider.notifier).loadCategories(),
    ]);
    final user = ref.read(userNotifierProvider).user;
    if (user != null) {
      await ref
          .read(favouritesNotifierProvider.notifier)
          .getFavourites(UserUidModel(uid: user.uid));
    }
    isAnonymous = await ref.read(userNotifierProvider.notifier).isAnonymous();
    isInitialized = true;
    notifyListeners();
  }

  Future<void> refreshContent() async {
    final homeNotifier = ref.read(homeNotifierProvider.notifier);
    paginationModel = paginationModel.copyWith(refresh: true, currentPage: 1);
    notifyListeners();
    await Future.wait([
      homeNotifier.loadAllAdvertisements(
        refresh: true,
        page: paginationModel.currentPage,
        pageSize: paginationModel.pageSize,
      ),
      homeNotifier.loadBanners(),
      ref.read(categoriesNotifierProvider.notifier).loadCategories(),
    ]);
    final user = ref.read(userNotifierProvider).user;
    if (user != null) {
      await ref
          .read(favouritesNotifierProvider.notifier)
          .getFavourites(UserUidModel(uid: user.uid));
    }
    paginationModel = paginationModel.copyWith(refresh: false);
    notifyListeners();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent * 0.9 &&
        !ref.read(homeNotifierProvider).isLoading) {
      final homeState = ref.read(homeNotifierProvider);
      if (homeState.hasMoreAll) {
        paginationModel = paginationModel.copyWith(
          currentPage: homeState.currentPageAll + 1,
        );
        notifyListeners();
        ref
            .read(homeNotifierProvider.notifier)
            .loadAllAdvertisements(
              page: paginationModel.currentPage,
              pageSize: paginationModel.pageSize,
            );
      }
    }
  }

  void showError(BuildContext context, String? error) {
    if (error != null && error != lastError) {
      lastError = error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error, style: contrastBoldM(context))),
        );
      });
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final HomePageController controller;
  final TextEditingController searchQuery = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = HomePageController(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initializeData();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    searchQuery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final homeState = ref.watch(homeNotifierProvider);
    final categories = ref.watch(categoriesNotifierProvider);

    controller.showError(context, homeState.error);

    if (homeState.isLoading && homeState.allAdvertisements == null) {
      return const HomePageShimmer();
    }

    final adverts = homeState.allAdvertisements ?? [];

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.refreshContent,
        child: CustomScrollView(
          key: const Key('home_scroll_view'),
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SearchAppBarWidget(
              key: const Key('search_app_bar'),
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
              key: const Key('banners_body'),
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
                  S.of(context)!.all_categories,
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
                  (context, index) => RepaintBoundary(
                    key: Key('category_card_$index'),
                    child: CategoryCard(
                      category:
                          categories.valueOrNull?[index] ??
                          const AdCategory(
                            id: 0,
                            nameEn: '',
                            nameRu: '',
                            nameKk: '',
                            imageUrl: '',
                            settings: {},
                          ),
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
                  S.of(context)!.all_ads,
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
                      S.of(context)!.no_ads_found,
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
                    return RepaintBoundary(
                      key: Key('advert_card_$index'),
                      child: AdvertMiniCard(advert: advert),
                    );
                  }, childCount: adverts.length),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenSize.width > 600 ? 3 : 2,
                    mainAxisSpacing: screenSize.width * 0.1,
                    crossAxisSpacing: screenSize.width * 0.02,
                    childAspectRatio: 0.65,
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
