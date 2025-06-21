import 'package:flutter/material.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/core/constants/regions_districts.dart';
import 'package:selo/core/constants/conditions.dart';

String getLocalizedCategory(AdCategory category, BuildContext context) {
  final s = S.of(context)!;
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
  final s = S.of(context)!;
  if (s.language_code == 'en') {
    return conditions.firstWhere((element) => element.id == id).nameEn;
  } else if (s.language_code == 'ru') {
    return conditions.firstWhere((element) => element.id == id).nameRu;
  } else if (s.language_code == 'kk') {
    return conditions.firstWhere((element) => element.id == id).nameKk;
  }
  throw Exception('Didn\'t add the localisation correctly');
}

String formatPhoneNumber(String input) {
  final digits = input.replaceAll(RegExp(r'\D'), '');

  if (digits.isEmpty) return '';

  // Ensure the number starts with '7' and prepend '+7' if not, and limit to 11 digits
  String cleanedDigits = digits;
  if (cleanedDigits.startsWith('8')) {
    cleanedDigits = '7' + cleanedDigits.substring(1);
  } else if (!cleanedDigits.startsWith('7')) {
    cleanedDigits = '7' + cleanedDigits;
  }

  // Limit to a maximum of 11 digits (including the initial 7)
  if (cleanedDigits.length > 11) {
    cleanedDigits = cleanedDigits.substring(0, 11);
  }

  // Remove the initial '7' for formatting purposes
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
