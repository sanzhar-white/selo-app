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

  const AdCategory({required int id, required this.imageUrl}) : super(id: id);

  @override
  List<Object?> get props => super.props + [imageUrl];

  Map<String, dynamic> toMap() => {...super.toMap(), 'imageUrl': imageUrl};

  factory AdCategory.fromMap(Map<String, dynamic> map) {
    return AdCategory(
      id: map['id'] is int ? map['id'] as int : int.parse(map['id'].toString()),
      imageUrl: map['imageUrl'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory AdCategory.fromJson(String source) =>
      AdCategory.fromMap(json.decode(source));
}

class PlaceCategory extends BaseCategory {
  final List<BaseCategory> subcategories;

  const PlaceCategory({required int id, required this.subcategories})
    : super(id: id);

  @override
  List<Object?> get props => super.props + [subcategories];

  @override
  Map<String, dynamic> toMap() => {
    ...super.toMap(),
    'subcategories': subcategories.map((e) => e.toMap()).toList(),
  };

  factory PlaceCategory.fromMap(Map<String, dynamic> map) {
    return PlaceCategory(
      id: map['id'] is int ? map['id'] as int : int.parse(map['id'].toString()),
      subcategories:
          (map['subcategories'] as List)
              .map((item) => BaseCategory.fromMap(item as Map<String, dynamic>))
              .toList(),
    );
  }

  @override
  String toJson() => json.encode(toMap());

  factory PlaceCategory.fromJson(String source) =>
      PlaceCategory.fromMap(json.decode(source));
}
