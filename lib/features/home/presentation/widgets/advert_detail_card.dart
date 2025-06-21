import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/core/utils/utils.dart';
import 'package:selo/features/add/presentation/providers/categories_provider.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:selo/features/favourites/presentation/providers/index.dart';
import 'package:selo/features/authentication/presentation/provider/index.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/features/home/presentation/providers/index.dart';
import 'package:selo/shared/widgets/phone_show_bottom.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:selo/shared/models/user_model.dart';

class AdvertDetailCard extends ConsumerStatefulWidget {
  const AdvertDetailCard({super.key, required this.advert});

  final AdvertModel advert;

  @override
  ConsumerState<AdvertDetailCard> createState() => _AdvertDetailCardState();
}

class _AdvertDetailCardState extends ConsumerState<AdvertDetailCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fillAnimation;
  late UserModel? user;
  late List<AdCategory> categories;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fillAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
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

  bool _isNewAdvert(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
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
        userUid: user!.uid,
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
    final colorScheme = Theme.of(context).colorScheme;
    final radius = ResponsiveRadius.screenBased(context);
    final categories = ref.watch(categoriesNotifierProvider).valueOrNull ?? [];
    final user = ref.watch(userNotifierProvider).user;
    final isFavourite = ref
        .watch(favouriteStatusProvider)
        .contains(widget.advert.uid);
    final screenSize = MediaQuery.of(context).size;

    final category = categories.firstWhere(
      (category) => category.id == widget.advert.category,
      orElse:
          () => AdCategory(
            id: widget.advert.category,
            nameEn: 'Unknown',
            nameKk: 'Белгісіз',
            nameRu: 'Неизвестно',
            imageUrl: '',
            settings: {},
          ),
    );

    return GestureDetector(
      key: const Key('advert_detail_card'),
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
                            color: colorScheme.inversePrimary.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
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
                                      (context, url) => Container(
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
                                          Container(color: colorScheme.surface),
                                  fadeInDuration: const Duration(
                                    milliseconds: 300,
                                  ),
                                  fadeOutDuration: const Duration(
                                    milliseconds: 300,
                                  ),
                                  memCacheWidth:
                                      (MediaQuery.of(context).size.width * 1.5)
                                          .toInt(),
                                )
                                : Container(color: colorScheme.surface),
                      ),
                    ),
                  ),
                  if (widget.advert.images.isNotEmpty &&
                      widget.advert.images.length > 1)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            borderRadius: radius,
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
                          horizontal: radius.topLeft.x,
                          vertical: radius.topLeft.y * 0.2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: radius,
                        ),
                        child: Text(
                          S.of(context)!.label_new_advert,
                          style: overGreenBoldM(context),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                        if (widget.advert.price != null &&
                            widget.advert.price != 0)
                          if (widget.advert.maxPrice != null)
                            Text(
                              '${S.of(context)!.to} ${widget.advert.maxPrice} ₸',
                              style: contrastBoldM(context),
                            )
                          else
                            Text(
                              '${widget.advert.price} ₸',
                              style: contrastBoldM(context),
                            )
                        else
                          Text(
                            S.of(context)!.negotiable,
                            style: contrastBoldM(context),
                          ),
                        Text(
                          getLocalizedCategory(category, context),
                          style: contrastM(context),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        if (widget.advert.tradeable &&
                            category.settings['tradeable'] == true)
                          Text(
                            S.of(context)!.trade_possible,
                            style: contrastM(context),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        Text(
                          '${widget.advert.views} ${S.of(context)!.views}, ${widget.advert.createdAt.toDate().toLocal().toString().split(' ')[0]}',
                          style: contrastM(context),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Flexible(
                  flex: 3,
                  child: CallButton(
                    key: const Key('call_button'),
                    phoneNumber: widget.advert.phoneNumber,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 1,
                  child: GestureDetector(
                    key: const Key('favourite_button'),
                    onTap: user == null ? null : _toggleFavourite,
                    child: RepaintBoundary(
                      child: Container(
                        height: screenSize.height * 0.05,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: radius,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.inversePrimary.withOpacity(
                                0.2,
                              ),
                              blurRadius: 4,
                              offset: const Offset(0, 0),
                            ),
                          ],
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
                                      CupertinoIcons.heart,
                                      color: colorScheme.primary,
                                      size: 24,
                                    ),
                                    ClipRect(
                                      child: Align(
                                        alignment: Alignment.center,
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CallButton extends StatelessWidget {
  final String phoneNumber;
  const CallButton({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = ResponsiveRadius.screenBased(context);
    final screenSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => showPhoneBottomSheet(context, phoneNumber),
      child: RepaintBoundary(
        child: Container(
          height: screenSize.height * 0.05,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: colorScheme.inversePrimary.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 0),
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
