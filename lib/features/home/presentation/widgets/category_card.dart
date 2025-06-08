import 'package:flutter/material.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/core/utils/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/features/home/presentation/providers/home_provider.dart';
import 'package:selo/features/home/data/models/home_model.dart';
import 'package:go_router/go_router.dart';
import 'package:selo/core/constants/routes.dart';

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
            // Фото — снизу слева
            Align(
              alignment: Alignment.bottomRight,
              child:
                  category.imageUrl != ''
                      ? Image.network(
                        category.imageUrl,
                        width: 100,
                        height: 60,
                        fit: BoxFit.contain,
                      )
                      : const Icon(Icons.category_outlined, size: 60),
            ),

            // Текст — сверху справа
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
