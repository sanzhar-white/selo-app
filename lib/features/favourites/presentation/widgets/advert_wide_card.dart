import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/core/utils/utils.dart';
import 'package:selo/features/add/presentation/providers/index.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/shared/widgets/shimmer_effect.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:selo/features/favourites/presentation/providers/index.dart';
import 'package:selo/features/authentication/presentation/provider/index.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/features/home/presentation/providers/index.dart';
import 'package:selo/shared/widgets/phone_show_bottom.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdvertWideCard extends ConsumerStatefulWidget {
  const AdvertWideCard({
    required this.advert,
    super.key,
    this.isLoading = false,
  });

  final AdvertModel advert;
  final bool isLoading;

  @override
  ConsumerState<AdvertWideCard> createState() => _AdvertWideCardState();
}

class _AdvertWideCardState extends ConsumerState<AdvertWideCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fillAnimation;
  dynamic user;
  List<AdCategory> categories = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.2, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fillAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      user = ref.read(userNotifierProvider).user;
      categories = ref.read(categoriesNotifierProvider).valueOrNull ?? [];
      final isFavourite = ref
          .read(favouriteStatusProvider)
          .contains(widget.advert.uid);
      if (isFavourite) {
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavourite() async {
    if (user == null) return;

    final isFavourite = ref
        .read(favouriteStatusProvider)
        .contains(widget.advert.uid);
    if (!isFavourite) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    final notifier = ref.read(favouritesNotifierProvider.notifier);
    try {
      await notifier.toggleFavourite(
        userUid: user.uid as String,
        advertUid: widget.advert.uid,
      );
    } catch (e) {
      if (!isFavourite) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = ResponsiveRadius.screenBased(context);
    if (widget.isLoading) {
      return _buildShimmerCard(context);
    }

    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final isFavourite = ref
        .watch(favouriteStatusProvider)
        .contains(widget.advert.uid);

    final category = categories.firstWhere(
      (category) => category.ids.contains(widget.advert.category),
      orElse:
          () => AdCategory(
            displayName: const LocalizedText(
              en: 'Unknown',
              kk: 'Белгісіз',
              ru: 'Неизвестно',
            ),
            ids: [widget.advert.category],
            images: [''],
            displayImage: '',
            names: const [],
            settings: const [],
          ),
    );

    bool isNewAdvert(DateTime createdAt) {
      final now = DateTime.now();
      final difference = now.difference(createdAt);
      return difference.inHours < 24;
    }

    return GestureDetector(
      onTap: () {
        if (user != null && user.uid != widget.advert.ownerUid) {
          ref.read(homeNotifierProvider.notifier).viewAdvert(widget.advert.uid);
        }
        context.push(Routes.nestedAdvertDetailsPage, extra: widget.advert);
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.05,
          vertical: screenSize.height * 0.01,
        ),
        width: screenSize.width,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: radius,
        ),
        child: Row(
          children: [
            Flexible(
              child: AspectRatio(
                aspectRatio: screenSize.width * 2.1 / screenSize.height,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.inversePrimary.withOpacity(0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: radius,
                        child:
                            widget.advert.images.isNotEmpty
                                ? CachedNetworkImage(
                                  imageUrl: widget.advert.images.first,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder:
                                      (context, url) => ColoredBox(
                                        color: colorScheme.onSurface
                                            .withOpacity(0.1),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.grey,
                                                ),
                                          ),
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) =>
                                          _buildPlaceholder(
                                            context,
                                            colorScheme,
                                          ),
                                  fadeInDuration: const Duration(
                                    milliseconds: 300,
                                  ),
                                  fadeOutDuration: const Duration(
                                    milliseconds: 300,
                                  ),
                                  memCacheWidth:
                                      (screenSize.width * 1.5).toInt(),
                                )
                                : _buildPlaceholder(context, colorScheme),
                      ),
                    ),
                    if (widget.advert.images.isNotEmpty)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.onSurface.withOpacity(0.5),
                              borderRadius: radius,
                            ),
                            child: Text(
                              widget.advert.images.length.toString(),
                              style: contrastBoldM(context),
                            ),
                          ),
                        ),
                      ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: user == null ? null : _toggleFavourite,
                        child: Container(
                          height: 48,
                          width: 48,
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: radius,
                          ),
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons.heart_fill,
                                        color: colorScheme.error,
                                        size: 24,
                                      ),
                                      ClipRect(
                                        child: Align(
                                          widthFactor: _fillAnimation.value,
                                          child: Icon(
                                            CupertinoIcons.heart_fill,
                                            color: colorScheme.error,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.advert.title,
                      style: contrastBoldM(context),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      '${getRegionName(widget.advert.region ?? 0)}\n${getDistrictName(widget.advert.district ?? 0, widget.advert.region ?? 0)}',
                      style: grayM(context),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    if (widget.advert.price != 0) ...[
                      if (widget.advert.maxPrice != null &&
                          widget.advert.maxPrice != 0) ...[
                        Text(
                          '${S.of(context)!.to} ${widget.advert.maxPrice} ₸',
                          style: contrastBoldM(context),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ] else ...[
                        Text(
                          '${formatPriceWithSpaces(widget.advert.price)} ₸',
                          style: contrastBoldM(context),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ] else ...[
                      Text(
                        S.of(context)!.negotiable,
                        style: contrastBoldM(context),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                    Text(
                      getLocalizedNameOfCategory(
                        category,
                        context,
                        widget.advert.category,
                      ),
                      style: grayM(context),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: () {
                              showPhoneBottomSheet(
                                context,
                                widget.advert.phoneNumber,
                              );
                            },
                            child: Container(
                              height: 32,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: radius,
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.inversePrimary
                                        .withOpacity(0.2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  S.of(context)!.call,
                                  style: overGreenBoldM(context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final radius = ResponsiveRadius.screenBased(context);

    return Row(
      children: [
        Flexible(
          child: AspectRatio(
            aspectRatio: screenSize.width * 2.1 / screenSize.height,
            child: ShimmerEffect(
              width: double.infinity,
              height: 150,
              borderRadius: radius.topLeft.x,
            ),
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerEffect(width: 160, height: 16, borderRadius: 4),
                const SizedBox(height: 8),
                const ShimmerEffect(width: 120, height: 14, borderRadius: 4),
                const SizedBox(height: 8),
                const ShimmerEffect(width: 80, height: 16, borderRadius: 4),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(
                      flex: 3,
                      child: ShimmerEffect(
                        width: 100,
                        height: 32,
                        borderRadius: radius.bottomLeft.x,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
          ),
        ],
      ),
      child: Icon(Icons.image, size: 50, color: colorScheme.primary),
    );
  }
}
