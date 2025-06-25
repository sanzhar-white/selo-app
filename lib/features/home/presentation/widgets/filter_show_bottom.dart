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

Future<SearchModel?> showCategoryFilterBottomSheet({
  required BuildContext context,
  required List<AdCategory> categories,
  SearchModel? currentFilters,
  required Function(SearchModel?) onApply,
}) async {
  int? selectedCategory = currentFilters?.category;
  final priceFromController = TextEditingController(
    text: currentFilters?.priceFrom?.toString() ?? '',
  );
  final priceToController = TextEditingController(
    text: currentFilters?.priceTo?.toString() ?? '',
  );
  String selectedRegion = currentFilters?.region?.toString() ?? '';
  String selectedCity = currentFilters?.district?.toString() ?? '';
  int selectedSorting = currentFilters?.sortBy ?? 0;

  final sortingOptions = {
    0: S.of(context).default_sorting,
    1: S.of(context).cheapest_first,
    2: S.of(context).most_expensive_first,
    3: S.of(context).newest_first,
    4: S.of(context).oldest_first,
  };

  SearchModel? result;
  final colorScheme = Theme.of(context).colorScheme;
  final radius = ResponsiveRadius.screenBased(context);

  await showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    backgroundColor: colorScheme.surface,
    shape: RoundedRectangleBorder(borderRadius: radius),
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.7,
    ),
    builder: (context) {
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
                      Text(S.of(context).filter, style: contrastBoldL(context)),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedCategory = null;
                            selectedRegion = '';
                            selectedCity = '';
                            selectedSorting = 0;
                            priceFromController.clear();
                            priceToController.clear();
                          });
                        },
                        child: Text(
                          S.of(context).reset,
                          style: TextStyle(color: colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(S.of(context).category, style: contrastBoldM(context)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.start,
                    children:
                        categories.map((category) {
                          final isSelected = selectedCategory == category.id;
                          return FilterChip(
                            label: Text(
                              getLocalizedCategory(category, context),
                              style:
                                  isSelected
                                      ? overGreenM(context)
                                      : contrastM(context),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedCategory = category.id;
                                } else {
                                  selectedCategory = null;
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
                        }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text(S.of(context).price, style: contrastBoldM(context)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          style: contrastBoldL(context),
                          controller: priceFromController,
                          hintText: S.of(context).from,
                          keyboardType: TextInputType.number,
                          theme: colorScheme,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          style: contrastBoldL(context),
                          controller: priceToController,
                          hintText: S.of(context).to,
                          keyboardType: TextInputType.number,
                          theme: colorScheme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(S.of(context).location, style: contrastBoldM(context)),
                  const SizedBox(height: 10),
                  LocationPicker(
                    locations: regions,
                    region: selectedRegion,
                    district: selectedCity,
                    regionLabel: S.of(context).region,
                    districtLabel: S.of(context).district,
                    showDistrict: true,
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
                  Text(S.of(context).sort, style: contrastBoldM(context)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    value: selectedSorting,
                    items:
                        sortingOptions.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value, style: contrastM(context)),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSorting = value!;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colorScheme.onSurface,
                      border: OutlineInputBorder(
                        borderRadius: radius,
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        result = SearchModel(
                          category: selectedCategory,
                          priceFrom: int.tryParse(priceFromController.text),
                          priceTo: int.tryParse(priceToController.text),
                          region: int.tryParse(selectedRegion),
                          district: int.tryParse(selectedCity),
                          sortBy: selectedSorting,
                        );
                        onApply(result);
                        context.pop();
                        ;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: radius),
                      ),
                      child: Text(
                        S.of(context).apply,
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

  return result;
}
