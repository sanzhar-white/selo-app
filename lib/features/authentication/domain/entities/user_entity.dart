// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserEntity extends Equatable {
  final String uid;
  final String phoneNumber;
  final String name;
  final List<String> likes;
  final int region;
  final int district;
  final String profileImage;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const UserEntity({
    required this.uid,
    required this.phoneNumber,
    required this.name,
    required this.likes,
    required this.region,
    required this.district,
    required this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  UserEntity copyWith({
    String? uid,
    String? phoneNumber,
    String? name,
    List<String>? likes,
    int? region,
    int? district,
    String? profileImage,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      likes: likes ?? this.likes,
      region: region ?? this.region,
      district: district ?? this.district,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'name': name,
      'likes': likes,
      'region': region,
      'district': district,
      'profileImage': profileImage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      uid: map['uid'] as String,
      phoneNumber: map['phoneNumber'] as String,
      name: map['name'] as String,
      likes: List<String>.from(map['likes'] ?? []),
      region: map['region'] as int,
      district: map['district'] as int,
      profileImage: map['profileImage'] as String,
      createdAt: Timestamp.fromDate(DateTime.parse(map['createdAt'] as String)),
      updatedAt:
          Timestamp.fromDate(DateTime.parse(map['upd atedAt'] as String)),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserEntity.fromJson(String source) =>
      UserEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserEntity(uid: $uid, phoneNumber: $phoneNumber, name: $name, likes: $likes, region: $region, district: $district, profileImage: $profileImage, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  List<Object?> get props => [
        uid,
        phoneNumber,
        name,
        likes,
        region,
        district,
        profileImage,
        createdAt,
        updatedAt,
      ];
}

class PhoneNumberEntity extends Equatable {
  final String phoneNumber;
  PhoneNumberEntity({required this.phoneNumber});

  PhoneNumberEntity copyWith({String? phoneNumber}) {
    return PhoneNumberEntity(phoneNumber: phoneNumber ?? this.phoneNumber);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'phoneNumber': phoneNumber};
  }

  factory PhoneNumberEntity.fromMap(Map<String, dynamic> map) {
    return PhoneNumberEntity(phoneNumber: map['phoneNumber'] as String);
  }

  String toJson() => json.encode(toMap());

  factory PhoneNumberEntity.fromJson(String source) =>
      PhoneNumberEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'PhoneNumberEntity(phoneNumber: $phoneNumber)';

  @override
  List<Object?> get props => [phoneNumber];
}

class SignUpEntity extends Equatable {
  final String phoneNumber;
  final String name;
  SignUpEntity({required this.phoneNumber, required this.name});

  SignUpEntity copyWith({String? phoneNumber, String? name}) {
    return SignUpEntity(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
    );
  }

  @override
  List<Object?> get props => [phoneNumber, name];
}

class AuthStatusEntity extends Equatable {
  final bool status;
  final String value;
  final UserEntity user;
  const AuthStatusEntity(
      {required this.status, required this.value, required this.user});

  @override
  List<Object?> get props => [status, value, user];
}

class SignInWithCredentialEntity extends Equatable {
  final String smsCode;
  final String verificationId;
  final UserEntity user;
  const SignInWithCredentialEntity(
      {required this.smsCode,
      required this.verificationId,
      required this.user});

  @override
  List<Object?> get props => [smsCode, verificationId, user];
}
