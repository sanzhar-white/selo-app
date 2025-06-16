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
  Animation<Color?>? _colorAnimation;
  bool _isFavourite = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    final favouritesState = ref.read(favouritesNotifierProvider);
    _isFavourite =
        favouritesState.favouritesModel?.any(
          (e) => e.uid == widget.advert.uid,
        ) ??
        false;
    if (_isFavourite) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final colorScheme = Theme.of(context).colorScheme;
    _colorAnimation = ColorTween(
      begin: colorScheme.primary,
      end: Colors.red,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavourite() async {
    final user = ref.read(userNotifierProvider).user;
    if (user == null) return;

    setState(() {
      _isFavourite = !_isFavourite;
      if (_isFavourite) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });

    final notifier = ref.read(favouritesNotifierProvider.notifier);
    try {
      await notifier.toggleFavourite(
        userUid: user.uid,
        advertUid: widget.advert.uid,
      );
    } catch (e) {
      setState(() {
        _isFavourite = !_isFavourite;
        if (_isFavourite) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = ResponsiveRadius.screenBased(context);
    final categories = ref.watch(categoriesNotifierProvider).valueOrNull ?? [];
    final user = ref.watch(userNotifierProvider).user;
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

    bool _isNewAdvert(DateTime createdAt) {
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
                  Container(
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
                                      color: colorScheme.onSurface.withOpacity(
                                        0.1,
                                      ),
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
                          horizontal: radius.topLeft.x,
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
                              'До ${widget.advert.maxPrice} ₸',
                              style: contrastBoldM(context),
                            )
                          else
                            Text(
                              '${widget.advert.price} ₸',
                              style: contrastBoldM(context),
                            )
                        else
                          Text(
                            S.of(context).negotiable,
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
                            S.of(context).trade_possible,
                            style: contrastM(context),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        Text(
                          '${widget.advert.views} ${S.of(context).views}, ${widget.advert.createdAt.toDate().toLocal().toString().split(' ')[0]}',
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
                  child: GestureDetector(
                    onTap: () {
                      showPhoneBottomSheet(context, widget.advert.phoneNumber);
                    },
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
                Flexible(
                  flex: 1,
                  child: GestureDetector(
                    onTap: user == null ? null : _toggleFavourite,
                    child: Container(
                      height: screenSize.height * 0.05,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
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
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Icon(
                                _isFavourite
                                    ? CupertinoIcons.heart_fill
                                    : CupertinoIcons.heart,
                                color:
                                    _colorAnimation?.value ??
                                    colorScheme.primary,
                                size: screenSize.height * 0.035,
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
          ],
        ),
      ),
    );
  }
}
