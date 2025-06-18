import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/utils/utils.dart';
import 'package:selo/features/add/presentation/providers/categories_provider.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/features/favourites/presentation/providers/index.dart';
import 'package:selo/features/home/presentation/providers/index.dart';
import 'package:selo/features/authentication/presentation/provider/index.dart';
import 'package:selo/shared/widgets/phone_show_bottom.dart';

class AdvertDetailsPage extends ConsumerStatefulWidget {
  final AdvertModel advert;

  const AdvertDetailsPage({super.key, required this.advert});

  @override
  ConsumerState<AdvertDetailsPage> createState() => _AdvertDetailsPageState();
}

class _AdvertDetailsPageState extends ConsumerState<AdvertDetailsPage>
    with SingleTickerProviderStateMixin {
  bool isFavourite = false;
  bool _isTogglingFavourite = false;
  bool _isInitialized = false;
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _loadFavouriteStatus();
    }
  }

  Future<void> _loadFavouriteStatus() async {
    if (!mounted) return;

    final favourites = ref.read(favouritesNotifierProvider).favouritesModel;
    if (favourites != null) {
      setState(() {
        isFavourite = favourites.any((e) => e.uid == widget.advert.uid);
      });
    }
  }

  Future<void> _toggleFavourite() async {
    final user = ref.read(userNotifierProvider).user;
    if (user == null) return;

    setState(() {
      isFavourite = !isFavourite;
      _isTogglingFavourite = true;
      if (isFavourite) {
        _animationController.forward().then(
          (_) => _animationController.reverse(),
        );
      }
    });

    final notifier = ref.read(favouritesNotifierProvider.notifier);
    try {
      await notifier.toggleFavourite(
        userUid: user.uid,
        advertUid: widget.advert.uid,
      );
      if (mounted) {
        ref
            .read(homeNotifierProvider.notifier)
            .loadAllAdvertisements(refresh: true, page: 1, pageSize: 10);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isFavourite = !isFavourite;
        });
      }
      debugPrint('Error toggling favourite: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingFavourite = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categories = ref.watch(categoriesNotifierProvider).valueOrNull ?? [];
    final category = categories.firstWhere(
      (cat) => cat.id == widget.advert.category,
      orElse:
          () => AdCategory(
            id: -1,
            nameEn: '',
            nameRu: '',
            nameKk: '',
            imageUrl: '',
            settings: {},
          ),
    );

    return Scaffold(
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: [
          // Image section
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ImageCarousel(images: widget.advert.images),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: SafeArea(
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 1.0, end: 0.9).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOut,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: colorScheme.surface,
                            shadows: [
                              BoxShadow(
                                color: colorScheme.inversePrimary,
                                blurRadius: 50,
                              ),
                            ],
                          ),
                          onPressed: () {
                            _animationController.forward().then((_) {
                              _animationController.reverse();
                              context.pop();
                              ;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: SafeArea(
                      child: Row(
                        children: [
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: RotationTransition(
                              turns: _rotationAnimation,
                              child: IconButton(
                                onPressed:
                                    _isTogglingFavourite
                                        ? null
                                        : _toggleFavourite,
                                icon:
                                    _isTogglingFavourite
                                        ? const SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                        : Icon(
                                          isFavourite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color:
                                              isFavourite
                                                  ? Colors.red
                                                  : colorScheme.surface,
                                          size: 28,
                                          shadows: [
                                            BoxShadow(
                                              color: colorScheme.inversePrimary,
                                              blurRadius: 50,
                                            ),
                                          ],
                                        ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.share,
                              color: colorScheme.surface,
                              shadows: [
                                BoxShadow(
                                  color: colorScheme.inversePrimary,
                                  blurRadius: 50,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Main content
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and location
                    Text(
                      widget.advert.title,
                      style: contrastBoldM(context).copyWith(fontSize: 22),
                      semanticsLabel: S.of(context).title_of_ad,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${getRegionName(widget.advert.region ?? 0)}, ${getDistrictName(widget.advert.district ?? 0, widget.advert.region ?? 0)}',
                          style: grayM(context),
                          semanticsLabel: S.of(context).location,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Price section
                    if (category.settings['pricePer'] == true ||
                        category.settings['salary'] == true ||
                        widget.advert.price != 0 ||
                        widget.advert.maxPrice != null) ...[
                      _PriceCard(
                        advert: widget.advert,
                        category: category,
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Details
                    _DetailsCard(
                      advert: widget.advert,
                      category: category,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 12),
                    // Quantity
                    if (category.settings['quantity'] == true ||
                        category.settings['maxQuantity'] == true) ...[
                      _QuantityCard(
                        advert: widget.advert,
                        category: category,
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Item details
                    if (category.settings['condition'] == true ||
                        category.settings['year'] == true) ...[
                      _ItemDetailsCard(
                        advert: widget.advert,
                        category: category,
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Description
                    _DescriptionCard(
                      advert: widget.advert,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 12),
                    // Stats
                    _StatsCard(advert: widget.advert, colorScheme: colorScheme),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      // Floating action button (Call button)
      floatingActionButton: _ActionBar(
        colorScheme: colorScheme,
        onCall: () {
          showPhoneBottomSheet(context, widget.advert.phoneNumber);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }
}

// Image carousel
class _ImageCarousel extends StatelessWidget {
  final List<String> images;

  const _ImageCarousel({required this.images});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return images.isEmpty
        ? Container(
          color: colorScheme.onSurface.withOpacity(0.1),
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              size: 48,
              color: Colors.grey,
            ),
          ),
        )
        : Stack(
          children: [
            PageView.builder(
              itemCount: images.length,
              itemBuilder:
                  (context, index) => CachedNetworkImage(
                    imageUrl: images[index],
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(
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
                          color: colorScheme.onSurface.withOpacity(0.1),
                          child: const Center(
                            child: Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                          ),
                        ),
                    fadeInDuration: const Duration(milliseconds: 300),
                    fadeOutDuration: const Duration(milliseconds: 300),
                    memCacheWidth:
                        (MediaQuery.of(context).size.width * 1.5).toInt(),
                    memCacheHeight:
                        (MediaQuery.of(context).size.height * 0.4 * 1.5)
                            .toInt(),
                  ),
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
  }
}

// Price card
class _PriceCard extends StatelessWidget {
  final AdvertModel advert;
  final AdCategory category;
  final ColorScheme colorScheme;

  const _PriceCard({
    required this.advert,
    required this.category,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final radius = ResponsiveRadius.screenBased(context);
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: radius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).price,
              style: greenBoldM(context).copyWith(fontSize: 18),
              semanticsLabel: S.of(context).price,
            ),
            const SizedBox(height: 8),
            if (advert.price == 0)
              Text(
                S.of(context).negotiable,
                style: grayM(context).copyWith(fontSize: 16),
              )
            else ...[
              _PriceRange(
                minPrice: advert.price.toDouble(),
                maxPrice: (advert.maxPrice ?? advert.price).toDouble(),
                colorScheme: colorScheme,
              ),
              if (advert.tradeable &&
                  category.settings['tradeable'] == true) ...[
                const SizedBox(height: 8),
                Text(
                  S.of(context).trade_possible,
                  style: grayS(context).copyWith(color: colorScheme.secondary),
                  semanticsLabel: S.of(context).trade_possible,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// Price range
class _PriceRange extends StatelessWidget {
  final double minPrice;
  final double maxPrice;
  final ColorScheme colorScheme;

  const _PriceRange({
    required this.minPrice,
    required this.maxPrice,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '${S.of(context).from}: ${minPrice.toStringAsFixed(0)} ₸\n${S.of(context).to}: ${maxPrice.toStringAsFixed(0)} ₸',
      style: contrastBoldM(context),
    );
  }
}

// Details card
class _DetailsCard extends StatelessWidget {
  final AdvertModel advert;
  final AdCategory category;
  final ColorScheme colorScheme;

  const _DetailsCard({
    required this.advert,
    required this.category,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final radius = ResponsiveRadius.screenBased(context);
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: radius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).details,
              style: greenBoldM(context).copyWith(fontSize: 18),
              semanticsLabel: S.of(context).details,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              title: S.of(context).phone_number,
              value:
                  advert.phoneNumber.isNotEmpty
                      ? advert.phoneNumber
                      : S.of(context).unknown,
              isVisible: true,
              icon: Icons.phone,
              colorScheme: colorScheme,
              semanticsLabel: S.of(context).phone_number,
            ),
            _InfoRow(
              title: S.of(context).category,
              value:
                  getLocalizedCategory(category, context).isNotEmpty
                      ? getLocalizedCategory(category, context)
                      : S.of(context).unknown,
              isVisible: true,
              icon: Icons.category,
              colorScheme: colorScheme,
              semanticsLabel: S.of(context).category,
            ),
            _InfoRow(
              title: S.of(context).contact_person,
              value:
                  advert.contactPerson?.isNotEmpty == true
                      ? advert.contactPerson!
                      : S.of(context).unknown,
              isVisible: category.settings['contactPerson'] == true,
              icon: Icons.person,
              colorScheme: colorScheme,
              semanticsLabel: S.of(context).contact_person,
            ),
            _InfoRow(
              title: S.of(context).company,
              value:
                  advert.companyName?.isNotEmpty == true
                      ? advert.companyName!
                      : S.of(context).unknown,
              isVisible: category.settings['companyName'] == true,
              icon: Icons.business,
              colorScheme: colorScheme,
              semanticsLabel: S.of(context).company,
            ),
          ],
        ),
      ),
    );
  }
}

// Quantity card
class _QuantityCard extends StatelessWidget {
  final AdvertModel advert;
  final AdCategory category;
  final ColorScheme colorScheme;

  const _QuantityCard({
    required this.advert,
    required this.category,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final radius = ResponsiveRadius.screenBased(context);
    final unit = advert.unit ?? '';
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: radius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).quantity,
              style: greenBoldM(context).copyWith(fontSize: 18),
              semanticsLabel: S.of(context).quantity,
            ),
            const SizedBox(height: 12),
            if (category.settings['quantity'] == true &&
                advert.quantity != null &&
                advert.quantity! > 0 &&
                category.settings['maxQuantity'] == true &&
                advert.maxQuantity != null &&
                advert.maxQuantity! > 0)
              _QuantityTag(
                value:
                    '${S.of(context).from} ${advert.quantity} $unit \n${S.of(context).to} ${advert.maxQuantity} $unit',
                colorScheme: colorScheme,
              )
            else if (category.settings['quantity'] == true &&
                advert.quantity != null &&
                advert.quantity! > 0)
              _QuantityTag(
                value: '${advert.quantity} $unit',
                colorScheme: colorScheme,
              )
            else if (category.settings['maxQuantity'] == true &&
                advert.maxQuantity != null &&
                advert.maxQuantity! > 0)
              _QuantityTag(
                value: '${advert.maxQuantity} $unit',
                colorScheme: colorScheme,
              )
            else
              Text(
                S.of(context).unknown,
                style: grayM(context).copyWith(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}

// Quantity tag
class _QuantityTag extends StatelessWidget {
  final String value;
  final ColorScheme colorScheme;

  const _QuantityTag({required this.value, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [Text(value, style: contrastBoldM(context))],
      ),
    );
  }
}

// Item details card
class _ItemDetailsCard extends StatelessWidget {
  final AdvertModel advert;
  final AdCategory category;
  final ColorScheme colorScheme;

  const _ItemDetailsCard({
    required this.advert,
    required this.category,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final radius = ResponsiveRadius.screenBased(context);
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: radius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).item_details,
              style: greenBoldM(context).copyWith(fontSize: 18),
              semanticsLabel: S.of(context).item_details,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              title: S.of(context).condition,
              value:
                  advert.condition != null && advert.condition != 0
                      ? getConditionName(advert.condition!, context)
                      : S.of(context).unknown,
              isVisible: category.settings['condition'] == true,
              icon: Icons.build,
              colorScheme: colorScheme,
              semanticsLabel: S.of(context).condition,
            ),
            _InfoRow(
              title: S.of(context).year_of_release,
              value:
                  advert.year != null && advert.year! > 0
                      ? advert.year.toString()
                      : S.of(context).unknown,
              isVisible: category.settings['year'] == true,
              icon: Icons.calendar_today,
              colorScheme: colorScheme,
              semanticsLabel: S.of(context).year_of_release,
            ),
          ],
        ),
      ),
    );
  }
}

// Description card
class _DescriptionCard extends StatelessWidget {
  final AdvertModel advert;
  final ColorScheme colorScheme;

  const _DescriptionCard({required this.advert, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final radius = ResponsiveRadius.screenBased(context);
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: radius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).description,
              style: greenBoldM(context).copyWith(fontSize: 18),
              semanticsLabel: S.of(context).description,
            ),
            const SizedBox(height: 12),
            Text(
              advert.description.isNotEmpty
                  ? advert.description
                  : S.of(context).unknown,
              style: grayM(context).copyWith(fontSize: 14, height: 1.6),
              semanticsLabel: S.of(context).description,
            ),
          ],
        ),
      ),
    );
  }
}

// Stats card
class _StatsCard extends StatelessWidget {
  final AdvertModel advert;
  final ColorScheme colorScheme;

  const _StatsCard({required this.advert, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final radius = ResponsiveRadius.screenBased(context);
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: radius,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.remove_red_eye,
                  size: 16,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 4),
                Semantics(
                  label: S.of(context).views,
                  child: Text(
                    '${advert.views} ${S.of(context).views}',
                    style: grayS(context),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.favorite, size: 16, color: colorScheme.secondary),
                const SizedBox(width: 4),
                Semantics(
                  label: S.of(context).likes,
                  child: Text(
                    '${advert.likes} ${S.of(context).likes}',
                    style: grayS(context),
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

// Action bar
class _ActionBar extends StatelessWidget {
  final ColorScheme colorScheme;
  final VoidCallback onCall;

  const _ActionBar({required this.colorScheme, required this.onCall});

  @override
  Widget build(BuildContext context) {
    return _ActionButton(
      icon: Icons.call,
      label: S.of(context).call,
      onTap: onCall,
      colorScheme: colorScheme,
    );
  }
}

// Action button
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final radius = ResponsiveRadius.screenBased(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: radius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(icon, size: 30, color: Colors.white)],
        ),
      ),
    );
  }
}

// Info row
class _InfoRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isVisible;
  final IconData? icon;
  final ColorScheme colorScheme;
  final String semanticsLabel;

  const _InfoRow({
    required this.title,
    required this.value,
    required this.isVisible,
    this.icon,
    required this.colorScheme,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible || value.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Semantics(
        label: semanticsLabel,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: colorScheme.secondary),
              const SizedBox(width: 12),
            ],
            Text('$title: ', style: greenBoldM(context).copyWith(fontSize: 16)),
            Expanded(
              child: Text(
                value,
                style: contrastM(context).copyWith(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
