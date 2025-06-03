import 'dart:convert';
import '../../domain/entities/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.phoneNumber,
    required super.name,
    required super.likes,
    required super.region,
    required super.district,
    required super.profileImage,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      name: map['name'] ?? '',
      likes: List<String>.from(map['likes'] ?? []),
      region: map['region'] ?? 0,
      district: map['district'] ?? 0,
      profileImage: map['profileImage'] ?? '',
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
    );
  }

  @override
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

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  @override
  String toJson() => json.encode(toMap());
}

class PhoneNumberModel extends PhoneNumberEntity {
  PhoneNumberModel({required super.phoneNumber});

  factory PhoneNumberModel.fromMap(Map<String, dynamic> map) {
    return PhoneNumberModel(phoneNumber: map['phoneNumber'] ?? '');
  }
  @override
  Map<String, dynamic> toMap() {
    return {'phoneNumber': phoneNumber};
  }

  factory PhoneNumberModel.fromJson(String source) =>
      PhoneNumberModel.fromMap(json.decode(source));
  @override
  String toJson() => json.encode(toMap());
}

class SignUpModel extends SignUpEntity {
  SignUpModel({required super.phoneNumber, required super.name});

  factory SignUpModel.fromMap(Map<String, dynamic> map) {
    return SignUpModel(
      phoneNumber: map['phoneNumber'] ?? '',
      name: map['name'] ?? '',
    );
  }
  @override
  Map<String, dynamic> toMap() {
    return {'phoneNumber': phoneNumber, 'name': name};
  }

  factory SignUpModel.fromJson(String source) =>
      SignUpModel.fromMap(json.decode(source));
  @override
  String toJson() => json.encode(toMap());
}

class AuthStatusModel extends AuthStatusEntity {
  const AuthStatusModel({
    required super.status,
    required super.value,
    required super.user,
  });

  factory AuthStatusModel.fromMap(Map<String, dynamic> map) {
    return AuthStatusModel(
      status: map['status'] ?? false,
      value: map['value'] ?? '',
      user: UserModel.fromMap(map['user']),
    );
  }
}

class SignInWithCredentialModel extends SignInWithCredentialEntity {
  const SignInWithCredentialModel({
    required super.smsCode,
    required super.verificationId,
    required super.user,
  });

  factory SignInWithCredentialModel.fromMap(Map<String, dynamic> map) {
    return SignInWithCredentialModel(
      smsCode: map['smsCode'] ?? false,
      verificationId: map['verificationId'] ?? '',
      user: UserModel.fromMap(map['user']),
    );
  }
}
