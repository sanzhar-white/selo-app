import 'dart:convert';
import 'package:equatable/equatable.dart';

class BaseCategory extends Equatable {
  final int id;

  const BaseCategory({required this.id});

  @override
  List<Object?> get props => [id];

  Map<String, dynamic> toMap() => {'id': id};

  factory BaseCategory.fromMap(Map<String, dynamic> map) {
    return BaseCategory(
      id: map['id'] is int ? map['id'] as int : int.parse(map['id'].toString()),
    );
  }

  String toJson() => json.encode(toMap());

  factory BaseCategory.fromJson(String source) =>
      BaseCategory.fromMap(json.decode(source));
}

class AdCategory extends BaseCategory {
  final String imageUrl;
  final String nameEn;
  final String nameRu;
  final String nameKk;
  final Map<String, bool> settings;

  const AdCategory({
    required int id,
    required this.imageUrl,
    required this.nameEn,
    required this.nameRu,
    required this.nameKk,
    required this.settings,
  }) : super(id: id);

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

  String toJson() => json.encode(toMap());

  factory AdCategory.fromJson(String source) =>
      AdCategory.fromMap(json.decode(source));
}

class PlaceCategory extends BaseCategory {
  final List<PlaceCategory>? subcategories;
  final String name;

  const PlaceCategory({required int id, this.subcategories, required this.name})
    : super(id: id);

  @override
  List<Object?> get props => super.props + [subcategories ?? [], name];

  @override
  Map<String, dynamic> toMap() => {
    ...super.toMap(),
    'subcategories': subcategories?.map((e) => e.toMap()).toList(),
    'name': name,
  };

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

  @override
  String toJson() => json.encode(toMap());

  factory PlaceCategory.fromJson(String source) =>
      PlaceCategory.fromMap(json.decode(source));
}
