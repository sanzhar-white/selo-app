import 'package:flutter/material.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/core/constants/regions_districts.dart';
import 'package:selo/core/constants/conditions.dart';

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

int getDistrictID(String name, int regionID) {
  return regions
          .firstWhere((element) => element.id == regionID)
          .subcategories
          ?.firstWhere((element) => element.name == name)
          .id ??
      0;
}

String getRegionName(int id) {
  return regions.firstWhere((element) => element.id == id).name;
}

String getDistrictName(int id, int regionID) {
  return regions
          .firstWhere((element) => element.id == regionID)
          .subcategories
          ?.firstWhere((element) => element.id == id)
          .name ??
      '';
}

String getConditionName(int id, BuildContext context) {
  final s = S.of(context);
  if (s.language_code == 'en') {
    return conditions.firstWhere((element) => element.id == id).nameEn;
  } else if (s.language_code == 'ru') {
    return conditions.firstWhere((element) => element.id == id).nameRu;
  } else if (s.language_code == 'kk') {
    return conditions.firstWhere((element) => element.id == id).nameKk;
  }
  throw Exception('Didn\'t add the localisation correctly');
}
