import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class AdvertModel extends Equatable {
  final String uid;
  final String ownerUid;
  final bool active;
  final int views;
  final int likes;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String title;
  final int price;
  final String phoneNumber;
  final int category;
  final bool tradeable;
  final int? region;
  final int? district;
  final List<String> images;
  final String description;
  final int? maxPrice;
  final int? quantity;
  final int? maxQuantity;
  final String? companyName;
  final String? contactPerson;
  final int? condition;
  final int? year;
  final String? unit;
  final String? unitPer;
  final Timestamp? deletedAt;

  const AdvertModel({
    required this.uid,
    required this.ownerUid,
    this.active = true,
    this.views = 0,
    this.likes = 0,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.price,
    required this.phoneNumber,
    required this.category,
    this.tradeable = false,
    this.region,
    this.district,
    required this.images,
    required this.description,
    this.maxPrice,
    this.quantity,
    this.maxQuantity,
    this.companyName,
    this.contactPerson,
    this.condition,
    this.year,
    this.unit,
    this.unitPer,
    this.deletedAt,
  });

  AdvertModel copyWith({
    String? uid,
    String? ownerUid,
    bool? active,
    int? views,
    int? likes,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? title,
    int? price,
    String? phoneNumber,
    int? category,
    bool? tradeable,
    int? region,
    int? district,
    List<String>? images,
    String? description,
    int? maxPrice,
    int? quantity,
    int? maxQuantity,
    String? companyName,
    String? contactPerson,
    int? condition,
    int? year,
    String? unit,
    String? unitPer,
    Timestamp? deletedAt,
  }) {
    return AdvertModel(
      uid: uid ?? this.uid,
      ownerUid: ownerUid ?? this.ownerUid,
      active: active ?? this.active,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      price: price ?? this.price,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      category: category ?? this.category,
      tradeable: tradeable ?? this.tradeable,
      region: region ?? this.region,
      district: district ?? this.district,
      images: images ?? this.images,
      description: description ?? this.description,
      maxPrice: maxPrice ?? this.maxPrice,
      quantity: quantity ?? this.quantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      companyName: companyName ?? this.companyName,
      contactPerson: contactPerson ?? this.contactPerson,
      condition: condition ?? this.condition,
      year: year ?? this.year,
      unit: unit ?? this.unit,
      unitPer: unitPer ?? this.unitPer,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'uid': uid,
      'ownerUid': ownerUid,
      'active': active,
      'views': views,
      'likes': likes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'title': title,
      'price': price,
      'phoneNumber': phoneNumber,
      'category': category,
      'tradeable': tradeable,
      'region': region,
      'district': district,
      'images': images,
      'description': description,
      'maxPrice': maxPrice,
      'quantity': quantity,
      'maxQuantity': maxQuantity,
      'companyName': companyName,
      'contactPerson': contactPerson,
      'condition': condition,
      'year': year,
      'unit': unit,
      'unitPer': unitPer,
      'deletedAt': deletedAt,
    };
    return map
      ..removeWhere((key, value) => value == null && key != 'deletedAt');
  }

  Map<String, dynamic> toHiveMap() {
    return {
      'uid': uid,
      'ownerUid': ownerUid,
      'active': active,
      'views': views,
      'likes': likes,
      'createdAt': createdAt.toDate().toIso8601String(),
      'updatedAt': updatedAt.toDate().toIso8601String(),
      'title': title,
      'price': price,
      'phoneNumber': phoneNumber,
      'category': category,
      'tradeable': tradeable,
      'region': region,
      'district': district,
      'images': images,
      'description': description,
      'maxPrice': maxPrice,
      'quantity': quantity,
      'maxQuantity': maxQuantity,
      'companyName': companyName,
      'contactPerson': contactPerson,
      'condition': condition,
      'year': year,
      'unit': unit,
      'unitPer': unitPer,
      'deletedAt': deletedAt?.toDate().toIso8601String(),
    };
  }

  factory AdvertModel.fromMap(Map<String, dynamic> map) {
    return AdvertModel(
      uid: map['uid'] as String? ?? '',
      ownerUid: map['ownerUid'] as String? ?? '',
      active: map['active'] as bool? ?? true,
      views: map['views'] as int? ?? 0,
      likes: map['likes'] as int? ?? 0,
      createdAt:
          map['createdAt'] is Timestamp
              ? map['createdAt'] as Timestamp
              : Timestamp.now(),
      updatedAt:
          map['updatedAt'] is Timestamp
              ? map['updatedAt'] as Timestamp
              : Timestamp.now(),
      title: map['title'] as String? ?? '',
      price: map['price'] as int? ?? 0,
      phoneNumber: map['phoneNumber'] as String? ?? '',
      category: map['category'] as int? ?? 0,
      tradeable: map['tradeable'] as bool? ?? false,
      region: map['region'] as int?,
      district: map['district'] as int?,
      images: List<String>.from(map['images'] ?? []),
      description: map['description'] as String? ?? '',
      maxPrice: map['maxPrice'] as int?,
      quantity: map['quantity'] as int?,
      maxQuantity: map['maxQuantity'] as int?,
      companyName: map['companyName'] as String?,
      contactPerson: map['contactPerson'] as String?,
      condition: map['condition'] as int?,
      year: map['year'] as int?,
      unit: map['unit'] as String?,
      unitPer: map['unitPer'] as String?,
      deletedAt:
          map['deletedAt'] is Timestamp ? map['deletedAt'] as Timestamp : null,
    );
  }

  factory AdvertModel.fromHiveMap(Map<String, dynamic> map) {
    return AdvertModel(
      uid: map['uid'] as String? ?? '',
      ownerUid: map['ownerUid'] as String? ?? '',
      active: map['active'] as bool? ?? true,
      views: map['views'] as int? ?? 0,
      likes: map['likes'] as int? ?? 0,
      createdAt:
          map['createdAt'] != null
              ? Timestamp.fromDate(DateTime.parse(map['createdAt'] as String))
              : Timestamp.now(),
      updatedAt:
          map['updatedAt'] != null
              ? Timestamp.fromDate(DateTime.parse(map['updatedAt'] as String))
              : Timestamp.now(),
      title: map['title'] as String? ?? '',
      price: map['price'] as int? ?? 0,
      phoneNumber: map['phoneNumber'] as String? ?? '',
      category: map['category'] as int? ?? 0,
      tradeable: map['tradeable'] as bool? ?? false,
      region: map['region'] as int?,
      district: map['district'] as int?,
      images: List<String>.from(map['images'] ?? []),
      description: map['description'] as String? ?? '',
      maxPrice: map['maxPrice'] as int?,
      quantity: map['quantity'] as int?,
      maxQuantity: map['maxQuantity'] as int?,
      companyName: map['companyName'] as String?,
      contactPerson: map['contactPerson'] as String?,
      condition: map['condition'] as int?,
      year: map['year'] as int?,
      unit: map['unit'] as String?,
      unitPer: map['unitPer'] as String?,
      deletedAt:
          map['deletedAt'] != null
              ? Timestamp.fromDate(DateTime.parse(map['deletedAt'] as String))
              : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AdvertModel.fromJson(Map<String, dynamic> json) =>
      AdvertModel.fromMap(json);

  @override
  List<Object?> get props => [
    uid,
    ownerUid,
    active,
    views,
    likes,
    createdAt,
    updatedAt,
    title,
    price,
    phoneNumber,
    category,
    tradeable,
    region,
    district,
    images,
    description,
    maxPrice,
    quantity,
    maxQuantity,
    companyName,
    contactPerson,
    condition,
    year,
    unit,
    unitPer,
    deletedAt,
  ];

  @override
  String toString() {
    return 'AdvertModel(uid: $uid, ownerUid: $ownerUid, active: $active, views: $views, likes: $likes, createdAt: $createdAt, updatedAt: $updatedAt, title: $title, price: $price, phoneNumber: $phoneNumber, category: $category, tradeable: $tradeable, region: $region, district: $district, images: $images, description: $description, maxPrice: $maxPrice, quantity: $quantity, maxQuantity: $maxQuantity, companyName: $companyName, contactPerson: $contactPerson, condition: $condition, year: $year, unit: $unit, unitPer: $unitPer, deletedAt: $deletedAt)';
  }
}
