import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/core/utils/utils.dart';
import 'package:selo/features/add/presentation/providers/categories_provider.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/shared/widgets/shimmer_effect.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:selo/features/favourites/presentation/providers/favourites_provider.dart';
import 'package:selo/features/authentication/presentation/provider/authentication_provider.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/features/home/presentation/providers/home_provider.dart';

class AdvertMiniCard extends ConsumerWidget {
  const AdvertMiniCard({
    super.key,
    required this.advert,
    this.isLoading = false,
  });

  final AdvertModel advert;
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return _buildShimmerCard(context);
    }

    final colorScheme = Theme.of(context).colorScheme;
    final radius = ResponsiveRadius.screenBased(context);
    final favouritesState = ref.watch(favouritesNotifierProvider);
    final categories = ref.watch(categoriesNotifierProvider).valueOrNull ?? [];
    final user = ref.watch(userNotifierProvider).user;

    final isFavourite =
        favouritesState.favouritesModel?.any((e) => e.uid == advert.uid) ??
        false;

    final category = categories.firstWhere(
      (category) => category.id == advert.category,
      orElse:
          () => AdCategory(
            id: advert.category,
            nameEn: 'Unknown',
            nameKk: 'Белгісіз',
            nameRu: 'Неизвестно',
            imageUrl: '',
            settings: {},
          ),
    );

    bool _isNewAdvert(DateTime createdAt) {
      final now = DateTime.now();
      final difference = now.difference(createdAt);
      return difference.inHours < 24;
    }

    Future<void> _toggleFavourite() async {
      if (user == null) return;

      final notifier = ref.read(favouritesNotifierProvider.notifier);
      await notifier.toggleFavourite(userUid: user.uid, advertUid: advert.uid);
    }

    return GestureDetector(
      onTap: () {
        if (user != null && user.uid != advert.ownerUid) {
          ref.read(homeNotifierProvider.notifier).viewAdvert(advert.uid);
        }
        context.push(Routes.nestedAdvertDetailsPage, extra: advert);
      },
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: radius,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение
            AspectRatio(
              aspectRatio: 1.5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.inversePrimary.withOpacity(0.2),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: radius,
                      child:
                          advert.images.isNotEmpty
                              ? Image.network(
                                advert.images.first,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder:
                                    (_, __, ___) =>
                                        _buildPlaceholder(context, colorScheme),
                              )
                              : _buildPlaceholder(context, colorScheme),
                    ),
                  ),
                  if (advert.images.isNotEmpty)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            borderRadius: ResponsiveRadius.screenBased(context),
                          ),
                          child: Text(
                            advert.images.length.toString(),
                            style: contrastBoldM(context),
                          ),
                        ),
                      ),
                    ),

                  if (_isNewAdvert(advert.createdAt.toDate()))
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: radius.topLeft.x * 1,
                          vertical: radius.topLeft.y * 0.2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: ResponsiveRadius.screenBased(context),
                        ),
                        child: Text(
                          S.of(context).label_new_advert,
                          style: overGreenBoldM(context),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Текст и кнопки
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Текстовая информация
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          advert.title,
                          style: contrastBoldM(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${getRegionName(advert.region ?? 0)}, ${getDistrictName(advert.district ?? 0, advert.region ?? 0)}',
                          style: contrastM(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (advert.price != null && advert.price != 0) ...[
                          if (advert.maxPrice != null) ...[
                            Text(
                              'До ${advert.maxPrice} ₸',
                              style: contrastBoldM(context),
                            ),
                          ] else ...[
                            Text(
                              '${advert.price} ₸',
                              style: contrastBoldM(context),
                            ),
                          ],
                        ] else ...[
                          Text(
                            S.of(context).negotiable,
                            style: contrastBoldM(context),
                          ),
                        ],
                        Text(
                          getLocalizedCategory(category, context),
                          style: contrastM(context),
                          overflow: TextOverflow.ellipsis,

                          maxLines: 1,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                // Кнопка звонка
                Flexible(
                  flex: 3,
                  child: GestureDetector(
                    onTap:
                        () => launchUrl(Uri.parse('tel:${advert.phoneNumber}')),
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: radius,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.inversePrimary.withOpacity(0.2),
                            blurRadius: 4,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          S.of(context).call,
                          style: overGreenBoldM(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Кнопка избранного
                Flexible(
                  flex: 1,
                  child: GestureDetector(
                    onTap: user == null ? null : _toggleFavourite,
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: radius,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.inversePrimary.withOpacity(0.2),
                            blurRadius: 4,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          isFavourite
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                          color:
                              isFavourite
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = ResponsiveRadius.screenBased(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shimmer для изображения
        ShimmerEffect(
          width: double.infinity,
          height: 150,
          borderRadius: radius.topLeft.x,
        ),
        // Shimmer для текста и кнопок
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ShimmerEffect(width: 160, height: 16, borderRadius: 4),
              const SizedBox(height: 8),
              ShimmerEffect(width: 120, height: 14, borderRadius: 4),
              const SizedBox(height: 8),
              ShimmerEffect(width: 80, height: 16, borderRadius: 4),
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

  Widget _buildPlaceholder(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: ResponsiveRadius.screenBased(context),
        boxShadow: [
          BoxShadow(
            color: colorScheme.inversePrimary.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Icon(Icons.image, size: 50, color: colorScheme.primary),
    );
  }
}
