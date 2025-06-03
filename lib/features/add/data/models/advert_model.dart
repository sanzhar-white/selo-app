import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/advert_entity.dart';

class AdvertModel extends AdvertEntity {
  const AdvertModel({
    required super.uid,
    required super.ownerUid,
    required super.createdDate,
    required super.updatedDate,
    required super.title,
    required super.price,
    required super.phoneNumber,
    required super.category,
    required super.region,
    required super.district,
    required super.images,
    required super.description,
    super.active,
    super.views,
    super.likes,
    super.tradeable,
    super.quantity,
    super.maxPrice,
    super.maxQuantity,
    super.companyName,
    super.contactPerson,
    super.condition,
    super.year,
    super.unit,
    super.unitPer,
  });

  factory AdvertModel.fromMap(Map<String, dynamic> map) {
    return AdvertModel(
      uid: map['uid'] ?? '',
      ownerUid: map['ownerUid'] ?? '',
      active: map['active'] ?? true,
      views: map['views'] ?? 0,
      likes: map['likes'] ?? 0,
      createdDate: map['createdDate'] ?? Timestamp.now(),
      updatedDate: map['updatedDate'] ?? Timestamp.now(),
      title: map['title'] ?? '',
      price: map['price'] ?? 0,
      phoneNumber: map['phoneNumber'] ?? '',
      category: map['category'] ?? null,
      tradeable: map['tradeable'] ?? false,
      region: map['region'] ?? null,
      district: map['district'] ?? null,
      images: List<String>.from(map['images'] ?? []),
      description: map['description'] ?? '',
      maxPrice: map['maxPrice'],
      quantity: map['quantity'],
      maxQuantity: map['maxQuantity'],
      companyName: map['companyName'],
      contactPerson: map['contactPerson'],
      condition: map['condition'] ?? null,
      year: map['year'],
      unit: map['unit'],
      unitPer: map['unitPer'],
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'uid': uid,
      'ownerUid': ownerUid,
      'active': active,
      'views': views,
      'likes': likes,
      'createdDate': createdDate as Object,
      'updatedDate': updatedDate as Object,
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

  String toJson() => json.encode(toMap());

  factory AdvertModel.fromJson(String source) =>
      AdvertModel.fromMap(json.decode(source));

  AdvertModel copyWith({
    String? uid,
    String? ownerUid,
    bool? active,
    int? views,
    int? likes,
    Timestamp? createdDate,
    Timestamp? updatedDate,
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
  }) {
    return AdvertModel(
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

  @override
  String toString() {
    return 'AdvertModel(uid: $uid, ownerUid: $ownerUid, active: $active, views: $views, likes: $likes, createdDate: $createdDate, updatedDate: $updatedDate, title: $title, price: $price, phoneNumber: $phoneNumber, category: $category, tradeable: $tradeable, region: $region, district: $district, images: $images, description: $description, maxPrice: $maxPrice, quantity: $quantity, maxQuantity: $maxQuantity, companyName: $companyName, contactPerson: $contactPerson, condition: $condition, year: $year, unit: $unit, unitPer: $unitPer)';
  }
}
