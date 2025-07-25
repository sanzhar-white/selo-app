import 'dart:convert';
import 'package:hive/hive.dart';
import 'user_model.dart';

part 'local_user_model.g.dart';

@HiveType(typeId: 0)
class LocalUserModel extends HiveObject { // Сохраняем UserModel как json-строку

  LocalUserModel({required this.userJson});

  factory LocalUserModel.fromUserModel(UserModel user) {
    return LocalUserModel(userJson: jsonEncode(user.toHiveMap()));
  }
  @HiveField(0)
  final String userJson;

  UserModel get user => UserModel.fromJson(userJson);
}
