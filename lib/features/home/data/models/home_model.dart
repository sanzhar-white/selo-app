// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SearchModel extends Equatable {
  final String? searchQuery;
  final List<int>? categories;
  final int? district;
  final int? region;
  final int? priceFrom;
  final int? priceTo;
  final int? sortBy;

  const SearchModel({
    this.searchQuery,
    this.categories,
    this.district,
    this.region,
    this.priceFrom,
    this.priceTo,
    this.sortBy,
  });

  // Конструктор для обратной совместимости с одной категорией
  SearchModel.singleCategory({
    this.searchQuery,
    int? category, // Для обратной совместимости
    this.district,
    this.region,
    this.priceFrom,
    this.priceTo,
    this.sortBy,
  }) : categories = category != null ? [category] : null;

  SearchModel copyWith({
    Object? searchQuery = const _Unset(),
    Object? categories = const _Unset(),
    Object? district = const _Unset(),
    Object? region = const _Unset(),
    Object? priceFrom = const _Unset(),
    Object? priceTo = const _Unset(),
    Object? sortBy = const _Unset(),
  }) {
    return SearchModel(
      searchQuery:
          searchQuery is _Unset ? this.searchQuery : searchQuery as String?,
      categories:
          categories is _Unset ? this.categories : categories as List<int>?,
      district: district is _Unset ? this.district : district as int?,
      region: region is _Unset ? this.region : region as int?,
      priceFrom: priceFrom is _Unset ? this.priceFrom : priceFrom as int?,
      priceTo: priceTo is _Unset ? this.priceTo : priceTo as int?,
      sortBy: sortBy is _Unset ? this.sortBy : sortBy as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'searchQuery': searchQuery,
      'categories': categories,
      'district': district,
      'region': region,
      'priceFrom': priceFrom,
      'priceTo': priceTo,
      'sortBy': sortBy,
    };
  }

  factory SearchModel.fromMap(Map<String, dynamic> map) {
    return SearchModel(
      searchQuery:
          map['searchQuery'] != null ? map['searchQuery'] as String : null,
      categories:
          map['categories'] != null
              ? List<int>.from(map['categories'] as List)
              : null,
      district: map['district'] != null ? map['district'] as int : null,
      region: map['region'] != null ? map['region'] as int : null,
      priceFrom: map['priceFrom'] != null ? map['priceFrom'] as int : null,
      priceTo: map['priceTo'] != null ? map['priceTo'] as int : null,
      sortBy: map['sortBy'] != null ? map['sortBy'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SearchModel.fromJson(String source) =>
      SearchModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SearchModel(searchQuery: $searchQuery, categories: $categories, district: $district, region: $region, priceFrom: $priceFrom, priceTo: $priceTo, sortBy: $sortBy)';
  }

  @override
  List<Object?> get props => [
    searchQuery,
    categories,
    district,
    region,
    priceFrom,
    priceTo,
    sortBy,
  ];
}

class PaginationModel extends Equatable {
  final int currentPage;
  final int pageSize;
  final bool refresh;

  const PaginationModel({
    this.currentPage = 1,
    this.pageSize = 10,
    this.refresh = false,
  });

  PaginationModel copyWith({int? pageSize, int? currentPage, bool? refresh}) {
    return PaginationModel(
      pageSize: pageSize ?? this.pageSize,
      currentPage: currentPage ?? this.currentPage,
      refresh: refresh ?? this.refresh,
    );
  }

  @override
  List<Object?> get props => [currentPage, pageSize, refresh];
}

class BannerModel {
  final String imageUrl;
  final VoidCallback? onTap;
  final String? title;
  final String? description;

  const BannerModel({
    required this.imageUrl,
    this.onTap,
    this.title,
    this.description,
  });
}

class _Unset {
  const _Unset();
}
