import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:selo/core/constants/regions_districts.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/features/home/data/models/home_model.dart';
import 'package:selo/core/utils/utils.dart';
import 'package:selo/shared/widgets/custom_text_field.dart';
import 'package:selo/shared/widgets/location_picker.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/shared/widgets/show_bottom_picker.dart';

Future<SearchModel?> showCategoryFilterBottomSheet({
  required BuildContext context,
  required List<AdCategory> categories,
  required Function(SearchModel?) onApply,
  SearchModel? currentFilters,
}) async {
  Set<int> selectedCategories = <int>{};
  if (currentFilters?.categories != null) {
    selectedCategories = currentFilters!.categories!.toSet();
  }
  final priceFromController = TextEditingController(
    text: currentFilters?.priceFrom?.toString() ?? '',
  );
  final priceToController = TextEditingController(
    text: currentFilters?.priceTo?.toString() ?? '',
  );
  var selectedRegion = currentFilters?.region?.toString() ?? '';
  var selectedCity = currentFilters?.district?.toString() ?? '';
  var selectedSorting = currentFilters?.sortBy ?? 0;

  final sortingOptions = {
    0: S.of(context)!.default_sorting,
    1: S.of(context)!.cheapest_first,
    2: S.of(context)!.most_expensive_first,
    3: S.of(context)!.newest_first,
    4: S.of(context)!.oldest_first,
  };

  SearchModel? result;
  final colorScheme = Theme.of(context).colorScheme;
  final radius = ResponsiveRadius.screenBased(context);

  await showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(borderRadius: radius),
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.7,
    ),
    builder: (context) {
      return Builder(
        builder: (bottomSheetContext) {
          final colorScheme = Theme.of(bottomSheetContext).colorScheme;
          final radius = ResponsiveRadius.screenBased(bottomSheetContext);
          return StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  top: 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            S.of(context)!.filter,
                            style: contrastBoldL(context),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                selectedCategories.clear();
                                selectedRegion = '';
                                selectedCity = '';
                                selectedSorting = 0;
                                priceFromController.clear();
                                priceToController.clear();
                              });
                            },
                            child: Text(
                              S.of(context)!.reset,
                              style: TextStyle(color: colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        S.of(context)!.category,
                        style: contrastBoldM(context),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            categories.expand((category) {
                              return category.ids.map((categoryId) {
                                final isSelected = selectedCategories.contains(
                                  categoryId,
                                );

                                final categoryName =
                                    getLocalizedNameForCategoryId(
                                      category,
                                      context,
                                      categoryId,
                                    );

                                return FilterChip(
                                  label: Text(
                                    categoryName,
                                    style:
                                        isSelected
                                            ? overGreenM(context)
                                            : contrastM(context),
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        selectedCategories.add(categoryId);
                                      } else {
                                        selectedCategories.remove(categoryId);
                                      }
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: radius,
                                    side: const BorderSide(
                                      color: Colors.transparent,
                                      width: 0,
                                    ),
                                  ),
                                  backgroundColor: colorScheme.onSurface,
                                  selectedColor: colorScheme.primary,
                                  checkmarkColor: colorScheme.surface,
                                );
                              });
                            }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Text(S.of(context)!.price, style: contrastBoldM(context)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              style: contrastBoldL(context),
                              controller: priceFromController,
                              hintText: S.of(context)!.from,
                              keyboardType: TextInputType.number,
                              theme: colorScheme,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              style: contrastBoldL(context),
                              controller: priceToController,
                              hintText: S.of(context)!.to,
                              keyboardType: TextInputType.number,
                              theme: colorScheme,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        S.of(context)!.location,
                        style: contrastBoldM(context),
                      ),
                      const SizedBox(height: 10),
                      LocationPicker(
                        locations: regions,
                        region: selectedRegion,
                        district: selectedCity,
                        regionLabel: S.of(context)!.region,
                        districtLabel: S.of(context)!.district,
                        onRegionChanged: (region) {
                          setState(() {
                            selectedRegion = region;
                            selectedCity = '';
                          });
                        },
                        onDistrictChanged: (district) {
                          setState(() {
                            selectedCity = district;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(S.of(context)!.sort, style: contrastBoldM(context)),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          final selected = await showBottomPicker<int>(
                            context: context,
                            items: sortingOptions.keys.toList(),
                            itemBuilder:
                                (ctx, key) => Text(
                                  sortingOptions[key]!,
                                  style: contrastM(context),
                                ),
                            onItemSelected: (value) {
                              setState(() {
                                selectedSorting = value;
                              });
                            },
                            title: S.of(context)!.sort,
                          );
                          if (selected != null) {
                            setState(() {
                              selectedSorting = selected;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface,
                            borderRadius: radius,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                sortingOptions[selectedSorting]!,
                                style: contrastM(context),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            result = SearchModel(
                              categories:
                                  selectedCategories.isNotEmpty
                                      ? selectedCategories.toList()
                                      : null,
                              priceFrom: int.tryParse(priceFromController.text),
                              priceTo: int.tryParse(priceToController.text),
                              region: int.tryParse(selectedRegion),
                              district: int.tryParse(selectedCity),
                              sortBy: selectedSorting,
                            );
                            onApply(result);
                            context.pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: radius),
                          ),
                          child: Text(
                            S.of(context)!.apply,
                            style: TextStyle(color: colorScheme.onPrimary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );

  return result;
}
