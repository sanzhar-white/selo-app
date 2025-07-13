import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/features/authentication/presentation/provider/index.dart';
import 'package:selo/features/profile/presentation/providers/index.dart';
import 'package:selo/features/favourites/presentation/widgets/advert_wide_card.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/core/utils/auth_navigation_handler.dart';

import '../widgets/my_advert_wide_card.dart';

class MyAdsPage extends ConsumerStatefulWidget {
  const MyAdsPage({super.key});

  @override
  ConsumerState<MyAdsPage> createState() => _MyAdsPageState();
}

class _MyAdsPageState extends ConsumerState<MyAdsPage> {
  late final AuthNavigationHandler _authNavigationHandler;

  @override
  void initState() {
    super.initState();
    _authNavigationHandler = AuthNavigationHandler();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadMyAds();
      }
    });
  }

  void _loadMyAds() {
    final user = ref.read(userNotifierProvider).user;
    if (user?.uid != null) {
      ref.read(profileNotifierProvider.notifier).getMyAdverts(uid: user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ProfileState>(profileNotifierProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!, style: contrastBoldM(context))),
        );
      }
    });

    final colorScheme = Theme.of(context).colorScheme;
    final userState = ref.watch(userNotifierProvider);

    return Scaffold(
      body: _buildBody(context, userState, colorScheme),
      floatingActionButton: _buildFloatingActionButton(context, userState),
    );
  }

  Widget _buildBody(
    BuildContext context,
    UserState userState,
    ColorScheme colorScheme,
  ) {
    if (_authNavigationHandler.isAnonymous(userState)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            S.of(context)!.edit_anonymous_window,
            style: contrastM(context),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: [_buildAppBar(context, colorScheme), _buildContent(context)],
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, ColorScheme colorScheme) {
    return SliverAppBar(
      title: Text(S.of(context)!.my_ads_title, style: contrastBoldL(context)),
      iconTheme: IconThemeData(color: colorScheme.inversePrimary),
      centerTitle: true,
      elevation: 0,
      floating: true,
    );
  }

  Widget _buildContent(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);

    if (profileState.isLoading) {
      return const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (profileState.error != null && profileState.myAdverts == null) {
      return _buildErrorState(context);
    }

    if (profileState.myAdverts == null || profileState.myAdverts!.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildAdsList(context, profileState);
  }

  Widget _buildErrorState(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(S.of(context)!.error, style: contrastM(context)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMyAds,
              child: Text(S.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Text(S.of(context)!.no_ads_found, style: contrastM(context)),
      ),
    );
  }

  Widget _buildAdsList(BuildContext context, ProfileState profileState) {
    final adverts = profileState.myAdverts!;
    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final advert = adverts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RepaintBoundary(
              child: MyAdvertWideCard(
                key: ValueKey(advert.uid),
                advert: advert,
              ),
            ),
          );
        }, childCount: adverts.length),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, UserState userState) {
    return FloatingActionButton(
      onPressed:
          () => _authNavigationHandler.navigateIfAuthenticated(
            context,
            Routes.addPage,
            userState,
            ref,
          ),
      child: const Icon(Icons.add),
    );
  }
}
