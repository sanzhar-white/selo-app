import 'package:flutter/material.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/core/models/category.dart';

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
