import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:selo/generated/l10n.dart';

class BaseCategory extends Equatable {
  const BaseCategory({required this.id});

  factory BaseCategory.fromMap(Map<String, dynamic> map) {
    return BaseCategory(
      id: map['id'] is int ? map['id'] as int : int.parse(map['id'].toString()),
    );
  }

  factory BaseCategory.fromJson(String source) =>
      BaseCategory.fromMap(json.decode(source) as Map<String, dynamic>);
  final int id;

  @override
  List<Object?> get props => [id];

  Map<String, dynamic> toMap() => {'id': id};

  String toJson() => json.encode(toMap());
}

class LocalizedText {
  final String en;
  final String kk;
  final String ru;

  const LocalizedText({
    required this.en,
    required this.kk,
    required this.ru,
  });
  factory LocalizedText.fromMap(Map<String, dynamic> map) {
    return LocalizedText(
      en: map['en']?.toString() ?? '',
      kk: map['kk']?.toString() ?? '',
      ru: map['ru']?.toString() ?? '',
    );
  }
}

class AdCategoryItemSettings {
  final bool maxPrice;
  final bool quantity;
  final bool maxQuantity;
  final bool salary;
  final bool pricePer;
  final bool contactPerson;
  final bool condition;
  final bool year;
  final bool tradeable;
  final bool companyName;

  const AdCategoryItemSettings({
    required this.maxPrice,
    required this.quantity,
    required this.maxQuantity,
    required this.salary,
    required this.pricePer,
    required this.contactPerson,
    required this.condition,
    required this.year,
    required this.tradeable,
    required this.companyName,
  });

  factory AdCategoryItemSettings.fromMap(Map<String, dynamic> map) {
    return AdCategoryItemSettings(
      maxPrice: map['maxPrice'] as bool? ?? false,
      quantity: map['quantity'] as bool? ?? false,
      maxQuantity: map['maxQuantity'] as bool? ?? false,
      salary: map['salary'] as bool? ?? false,
      pricePer: map['pricePer'] as bool? ?? false,
      contactPerson: map['contactPerson'] as bool? ?? false,
      condition: map['condition'] as bool? ?? false,
      year: map['year'] as bool? ?? false,
      tradeable: map['tradeable'] as bool? ?? false,
      companyName: map['companyName'] as bool? ?? false,
    );
  }
}

class AdCategory {
  final LocalizedText displayName;
  final List<int> ids;
  final List<String> images;
  final String displayImage;
  final List<LocalizedText> names;
  final List<AdCategoryItemSettings> settings;

  const AdCategory({
    required this.displayName,
    required this.ids,
    required this.images,
    required this.displayImage,
    required this.names,
    required this.settings,
  });

  factory AdCategory.fromMap(Map<String, dynamic> map) {
    final idsMap = map['ids'] as Map<String, dynamic>? ?? {};
    final imagesMap = map['images'] as Map<String, dynamic>? ?? {};
    final namesMap = map['names'] as Map<String, dynamic>? ?? {};
    final settingsMap = map['settings'] as Map<String, dynamic>? ?? {};

    // Извлекаем display_image из imagesMap
    final displayImage = imagesMap['display_image']?.toString() ?? '';

    // Фильтруем images, исключая display_image
    final images = <String>[];
    for (final entry in imagesMap.entries) {
      if (entry.key != 'display_image') {
        images.add(entry.value.toString());
      }
    }

    // Извлекаем display_name из namesMap
    final displayNameMap =
        namesMap['display_name'] as Map<String, dynamic>? ?? {};
    final displayName = LocalizedText.fromMap(displayNameMap);

    // Фильтруем names, исключая display_name
    final names = <LocalizedText>[];
    for (final entry in namesMap.entries) {
      if (entry.key != 'display_name') {
        names.add(LocalizedText.fromMap(entry.value as Map<String, dynamic>));
      }
    }

    return AdCategory(
      displayName: displayName,
      ids: idsMap.values.map((e) => e as int).toList(),
      images: images,
      displayImage: displayImage,
      names: names,
      settings:
          settingsMap.values
              .map(
                (e) =>
                    AdCategoryItemSettings.fromMap(e as Map<String, dynamic>),
              )
              .toList(),
    );
  }
}

class PlaceCategory extends BaseCategory {
  const PlaceCategory({
    required super.id,
    required this.name,
    this.subcategories,
  });

  factory PlaceCategory.fromMap(Map<String, dynamic> map) {
    List<PlaceCategory>? subcategoriesList;
    if (map['subcategories'] != null) {
      subcategoriesList =
          (map['subcategories'] as List)
              .map(
                (item) => PlaceCategory.fromMap(item as Map<String, dynamic>),
              )
              .toList();
    }

    return PlaceCategory(
      id: map['id'] is int ? map['id'] as int : int.parse(map['id'].toString()),
      subcategories: subcategoriesList,
      name: map['name']?.toString() ?? '',
    );
  }

  factory PlaceCategory.fromJson(String source) =>
      PlaceCategory.fromMap(json.decode(source) as Map<String, dynamic>);
  final List<PlaceCategory>? subcategories;
  final String name;

  @override
  List<Object?> get props => super.props + [subcategories ?? [], name];

  @override
  Map<String, dynamic> toMap() => {
    ...super.toMap(),
    'subcategories': subcategories?.map((e) => e.toMap()).toList(),
    'name': name,
  };

  @override
  String toJson() => json.encode(toMap());
}

class ConditionType extends BaseCategory {
  final LocalizedText names;
  const ConditionType({
    required super.id,
    required this.names,
  });
}
