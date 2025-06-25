class UserUidModel {

  UserUidModel({required this.uid});
  final String uid;
}

class AdvertUidModel {

  AdvertUidModel({required this.uid});
  final String uid;
}

class FavouritesModel {

  FavouritesModel({required this.userUid, required this.advertUid});
  final UserUidModel userUid;
  final AdvertUidModel advertUid;
}
