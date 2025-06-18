import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/features/home/data/models/home_model.dart';

class BannersBodyWidget extends StatefulWidget {
  const BannersBodyWidget({
    super.key,
    required this.banners,
    this.autoPlayInterval = const Duration(seconds: 10),
  });

  final List<BannerModel> banners;
  final Duration autoPlayInterval;

  @override
  State<BannersBodyWidget> createState() => _BannersBodyWidgetState();
}

class _BannersBodyWidgetState extends State<BannersBodyWidget> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(), // или можно показать заглушку
      );
    }

    return SliverToBoxAdapter(
      child: Column(
        children: [
          CarouselSlider.builder(
            itemCount: widget.banners.length,
            itemBuilder: (context, index, realIdx) {
              final banner = widget.banners[index];
              return _CarouselItem(banner: banner);
            },
            options: CarouselOptions(
              aspectRatio: 16 / 9,
              viewportFraction: 0.9,
              autoPlay: true,
              autoPlayInterval: widget.autoPlayInterval,
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                setState(() => _currentIndex = index);
              },
            ),
          ),
          const SizedBox(height: 8),
          _CarouselDotsIndicator(
            count: widget.banners.length,
            activeIndex: _currentIndex,
          ),
        ],
      ),
    );
  }
}

class _CarouselItem extends StatelessWidget {
  const _CarouselItem({required this.banner});

  final BannerModel banner;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final radius = ResponsiveRadius.screenBased(context);
    return GestureDetector(
      onTap: banner.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: radius,
          color: colorScheme.surface,
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: radius,
              child: buildImageWidget(
                banner.imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                context: context,
              ),
            ),
            if (banner.title != null || banner.description != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: radius,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (banner.title != null)
                        Text(
                          banner.title!,
                          style: contrastBoldM(
                            context,
                          ).copyWith(color: Colors.white),
                        ),
                      if (banner.description != null)
                        Text(
                          banner.description!,
                          style: contrastM(
                            context,
                          ).copyWith(color: Colors.white70),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CarouselDotsIndicator extends StatelessWidget {
  const _CarouselDotsIndicator({
    required this.count,
    required this.activeIndex,
  });

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? colorScheme.primary : Colors.grey,
          ),
        );
      }),
    );
  }
}

Widget buildImageWidget(
  String imageUrl, {
  double? height,
  double? width,
  BoxFit? fit = BoxFit.contain,
  required BuildContext context,
}) {
  if (imageUrl.isEmpty) {
    return _placeholderImage(height, width, context);
  }

  if (imageUrl.toLowerCase().endsWith('.svg')) {
    return SvgPicture.asset(
      imageUrl,
      height: height,
      width: width,
      fit: fit ?? BoxFit.contain,
    );
  }

  if (imageUrl.startsWith('http')) {
    final colorScheme = Theme.of(context).colorScheme;
    return Image.network(
      imageUrl,
      height: height,
      width: width,
      fit: fit ?? BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: height,
          width: width,
          color: colorScheme.surface,
          child: Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
            ),
          ),
        );
      },
      errorBuilder:
          (context, error, stackTrace) =>
              _placeholderImage(height, width, context),
    );
  }

  return Image.asset(imageUrl, height: height, width: width, fit: fit);
}

Widget _placeholderImage(double? height, double? width, BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  return Container(
    height: height,
    width: width,
    color: colorScheme.onSurface,
    child: Icon(
      Icons.image_not_supported_outlined,
      color: colorScheme.inversePrimary,
      size: 40,
    ),
  );
}
