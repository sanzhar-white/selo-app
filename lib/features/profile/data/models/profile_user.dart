// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class UpdateUserModel extends Equatable {
  final String uid;
  final String? name;
  final String? lastName;
  final String? phoneNumber;
  final int? region;
  final int? district;
  final String? profileImage;

  const UpdateUserModel({
    required this.uid,
    this.name,
    this.lastName,
    this.phoneNumber,
    this.region,
    this.district,
    this.profileImage,
  });

  UpdateUserModel copyWith({
    String? uid,
    String? name,
    String? lastName,
    String? phoneNumber,
    int? region,
    int? district,
    String? profileImage,
  }) {
    return UpdateUserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      region: region ?? this.region,
      district: district ?? this.district,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'region': region,
      'district': district,
      'profileImage': profileImage,
    };
  }

  factory UpdateUserModel.fromMap(Map<String, dynamic> map) {
    return UpdateUserModel(
      uid: map['uid'] as String,
      name: map['name'] != null ? map['name'] as String : null,
      lastName: map['lastName'] != null ? map['lastName'] as String : null,
      phoneNumber:
          map['phoneNumber'] != null ? map['phoneNumber'] as String : null,
      region: map['region'] != null ? map['region'] as int : null,
      district: map['district'] != null ? map['district'] as int : null,
      profileImage:
          map['profileImage'] != null ? map['profileImage'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UpdateUserModel.fromJson(String source) =>
      UpdateUserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UpdateUserModel(uid: $uid, name: $name, lastName: $lastName, phoneNumber: $phoneNumber, region: $region, district: $district, profileImage: $profileImage)';
  }

  @override
  List<Object?> get props => [
    uid,
    name,
    lastName,
    phoneNumber,
    region,
    district,
    profileImage,
  ];
}
