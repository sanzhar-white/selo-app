class FirebaseCollections {
  static const String adverts = 'adverts';
  static const String users = 'users';
  static const String banners = 'banners';
  static const String categories = 'categories';
  static const String user_photos = 'user_photos';
}

class FirebaseConstants {
  static const int maxImageSizeBytes = 25 * 1024 * 1024;
  static const int maxUploadRetries = 3;
  static const Duration uploadRetryDelay = Duration(seconds: 1);
  static const Duration operationTimeout = Duration(seconds: 60);
}
