class UserUidModel {
  final String uid;

  UserUidModel({required this.uid});
}

class AdvertUidModel {
  final String uid;

  AdvertUidModel({required this.uid});
}

class FavouritesModel {
  final UserUidModel userUid;
  final AdvertUidModel advertUid;

  FavouritesModel({required this.userUid, required this.advertUid});
}
