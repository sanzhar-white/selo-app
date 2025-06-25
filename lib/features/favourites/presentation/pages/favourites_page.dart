import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/features/authentication/presentation/provider/index.dart';
import 'package:selo/features/favourites/data/model/favourites_model.dart';
import 'package:selo/features/favourites/presentation/providers/index.dart';
import 'package:selo/features/favourites/presentation/widgets/advert_wide_card.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavouritesPage extends ConsumerStatefulWidget {
  const FavouritesPage({super.key});

  @override
  ConsumerState<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends ConsumerState<FavouritesPage> {
  @override
  void initState() {
    super.initState();
    _loadFavourites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFavourites();
  }

  void _loadFavourites() {
    final user = ref.read(userNotifierProvider).user;
    if (user != null) {
      Future.microtask(() {
        ref
            .read(favouritesNotifierProvider.notifier)
            .getFavourites(UserUidModel(uid: user.uid));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(userNotifierProvider).user;
    final favouritesState = ref.watch(favouritesNotifierProvider);

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            S.of(context)!.favourites_anonymous_window,
            style: contrastM(context),
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              S.of(context)!.favourites_title,
              style: contrastBoldL(context),
            ),
            iconTheme: IconThemeData(color: colorScheme.inversePrimary),
            centerTitle: true,
            elevation: 0,
            floating: true,
          ),
          if (favouritesState.isLoading)
            SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                return AdvertWideCard(
                  isLoading: true,
                  advert: AdvertModel(
                    uid: '',
                    ownerUid: '',
                    createdAt: Timestamp.now(),
                    updatedAt: Timestamp.now(),
                    title: '',
                    price: 0,
                    phoneNumber: '',
                    category: 0,
                    images: const [],
                    description: '',
                  ),
                );
              }, childCount: 5),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 2.2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
            )
          else if (favouritesState.error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SelectableText(
                      'Error: ${favouritesState.error}',
                      style: contrastM(context),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadFavourites,
                      child: Text(
                        S.of(context)!.retry,
                        style: contrastM(context),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (favouritesState.favouritesModel == null ||
              favouritesState.favouritesModel!.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  S.of(context)!.favourites_empty,
                  style: contrastM(context),
                ),
              ),
            )
          else
            SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final advert = favouritesState.favouritesModel![index];
                return AdvertWideCard(advert: advert);
              }, childCount: favouritesState.favouritesModel!.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 2.2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
            ),
        ],
      ),
    );
  }
}
