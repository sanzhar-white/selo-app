import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/features/authentication/presentation/provider/authentication_provider.dart';
import 'package:selo/features/profile/presentation/providers/profile_provider.dart';
import 'package:selo/features/favourites/presentation/widgets/advert_wide_card.dart';
import 'package:selo/generated/l10n.dart';

class MyAdsPage extends ConsumerStatefulWidget {
  const MyAdsPage({super.key});

  @override
  ConsumerState<MyAdsPage> createState() => _MyAdsPageState();
}

class _MyAdsPageState extends ConsumerState<MyAdsPage> {
  @override
  void initState() {
    super.initState();
    _loadMyAds();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadMyAds();
  }

  void _loadMyAds() {
    final user = ref.read(userNotifierProvider).user;
    if (user != null) {
      Future.microtask(() {
        ref.read(profileNotifierProvider.notifier).getMyAdverts(uid: user.uid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(userNotifierProvider).user;
    final profileState = ref.watch(profileNotifierProvider);

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            S.of(context).edit_anonymous_window,
            style: contrastM(context),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              S.of(context).my_ads_title,
              style: contrastBoldL(context),
            ),
            iconTheme: IconThemeData(color: colorScheme.inversePrimary),
            centerTitle: true,
            elevation: 0,
            floating: true,
          ),
          if (profileState.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (profileState.error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SelectableText(
                      'Error: ${profileState.error}',
                      style: contrastM(context),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadMyAds,
                      child: Text(S.of(context).retry),
                    ),
                  ],
                ),
              ),
            )
          else if (profileState.myAdverts == null ||
              profileState.myAdverts!.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  S.of(context).no_ads_found,
                  style: contrastM(context),
                ),
              ),
            )
          else
            SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final advert = profileState.myAdverts![index];
                return AdvertWideCard(advert: advert);
              }, childCount: profileState.myAdverts!.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
            ),
        ],
      ),
    );
  }
}
