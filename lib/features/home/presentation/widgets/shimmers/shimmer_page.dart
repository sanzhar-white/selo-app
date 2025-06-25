import 'package:flutter/material.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/features/home/presentation/widgets/search_appbar.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/shared/widgets/shimmer_effect.dart';

class HomePageShimmer extends StatelessWidget {
  const HomePageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SearchAppBarWidget(
            searchQuery: TextEditingController(text: ''),
            onSearchSubmitted: (value) {},
            onFilterPressed: (value) {},
          ),
          const SliverToBoxAdapter(child: BannersBodyShimmer()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                S.of(context)!.all_categories,
                style: contrastBoldL(context),
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: _ShimmerCategories(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 16),
              child: Text(
                S.of(context)!.all_ads,
                style: contrastBoldL(context),
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            sliver: _ShimmerAdsList(),
          ),
        ],
      ),
    );
  }
}

class _ShimmerCategories extends StatelessWidget {
  const _ShimmerCategories();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const itemCount = 2;

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) => const ShimmerEffect(
          width: double.infinity,
          height: 60,
          borderRadius: 12,
        ),
        childCount: itemCount,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screenWidth > 600 ? 3 : 2,
        mainAxisSpacing: screenWidth * 0.05,
        crossAxisSpacing: screenWidth * 0.05,
        childAspectRatio: 1.8,
      ),
    );
  }
}

class _ShimmerAdsList extends StatelessWidget {
  const _ShimmerAdsList();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const itemCount = 6;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: EdgeInsets.only(bottom: screenWidth * 0.04),
          child: const ShimmerEffect(
            width: double.infinity,
            height: 200,
            borderRadius: 16,
          ),
        ),
        childCount: itemCount,
      ),
    );
  }
}

class BannersBodyShimmer extends StatelessWidget {
  const BannersBodyShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ShimmerEffect(
        width: double.infinity,
        height: MediaQuery.of(context).size.width * 0.5,
        borderRadius: 16,
      ),
    );
  }
}
