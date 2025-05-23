import 'dart:convert';

import 'package:equatable/equatable.dart';

class AdvertEntity extends Equatable {
  final String uid;
  final String ownerUid;
  final bool active;
  final int views;
  final int likes;
  final String createdDate;
  final String updatedDate;
  final String title;
  final int price;
  final String phoneNumber;
  final String category;
  final bool tradeable;
  final String region;
  final String district;
  final List<String> images;

  // Дополнительные поля
  final String description; // обязательно
  final int? maxPrice;
  final int? quantity;
  final int? maxQuantity;
  final String? companyName;
  final String? contactPerson;
  final String? condition;
  final int? year;
  final String? unit;
  final String? unitPer;

  const AdvertEntity({
    required this.uid,
    required this.ownerUid,
    this.active = true,
    this.views = 0,
    this.likes = 0,
    required this.createdDate,
    required this.updatedDate,
    required this.title,
    required this.price,
    required this.phoneNumber,
    required this.category,
    this.tradeable = false,
    required this.region,
    required this.district,
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
  });

  AdvertEntity copyWith({
    String? uid,
    String? ownerUid,
    bool? active,
    int? views,
    int? likes,
    String? createdDate,
    String? updatedDate,
    String? title,
    int? price,
    String? phoneNumber,
    String? category,
    bool? tradeable,
    String? region,
    String? district,
    List<String>? images,
    String? description,
    int? maxPrice,
    int? quantity,
    int? maxQuantity,
    String? companyName,
    String? contactPerson,
    String? condition,
    int? year,
    String? unit,
    String? unitPer,
  }) {
    return AdvertEntity(
      uid: uid ?? this.uid,
      ownerUid: ownerUid ?? this.ownerUid,
      active: active ?? this.active,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
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
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'uid': uid,
      'ownerUid': ownerUid,
      'active': active,
      'views': views,
      'likes': likes,
      'createdDate': createdDate,
      'updatedDate': updatedDate,
      'title': title,
      'price': price,
      'phoneNumber': phoneNumber,
      'category': category,
      'tradeable': tradeable,
      'region': region,
      'district': district,
      'images': images,
      'description': description,
    };

    if (maxPrice != null) map['maxPrice'] = maxPrice as Object;
    if (quantity != null) map['quantity'] = quantity as Object;
    if (maxQuantity != null) map['maxQuantity'] = maxQuantity as Object;
    if (companyName != null) map['companyName'] = companyName as Object;
    if (contactPerson != null) map['contactPerson'] = contactPerson as Object;
    if (condition != null) map['condition'] = condition as Object;
    if (year != null) map['year'] = year as Object;
    if (unit != null) map['unit'] = unit as Object;
    if (unitPer != null) map['unitPer'] = unitPer as Object;

    return map;
  }

  factory AdvertEntity.fromMap(Map<String, dynamic> map) {
    return AdvertEntity(
      uid: map['uid'] ?? '',
      ownerUid: map['ownerUid'] ?? '',
      active: map['active'] ?? false,
      views: map['views'] ?? 0,
      likes: map['likes'] ?? 0,
      createdDate: map['createdDate'] ?? '',
      updatedDate: map['updatedDate'] ?? '',
      title: map['title'] ?? '',
      price: map['price'] ?? 0,
      phoneNumber: map['phoneNumber'] ?? '',
      category: map['category'] ?? '',
      tradeable: map['tradeable'] ?? false,
      region: map['region'] ?? '',
      district: map['district'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      description: map['description'] ?? '',
      maxPrice: map['maxPrice'],
      quantity: map['quantity'],
      maxQuantity: map['maxQuantity'],
      companyName: map['companyName'],
      contactPerson: map['contactPerson'],
      condition: map['condition'],
      year: map['year'],
      unit: map['unit'],
      unitPer: map['unitPer'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AdvertEntity.fromJson(String source) =>
      AdvertEntity.fromMap(json.decode(source));

  @override
  List<Object?> get props => [
    uid,
    ownerUid,
    active,
    views,
    likes,
    createdDate,
    updatedDate,
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
  ];

  @override
  String toString() {
    return 'AdvertEntity(uid: $uid, ownerUid: $ownerUid, active: $active, views: $views, likes: $likes, createdDate: $createdDate, updatedDate: $updatedDate, title: $title, price: $price, phoneNumber: $phoneNumber, category: $category, tradeable: $tradeable, region: $region, district: $district, images: $images, description: $description, maxPrice: $maxPrice, quantity: $quantity, maxQuantity: $maxQuantity, companyName: $companyName, contactPerson: $contactPerson, condition: $condition, year: $year, unit: $unit, unitPer: $unitPer)';
  }
}
