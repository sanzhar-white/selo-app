import 'package:flutter/material.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/core/utils/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/features/home/presentation/providers/index.dart';
import 'package:selo/features/home/data/models/home_model.dart';
import 'package:go_router/go_router.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CategoryCard extends ConsumerWidget {
  const CategoryCard({super.key, required this.category});
  final AdCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        final homeNotifier = ref.read(homeNotifierProvider.notifier);
        homeNotifier.loadFilteredAdvertisements(
          refresh: true,
          page: 1,
          pageSize: 10,
          filter: SearchModel(category: category.id),
        );
        context.push(
          Routes.nestedFilterPage,
          extra: {'searchQuery': '', 'initialCategoryId': category.id},
        );
      },
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.onSurface,
          borderRadius: ResponsiveRadius.screenBased(context),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomRight,
              child:
                  category.imageUrl != ''
                      ? CachedNetworkImage(
                        imageUrl: category.imageUrl,
                        width: 100,
                        height: 60,
                        fit: BoxFit.contain,
                        placeholder:
                            (context, url) => Container(
                              width: 100,
                              height: 60,
                              color: colorScheme.onSurface.withOpacity(0.1),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              width: 100,
                              height: 60,
                              color: colorScheme.inversePrimary,
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                        fadeInDuration: const Duration(milliseconds: 300),
                        fadeOutDuration: const Duration(milliseconds: 300),
                        memCacheWidth: 150,
                        memCacheHeight: 90,
                      )
                      : Icon(
                        Icons.category_outlined,
                        size: 60,
                        color: colorScheme.inversePrimary,
                      ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                getLocalizedCategory(category, context),
                style: contrastBoldM(context),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
