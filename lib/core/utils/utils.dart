import 'package:flutter/material.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/core/constants/regions_districts.dart';
import 'package:selo/core/constants/conditions.dart';
import 'package:intl/intl.dart';

String getLocalizedDisplayNameOfCategory(
  AdCategory category,
  BuildContext context,
) {
  final s = S.of(context)!;
  if (s.language_code == 'en') {
    return category.displayName.en;
  } else if (s.language_code == 'ru') {
    return category.displayName.ru;
  } else if (s.language_code == 'kk') {
    return category.displayName.kk;
  }
  throw Exception("Didn't add the localisation correctly");
}

String getLocalizedNameOfCategory(
  AdCategory category,
  BuildContext context,
  int? categoryId,
) {
  final s = S.of(context)!;

  // Если передан конкретный categoryId, ищем соответствующее имя
  if (categoryId != null) {
    final categoryIndex = category.ids.indexOf(categoryId);
    if (categoryIndex >= 0 && categoryIndex < category.names.length) {
      final localizedName = category.names[categoryIndex];
      if (s.language_code == 'en') {
        return localizedName.en;
      } else if (s.language_code == 'ru') {
        return localizedName.ru;
      } else if (s.language_code == 'kk') {
        return localizedName.kk;
      }
    }
  }

  // Если categoryId не найден или не передан, возвращаем displayName
  if (s.language_code == 'en') {
    return category.displayName.en;
  } else if (s.language_code == 'ru') {
    return category.displayName.ru;
  } else if (s.language_code == 'kk') {
    return category.displayName.kk;
  }

  throw Exception("Didn't add the localisation correctly");
}

String getLocalizedNameOfCategoryByIndex(
  AdCategory category,
  BuildContext context,
  int index,
) {
  final s = S.of(context)!;

  if (index >= 0 && index < category.names.length) {
    final localizedName = category.names[index];
    if (s.language_code == 'en') {
      return localizedName.en;
    } else if (s.language_code == 'ru') {
      return localizedName.ru;
    } else if (s.language_code == 'kk') {
      return localizedName.kk;
    }
  }

  // Fallback к displayName если индекс невалидный
  if (s.language_code == 'en') {
    return category.displayName.en;
  } else if (s.language_code == 'ru') {
    return category.displayName.ru;
  } else if (s.language_code == 'kk') {
    return category.displayName.kk;
  }

  throw Exception("Didn't add the localisation correctly");
}

String getLocalizedNameForCategoryId(
  AdCategory category,
  BuildContext context,
  int categoryId,
) {
  final categoryIndex = category.ids.indexOf(categoryId);
  if (categoryIndex >= 0) {
    return getLocalizedNameOfCategoryByIndex(category, context, categoryIndex);
  }
  // Fallback к displayName если categoryId не найден
  return getLocalizedDisplayNameOfCategory(category, context);
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
  final s = S.of(context)!;
  if (s.language_code == 'en') {
    return conditions.firstWhere((element) => element.id == id).names.en;
  } else if (s.language_code == 'ru') {
    return conditions.firstWhere((element) => element.id == id).names.ru;
  } else if (s.language_code == 'kk') {
    return conditions.firstWhere((element) => element.id == id).names.kk;
  }
  throw Exception("Didn't add the localisation correctly");
}

String formatPhoneNumber(String input) {
  final digits = input.replaceAll(RegExp(r'\D'), '');

  if (digits.isEmpty) return '';

  var cleanedDigits = digits;
  if (cleanedDigits.startsWith('8')) {
    cleanedDigits = '7${cleanedDigits.substring(1)}';
  } else if (!cleanedDigits.startsWith('7')) {
    cleanedDigits = '7$cleanedDigits';
  }

  if (cleanedDigits.length > 11) {
    cleanedDigits = cleanedDigits.substring(0, 11);
  }

  final effectiveDigits =
      cleanedDigits.length > 1 ? cleanedDigits.substring(1) : '';
  final buffer = StringBuffer('+7');

  if (effectiveDigits.isNotEmpty) {
    buffer.write(' (');
    if (effectiveDigits.length > 3) {
      buffer.write(effectiveDigits.substring(0, 3));
      buffer.write(')');
      if (effectiveDigits.length > 3) {
        buffer.write(' ');
        if (effectiveDigits.length > 6) {
          buffer.write(effectiveDigits.substring(3, 6));
          buffer.write(' ');
          buffer.write(effectiveDigits.substring(6));
        } else {
          buffer.write(effectiveDigits.substring(3));
        }
      }
    } else {
      buffer.write(effectiveDigits);
    }
  }

  return buffer.toString().trim();
}

String formatPriceWithSpaces(num price) {
  final numberFormat = NumberFormat('#,##0', 'ru_RU');
  return numberFormat.format(price);
}

String toRawPhone(String input) {
  final digits = input.replaceAll(RegExp(r'\\D'), '');
  if (digits.startsWith('8')) {
    return '+7${digits.substring(1)}';
  } else if (digits.startsWith('7')) {
    return '+7${digits.substring(1)}';
  } else if (digits.startsWith('9') && digits.length == 10) {
    return '+7$digits';
  } else if (digits.length == 11 && digits.startsWith('7')) {
    return '+7${digits.substring(1)}';
  }
  return '+$digits';
}

String formatPhoneNumberForUI(String input) {
  final digits = input.replaceAll(RegExp(r'\\D'), '');
  if (digits.length != 11) return input;
  final buffer = StringBuffer('+7 (');
  buffer.write(digits.substring(1, 4));
  buffer.write(') ');
  buffer.write(digits.substring(4, 7));
  buffer.write(' ');
  buffer.write(digits.substring(7, 11));
  return buffer.toString();
}
