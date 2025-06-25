import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

class AdvertMiniCard extends ConsumerStatefulWidget {
  const AdvertMiniCard({
    required this.advert,
    super.key,
    this.isLoading = false,
  });

  final AdvertModel advert;
  final bool isLoading;

  @override
  ConsumerState<AdvertMiniCard> createState() => _AdvertMiniCardState();
}

class _AdvertMiniCardState extends ConsumerState<AdvertMiniCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fillAnimation;
  Animation<Color?>? _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fillAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final colorScheme = Theme.of(context).colorScheme;
    _colorAnimation = ColorTween(
      begin: colorScheme.primary,
      end: Theme.of(context).colorScheme.error,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _isNewAdvert(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }

  Future<void> _toggleFavourite() async {
    final user = ref.read(userNotifierProvider).user;
    if (user == null) return;

    final notifier = ref.read(favouritesNotifierProvider.notifier);
    final isFavourite = ref
        .read(favouriteStatusProvider)
        .contains(widget.advert.uid);

    ref
        .read(favouriteStatusProvider.notifier)
        .toggleFavourite(widget.advert.uid);

    try {
      await notifier.toggleFavourite(
        userUid: user.uid,
        advertUid: widget.advert.uid,
      );
    } catch (e) {
      ref
          .read(favouriteStatusProvider.notifier)
          .toggleFavourite(widget.advert.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildShimmerCard(context);
    }

    final isFavourite = ref
        .watch(favouriteStatusProvider)
        .contains(widget.advert.uid);

    if (isFavourite) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final radius = ResponsiveRadius.screenBased(context);
    final categories = ref.watch(categoriesNotifierProvider).valueOrNull ?? [];
    final user = ref.watch(userNotifierProvider).user;

    final category = categories.firstWhere(
      (category) => category.id == widget.advert.category,
      orElse:
          () => AdCategory(
            id: widget.advert.category,
            nameEn: 'Unknown',
            nameKk: 'Белгісіз',
            nameRu: 'Неизвестно',
            imageUrl: '',
            settings: const {},
          ),
    );

    return GestureDetector(
      key: const Key('advert_mini_card'),
      onTap: () {
        if (user != null && user.uid != widget.advert.ownerUid) {
          ref.read(homeNotifierProvider.notifier).viewAdvert(widget.advert.uid);
        }
        context.push(Routes.nestedAdvertDetailsPage, extra: widget.advert);
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
            // Image section
            AspectRatio(
              aspectRatio: 1.5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RepaintBoundary(
                    child: Container(
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
                                ? Image.network(
                                  widget.advert.images.first,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder:
                                      (_, __, ___) => _buildPlaceholder(
                                        context,
                                        colorScheme,
                                      ),
                                )
                                : _buildPlaceholder(context, colorScheme),
                      ),
                    ),
                  ),
                  if (widget.advert.images.isNotEmpty &&
                      widget.advert.images.length > 1)
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
                            color: colorScheme.onSurface.withOpacity(0.7),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          child: Text(
                            widget.advert.images.length.toString(),
                            style: contrastBoldM(context),
                          ),
                        ),
                      ),
                    ),
                  if (_isNewAdvert(widget.advert.createdAt.toDate()))
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
                          S.of(context)!.label_new_advert,
                          style: overGreenBoldM(context),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      key: const Key('mini_favourite_button'),
                      onTap: _toggleFavourite,
                      child: RepaintBoundary(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: radius,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.inversePrimary.withOpacity(
                                  0.1,
                                ),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.heart,
                                      color: colorScheme.primary,
                                      size: 26,
                                    ),
                                    ClipRect(
                                      child: Align(
                                        widthFactor: _fillAnimation.value,
                                        child: Icon(
                                          CupertinoIcons.heart_fill,
                                          color: colorScheme.error,
                                          size: 26,
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
            // Text and buttons
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text information
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.advert.title,
                          style: contrastBoldM(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${getRegionName(widget.advert.region ?? 0)}, ${getDistrictName(widget.advert.district ?? 0, widget.advert.region ?? 0)}',
                          style: contrastM(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.advert.price != 0) ...[
                          if (widget.advert.maxPrice != null) ...[
                            Text(
                              '${S.of(context)!.to} ${widget.advert.maxPrice} ₸',
                              style: contrastBoldM(context),
                            ),
                          ] else ...[
                            Text(
                              '${widget.advert.price} ₸',
                              style: contrastBoldM(context),
                            ),
                          ],
                        ] else ...[
                          Text(
                            S.of(context)!.negotiable,
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
                // Call button
                Flexible(
                  flex: 3,
                  child: CallButton(
                    key: const Key('mini_call_button'),
                    phoneNumber: widget.advert.phoneNumber,
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
        // Shimmer for image
        ShimmerEffect(
          width: double.infinity,
          height: 150,
          borderRadius: radius.topLeft.x,
        ),
        // Shimmer for text and buttons
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              const ShimmerEffect(width: 160, height: 16, borderRadius: 4),
              const SizedBox(height: 8),
              const ShimmerEffect(width: 120, height: 14, borderRadius: 4),
              const SizedBox(height: 8),
              const ShimmerEffect(width: 80, height: 16, borderRadius: 4),
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
          ),
        ],
      ),
      child: Icon(Icons.image, size: 50, color: colorScheme.primary),
    );
  }
}

class CallButton extends StatelessWidget {
  const CallButton({required this.phoneNumber, super.key});
  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = ResponsiveRadius.screenBased(context);
    final screenSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => showPhoneBottomSheet(context, phoneNumber),
      child: RepaintBoundary(
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: colorScheme.inversePrimary.withOpacity(0.2),
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
    );
  }
}
