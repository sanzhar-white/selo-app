import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:selo/features/authentication/data/models/local_user_model.dart';

class LocalStorageService {
  static const String _userBoxName = 'userBox';
  static const String _userKey = 'currentUser';
  static Box<LocalUserModel>? _userBox;

  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      Hive.registerAdapter(LocalUserModelAdapter());
      _userBox = await Hive.openBox<LocalUserModel>(_userBoxName);
      debugPrint('LocalStorageService initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('Error initializing LocalStorageService: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> saveUser(LocalUserModel user) async {
    try {
      final box = _userBox ?? await Hive.openBox<LocalUserModel>(_userBoxName);
      await box.put(_userKey, user);
    } catch (e) {
      debugPrint('Error saving user: $e');
      rethrow;
    }
  }

  static LocalUserModel? getUser() {
    try {
      final box = _userBox ?? Hive.box<LocalUserModel>(_userBoxName);
      return box.get(_userKey);
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  static Future<void> deleteUser() async {
    try {
      final box = _userBox ?? await Hive.openBox<LocalUserModel>(_userBoxName);
      await box.delete(_userKey);
    } catch (e) {
      debugPrint('Error deleting user: $e');
      rethrow;
    }
  }

  static bool isUserLoggedIn() {
    try {
      return getUser() != null;
    } catch (e) {
      debugPrint('Error checking user login status: $e');
      return false;
    }
  }

  static Future<void> clearAll() async {
    try {
      final box = _userBox ?? await Hive.openBox<LocalUserModel>(_userBoxName);
      await box.clear();
    } catch (e) {
      debugPrint('Error clearing all data: $e');
      rethrow;
    }
  }
}
