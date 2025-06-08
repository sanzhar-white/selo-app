// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String phoneNumber;
  final String name;
  final String lastName;
  final List<String> likes;
  final int region;
  final int district;
  final String profileImage;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final Timestamp? deletedAt;

  const UserModel({
    required this.uid,
    required this.phoneNumber,
    required this.name,
    required this.lastName,
    required this.likes,
    required this.region,
    required this.district,
    required this.profileImage,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  UserModel copyWith({
    String? uid,
    String? phoneNumber,
    String? name,
    String? lastName,
    List<String>? likes,
    int? region,
    int? district,
    String? profileImage,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Timestamp? deletedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      likes: likes ?? this.likes,
      region: region ?? this.region,
      district: district ?? this.district,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  // For Firestore: Store Timestamp directly
  Map<String, dynamic> toFirestoreMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'name': name,
      'lastName': lastName,
      'likes': likes,
      'region': region,
      'district': district,
      'profileImage': profileImage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
    };
  }

  factory UserModel.fromFirestoreMap(Map<String, dynamic> map) {
    // Helper function to convert dynamic to Timestamp
    Timestamp toTimestamp(dynamic value) {
      if (value is Timestamp) {
        return value;
      } else if (value is String) {
        // Attempt to parse ISO 8601 string or other date format
        try {
          return Timestamp.fromDate(DateTime.parse(value));
        } catch (e) {
          // Fallback to current time if parsing fails
          return Timestamp.now();
        }
      } else {
        // Fallback to current time if type is unexpected
        return Timestamp.now();
      }
    }

    return UserModel(
      uid: map['uid'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      name: map['name'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      likes: List<String>.from(map['likes'] ?? []),
      region: (map['region'] as num?)?.toInt() ?? 0,
      district: (map['district'] as num?)?.toInt() ?? 0,
      profileImage: map['profileImage'] as String? ?? '',
      createdAt: toTimestamp(map['createdAt']),
      updatedAt: toTimestamp(map['updatedAt']),
      deletedAt:
          map['deletedAt'] != null ? toTimestamp(map['deletedAt']) : null,
    );
  }

  // For Hive: Convert Timestamp to ISO 8601 strings
  Map<String, dynamic> toHiveMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'name': name,
      'lastName': lastName,
      'likes': likes,
      'region': region,
      'district': district,
      'profileImage': profileImage,
      'createdAt': createdAt.toDate().toIso8601String(),
      'updatedAt': updatedAt.toDate().toIso8601String(),
      'deletedAt': deletedAt?.toDate().toIso8601String(),
    };
  }

  factory UserModel.fromHiveMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      name: map['name'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      likes: List<String>.from(map['likes'] ?? []),
      region: (map['region'] as num?)?.toInt() ?? 0,
      district: (map['district'] as num?)?.toInt() ?? 0,
      profileImage: map['profileImage'] as String? ?? '',
      createdAt: Timestamp.fromDate(DateTime.parse(map['createdAt'] as String)),
      updatedAt: Timestamp.fromDate(DateTime.parse(map['updatedAt'] as String)),
      deletedAt:
          map['deletedAt'] != null
              ? Timestamp.fromDate(DateTime.parse(map['deletedAt'] as String))
              : null,
    );
  }

  String toJson() => json.encode(toHiveMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromHiveMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(uid: $uid, phoneNumber: $phoneNumber, name: $name, lastName: $lastName, likes: $likes, region: $region, district: $district, profileImage: $profileImage, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  List<Object?> get props => [
    uid,
    phoneNumber,
    name,
    lastName,
    likes,
    region,
    district,
    profileImage,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}

class PhoneNumberModel extends Equatable {
  final String phoneNumber;
  PhoneNumberModel({required this.phoneNumber});

  PhoneNumberModel copyWith({String? phoneNumber}) {
    return PhoneNumberModel(phoneNumber: phoneNumber ?? this.phoneNumber);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'phoneNumber': phoneNumber};
  }

  factory PhoneNumberModel.fromMap(Map<String, dynamic> map) {
    return PhoneNumberModel(phoneNumber: map['phoneNumber'] as String);
  }

  String toJson() => json.encode(toMap());

  factory PhoneNumberModel.fromJson(String source) =>
      PhoneNumberModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'PhoneNumberModel(phoneNumber: $phoneNumber)';

  @override
  List<Object?> get props => [phoneNumber];
}

class SignUpModel extends Equatable {
  final String phoneNumber;
  final String name;
  final String lastName;

  SignUpModel({
    required this.phoneNumber,
    required this.name,
    this.lastName = '',
  });

  SignUpModel copyWith({String? phoneNumber, String? name, String? lastName}) {
    return SignUpModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
    );
  }

  @override
  List<Object?> get props => [phoneNumber, name, lastName];
}

class AuthStatusModel extends Equatable {
  final bool status;
  final String value;
  final UserModel user;
  const AuthStatusModel({
    required this.status,
    required this.value,
    required this.user,
  });

  @override
  List<Object?> get props => [status, value, user];
}

class SignInWithCredentialModel extends Equatable {
  final String smsCode;
  final String verificationId;
  final UserModel user;
  const SignInWithCredentialModel({
    required this.smsCode,
    required this.verificationId,
    required this.user,
  });

  @override
  List<Object?> get props => [smsCode, verificationId, user];
}
