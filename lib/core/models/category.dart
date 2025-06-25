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

class AdCategory extends BaseCategory {
  const AdCategory({
    required super.id,
    required this.imageUrl,
    required this.nameEn,
    required this.nameRu,
    required this.nameKk,
    required this.settings,
  });

  factory AdCategory.fromMap(Map<String, dynamic> map) {
    return AdCategory(
      id: map['id'] is int ? map['id'] as int : int.parse(map['id'].toString()),
      imageUrl: map['imageUrl']?.toString() ?? '',
      nameEn: map['nameEn']?.toString() ?? '',
      nameRu: map['nameRu']?.toString() ?? '',
      nameKk: map['nameKk']?.toString() ?? '',
      settings:
          (map['settings'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as bool),
          ) ??
          {},
    );
  }

  factory AdCategory.fromJson(String source) =>
      AdCategory.fromMap(json.decode(source) as Map<String, dynamic>);
  final String imageUrl;
  final String nameEn;
  final String nameRu;
  final String nameKk;
  final Map<String, bool> settings;

  String getLocalizedCategory(BuildContext context) {
    final s = S.of(context)!;
    if (s.language_code == 'en') {
      return nameEn;
    } else if (s.language_code == 'ru') {
      return nameRu;
    } else if (s.language_code == 'kk') {
      return nameKk;
    }
    throw Exception("Didn't add the localisation correctly");
  }

  @override
  List<Object?> get props =>
      super.props + [imageUrl, nameEn, nameRu, nameKk, settings];

  @override
  Map<String, dynamic> toMap() => {
    ...super.toMap(),
    'imageUrl': imageUrl,
    'nameEn': nameEn,
    'nameRu': nameRu,
    'nameKk': nameKk,
    'settings': settings,
  };

  @override
  String toJson() => json.encode(toMap());
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
