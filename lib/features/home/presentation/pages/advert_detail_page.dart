import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/utils/utils.dart';
import 'package:selo/features/add/presentation/providers/categories_provider.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:selo/features/favourites/presentation/providers/favourites_provider.dart';
import 'package:selo/features/home/presentation/providers/home_provider.dart';
import 'package:selo/features/authentication/presentation/provider/authentication_provider.dart';

class AdvertDetailsPage extends ConsumerStatefulWidget {
  final AdvertModel advert;

  const AdvertDetailsPage({super.key, required this.advert});

  @override
  ConsumerState<AdvertDetailsPage> createState() => _AdvertDetailsPageState();
}

class _AdvertDetailsPageState extends ConsumerState<AdvertDetailsPage> {
  bool isFavourite = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isFavourite =
          ref
              .watch(favouritesNotifierProvider)
              .favouritesModel
              ?.any((e) => e.uid == widget.advert.uid) ??
          false;
    });
    print(isFavourite);
  }

  Future<void> _toggleFavourite() async {
    final user = ref.read(userNotifierProvider).user;
    if (user == null) {
      return;
    }
    final notifier = ref.read(favouritesNotifierProvider.notifier);
    await notifier.toggleFavourite(
      userUid: user.uid,
      advertUid: widget.advert.uid,
    );
    setState(() {
      isFavourite = !isFavourite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
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
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.advert.title, style: greenBoldM(context)),
        actions: [
          IconButton(
            onPressed: _toggleFavourite,
            icon: Icon(
              isFavourite ? Icons.favorite : Icons.favorite_border,
              color: colorScheme.primary,
              size: screenSize.width * 0.08,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.share, color: colorScheme.primary),
          ),
        ],
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.primary,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.04,
            vertical: screenSize.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ImageCarousel(images: widget.advert.images),
              SizedBox(height: screenSize.height * 0.02),
              if (category.settings['pricePer'] == true ||
                  category.settings['salary'] == true ||
                  widget.advert.price != 0 ||
                  widget.advert.price >= 0) ...[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          label: S.of(context).price,
                          child: Text(
                            widget.advert.price == 0
                                ? S.of(context).negotiable
                                : '${widget.advert.price.toStringAsFixed(0)} ₸',
                            style: greenBoldL(context).copyWith(fontSize: 24),
                          ),
                        ),
                        if (widget.advert.tradeable &&
                            category.settings['tradeable'] == true) ...[
                          const SizedBox(height: 4),
                          Semantics(
                            label: S.of(context).trade_possible,
                            child: Text(
                              S.of(context).trade_possible,
                              style: grayM(context).copyWith(fontSize: 14),
                            ),
                          ),
                        ],
                        if (category.settings['maxPrice'] == true &&
                            widget.advert.maxPrice != null &&
                            widget.advert.maxPrice! > 0) ...[
                          const SizedBox(height: 8),
                          Semantics(
                            label: S.of(context).max_price,
                            child: Text(
                              '${S.of(context).max_price}: ${widget.advert.maxPrice!.toStringAsFixed(0)} ₸',
                              style: contrastM(context).copyWith(fontSize: 16),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
              SizedBox(height: screenSize.height * 0.02),
              Semantics(
                label: S.of(context).title_of_ad,
                child: Text(widget.advert.title, style: contrastBoldM(context)),
              ),
              const SizedBox(height: 4),
              Semantics(
                label: S.of(context).location,
                child: Row(
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
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        label: S.of(context).details,
                        child: Text(
                          S.of(context).details,
                          style: greenBoldM(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        title: S.of(context).phone_number,
                        value:
                            widget.advert.phoneNumber.isNotEmpty
                                ? widget.advert.phoneNumber
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
                            widget.advert.contactPerson?.isNotEmpty == true
                                ? widget.advert.contactPerson!
                                : S.of(context).unknown,
                        isVisible: category.settings['contactPerson'] == true,
                        icon: Icons.person,
                        colorScheme: colorScheme,
                        semanticsLabel: S.of(context).contact_person,
                      ),
                      _InfoRow(
                        title: S.of(context).company,
                        value:
                            widget.advert.companyName?.isNotEmpty == true
                                ? widget.advert.companyName!
                                : S.of(context).unknown,
                        isVisible: category.settings['companyName'] == true,
                        icon: Icons.business,
                        colorScheme: colorScheme,
                        semanticsLabel: S.of(context).company,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),
              if (category.settings['quantity'] == true ||
                  category.settings['maxQuantity'] == true) ...[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          label: S.of(context).quantity,
                          child: Text(
                            S.of(context).quantity,
                            style: greenBoldM(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Semantics(
                          label:
                              '${S.of(context).quantity} and ${S.of(context).max_quantity}',
                          child: Row(
                            children: [
                              if (category.settings['quantity'] == true &&
                                  widget.advert.quantity != null &&
                                  widget.advert.quantity! > 0)
                                Text(
                                  '${S.of(context).quantity}: ${widget.advert.quantity} ${widget.advert.unit?.isNotEmpty == true ? widget.advert.unit! : ''}',
                                  style: contrastM(context),
                                ),
                              if (category.settings['quantity'] == true &&
                                  category.settings['maxQuantity'] == true &&
                                  widget.advert.quantity != null &&
                                  widget.advert.quantity! > 0 &&
                                  widget.advert.maxQuantity != null &&
                                  widget.advert.maxQuantity! > 0) ...[
                                const SizedBox(width: 8),
                                Text(' | ', style: grayM(context)),
                                const SizedBox(width: 8),
                              ],
                              if (category.settings['maxQuantity'] == true &&
                                  widget.advert.maxQuantity != null &&
                                  widget.advert.maxQuantity! > 0)
                                Text(
                                  '${S.of(context).max_quantity}: ${widget.advert.maxQuantity} ${widget.advert.unit?.isNotEmpty == true ? widget.advert.unit! : ''}',
                                  style: contrastM(context),
                                ),
                              if (!(category.settings['quantity'] == true &&
                                      widget.advert.quantity != null &&
                                      widget.advert.quantity! > 0) &&
                                  !(category.settings['maxQuantity'] == true &&
                                      widget.advert.maxQuantity != null &&
                                      widget.advert.maxQuantity! > 0))
                                Text(
                                  S.of(context).unknown,
                                  style: contrastM(context),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
              ],
              if (category.settings['condition'] == true ||
                  category.settings['year'] == true) ...[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          label: S.of(context).item_details,
                          child: Text(
                            S.of(context).item_details,
                            style: greenBoldM(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          title: S.of(context).condition,
                          value:
                              widget.advert.condition != null &&
                                      widget.advert.condition != 0
                                  ? getConditionName(
                                    widget.advert.condition!,
                                    context,
                                  )
                                  : S.of(context).unknown,
                          isVisible: category.settings['condition'] == true,
                          icon: Icons.build,
                          colorScheme: colorScheme,
                          semanticsLabel: S.of(context).condition,
                        ),
                        _InfoRow(
                          title: S.of(context).year_of_release,
                          value:
                              widget.advert.year != null &&
                                      widget.advert.year! > 0
                                  ? widget.advert.year.toString()
                                  : S.of(context).unknown,
                          isVisible: category.settings['year'] == true,
                          icon: Icons.calendar_today,
                          colorScheme: colorScheme,
                          semanticsLabel: S.of(context).year_of_release,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
              ],
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        label: S.of(context).description,
                        child: Text(
                          S.of(context).description,
                          style: greenBoldM(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Semantics(
                        label: S.of(context).description,
                        child: Text(
                          widget.advert.description.isNotEmpty
                              ? widget.advert.description
                              : S.of(context).unknown,
                          style: grayM(context).copyWith(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
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
                          '${widget.advert.views} ${S.of(context).views}',
                          style: grayS(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.favorite,
                        size: 16,
                        color: colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Semantics(
                        label: S.of(context).likes,
                        child: Text(
                          '${widget.advert.likes} ${S.of(context).likes}',
                          style: grayS(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageCarousel extends StatelessWidget {
  final List<String> images;

  const _ImageCarousel({required this.images});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 240,
          child:
              images.isEmpty
                  ? Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.1),
                    child: const Center(child: Icon(Icons.image_not_supported)),
                  )
                  : PageView.builder(
                    itemCount: images.length,
                    itemBuilder:
                        (context, index) =>
                            Image.network(images[index], fit: BoxFit.cover),
                  ),
        ),
      ),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Semantics(
        label: semanticsLabel,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: colorScheme.secondary),
              const SizedBox(width: 8),
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
