import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/utils/utils.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:selo/features/favourites/presentation/providers/favourites_provider.dart';
import 'package:selo/features/authentication/presentation/provider/authentication_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/features/add/presentation/providers/categories_provider.dart';
import 'package:selo/features/home/presentation/providers/home_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:selo/generated/l10n.dart';

class AdvertWideCard extends ConsumerStatefulWidget {
  const AdvertWideCard({super.key, required this.advert});

  final AdvertModel advert;

  @override
  ConsumerState<AdvertWideCard> createState() => _AdvertWideCardState();
}

class _AdvertWideCardState extends ConsumerState<AdvertWideCard> {
  dynamic user;
  List<AdCategory> categories = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      user = ref.watch(userNotifierProvider).user;
      categories = ref.watch(categoriesNotifierProvider).valueOrNull ?? [];
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
          borderRadius: ResponsiveRadius.screenBased(context),
        ),
        child: Row(
          children: [
            Flexible(
              flex: 1,
              child: AspectRatio(
                aspectRatio: screenSize.width * 2.1 / screenSize.height,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: ResponsiveRadius.screenBased(context),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.inversePrimary.withOpacity(0.2),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: ResponsiveRadius.screenBased(context),
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
                          if (widget.advert.images.isNotEmpty)
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
                                    color: colorScheme.onSurface.withOpacity(
                                      0.5,
                                    ),
                                    borderRadius: ResponsiveRadius.screenBased(
                                      context,
                                    ),
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
                              onTap:
                                  user == null
                                      ? null
                                      : () {
                                        ref
                                            .read(
                                              favouritesNotifierProvider
                                                  .notifier,
                                            )
                                            .toggleFavourite(
                                              userUid: user.uid,
                                              advertUid: widget.advert.uid,
                                            );
                                      },
                              child: Container(
                                height: 48,
                                width: 48,
                                margin: EdgeInsets.only(top: 10, left: 10),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: ResponsiveRadius.screenBased(
                                    context,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.inversePrimary
                                          .withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    size: screenSize.width * 0.08,
                                    CupertinoIcons.heart_fill,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.advert.title, style: contrastBoldM(context)),
                    Text(
                      '${getRegionName(widget.advert.region ?? 0)}\n${getDistrictName(widget.advert.district ?? 0, widget.advert.region ?? 0)}',
                      style: grayM(context),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    if (widget.advert.price != null &&
                        widget.advert.price != 0) ...[
                      if (widget.advert.maxPrice != null &&
                          widget.advert.maxPrice != 0) ...[
                        Text(
                          'До ${widget.advert.maxPrice.toString()} ₸',
                          style: contrastBoldM(context),
                        ),
                      ] else ...[
                        Text(
                          '${widget.advert.price.toString()} ₸',
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
                      style: grayM(context),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap:
                          () => launchUrl(
                            Uri.parse('tel:${widget.advert.phoneNumber}'),
                          ),
                      child: Container(
                        height: screenSize.height * 0.05,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: ResponsiveRadius.screenBased(context),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.inversePrimary.withOpacity(
                                0.2,
                              ),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
