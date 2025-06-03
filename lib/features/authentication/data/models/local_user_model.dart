import 'package:hive/hive.dart';

part 'local_user_model.g.dart';

@HiveType(typeId: 0)
class LocalUserModel extends HiveObject {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String phoneNumber;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String profileImage;

  @HiveField(4)
  final bool isAnonymous;

  LocalUserModel({
    required this.uid,
    required this.phoneNumber,
    required this.name,
    required this.profileImage,
    required this.isAnonymous,
  });

  factory LocalUserModel.fromUserModel(
    dynamic user, {
    bool isAnonymous = false,
  }) {
    return LocalUserModel(
      uid: user.uid,
      phoneNumber: user.phoneNumber,
      name: user.name,
      profileImage: user.profileImage,
      isAnonymous: isAnonymous,
    );
  }
}
