// lib/features/add/presentation/pages/choose_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:selo/core/utils/utils.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/features/add/presentation/providers/categories_provider.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/generated/l10n.dart';
import 'package:flutter/cupertino.dart';

class ChoosePage extends ConsumerStatefulWidget {
  const ChoosePage({super.key});

  @override
  ConsumerState<ChoosePage> createState() => _ChoosePageState();
}

class _ChoosePageState extends ConsumerState<ChoosePage> {
  @override
  void initState() {
    super.initState();
    // Загружаем категории при инициализации
    Future.microtask(() {
      ref.read(categoriesNotifierProvider.notifier).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesNotifierProvider);
    final screenSize = MediaQuery.of(context).size;
    final crossAxisCount = screenSize.width > 800 ? 2 : 1;
    final crossAxisSpacing =
        screenSize.width > 800
            ? screenSize.width * 0.005
            : screenSize.width * 0.001;
    final mainAxisSpacing =
        screenSize.height > 800
            ? screenSize.height * 0
            : screenSize.height * 0.001;
    final childAspectRatio = screenSize.width > 800 ? 6.0 : 5.0;

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: categoriesState.when(
        data:
            (categories) => CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: colorScheme.surface,
                  expandedHeight:
                      screenSize.height > 800
                          ? screenSize.height * 0.1
                          : screenSize.height * 0.2,
                  toolbarHeight:
                      screenSize.height > 800
                          ? screenSize.height * 0.1
                          : screenSize.height * 0.2,
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Creating a new advert', style: contrastL(context)),
                      SizedBox(height: screenSize.height * 0.001),
                      Text(
                        'Choose category of your advert:',
                        style: contrastM(context),
                      ),
                    ],
                  ),
                ),
                SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: crossAxisSpacing,
                    mainAxisSpacing: mainAxisSpacing,
                    childAspectRatio: childAspectRatio,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final category = categories[index];
                    return GestureDetector(
                      onTap: () {
                        context.push(
                          Routes.nestedCreateAdvertPage,
                          extra: category,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: ResponsiveRadius.screenBased(context),
                          color: colorScheme.onSurface,
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.05,
                          vertical: screenSize.height * 0.01,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.05,
                          vertical: screenSize.height * 0.015,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.category_outlined,
                                  color: colorScheme.inversePrimary,
                                ),
                                SizedBox(width: screenSize.width * 0.03),
                                Text(
                                  getLocalizedCategory(category, context),
                                  style: greenM(
                                    context,
                                  ).copyWith(color: colorScheme.inversePrimary),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: colorScheme.inversePrimary,
                              size: 16,
                            ),
                          ],
                        ),
                      ),

                      // child: Card(
                      //   color:
                      //       selectedCategories.contains(category)
                      //           ? colorScheme.primary
                      //           : colorScheme.surface,
                      //   elevation: 10,
                      //   shadowColor: colorScheme.primary,
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: ResponsiveRadius.screenBased(context),
                      //   ),
                      //   child: Center(
                      //     child: Text(
                      //       getLocalizedCategory(category, context),
                      //       style: greenM(context).copyWith(
                      //         color:
                      //             selectedCategories.contains(category)
                      //                 ? colorScheme.onPrimary
                      //                 : null,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    );
                  }, childCount: categories.length),
                ),
                SliverFillRemaining(),
              ],
            ),
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SelectableText('Ошибка: $error', style: greenM(context)),
                  SelectableText(
                    'Местоположение: ${stack}',
                    style: greenM(context),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(categoriesNotifierProvider.notifier)
                          .refreshCategories();
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
