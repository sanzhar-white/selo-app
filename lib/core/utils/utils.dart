import 'package:flutter/material.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/core/constants/regions_districts.dart';

String getLocalizedCategory(AdCategory category, BuildContext context) {
  final s = S.of(context);
  if (s.language_code == 'en') {
    return category.nameEn;
  } else if (s.language_code == 'ru') {
    return category.nameRu;
  } else if (s.language_code == 'kk') {
    return category.nameKk;
  }
  throw Exception('Didn\'t add the localisation correctly');
}

int getRegionID(String name) {
  return regions.firstWhere((element) => element.name == name).id;
}

int getDistrictID(String name, int regionID, List<PlaceCategory> regions) {
  return regions
          .firstWhere((element) => element.id == regionID)
          .subcategories
          ?.firstWhere((element) => element.name == name)
          .id ??
      0;
}
