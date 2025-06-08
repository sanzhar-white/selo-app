import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:selo/features/authentication/data/models/local_user_model.dart';
import 'package:selo/features/home/data/models/home_model.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:selo/shared/models/local_advert_model.dart';
import 'package:selo/features/home/data/models/local_banner_model.dart';

class LocalStorageService {
  static const String _userBoxName = 'userBox';
  static const String _settingsBoxName = 'settingsBox';
  static const String _userKey = 'user';
  static const String _themeKey = 'theme';
  static const String _localeKey = 'locale';
  static const String _adsBoxName = 'adsCacheBox';
  static const String _pagePrefix = 'page_';
  static const String _filterPrefix = 'filter_';
  static const String _bannersKey = 'banners';

  static Box<LocalUserModel>? _userBox;
  static Box<List<dynamic>>? _adsBox;

  static Future<void> init() async {
    try {
      await Hive.initFlutter();

      Hive.registerAdapter(LocalUserModelAdapter());
      Hive.registerAdapter(LocalAdvertModelAdapter());
      Hive.registerAdapter(LocalBannerModelAdapter());

      _userBox = await Hive.openBox<LocalUserModel>(_userBoxName);
      _adsBox = await Hive.openBox<List<dynamic>>(_adsBoxName);
      await Hive.openBox(_settingsBoxName);

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

  static Future<void> saveTheme(bool isDark) async {
    final box = Hive.box(_settingsBoxName);
    await box.put(_themeKey, isDark);
  }

  static bool? getTheme() {
    final box = Hive.box(_settingsBoxName);
    return box.get(_themeKey);
  }

  static Future<void> saveLocale(String languageCode) async {
    final box = Hive.box(_settingsBoxName);
    await box.put(_localeKey, languageCode);
  }

  static String? getLocale() {
    final box = Hive.box(_settingsBoxName);
    return box.get(_localeKey);
  }

  static Future<void> cacheBanners(List<BannerModel> banners) async {
    try {
      await _adsBox?.put(
        _bannersKey,
        banners.map((e) => LocalBannerModel.fromBannerModel(e)).toList(),
      );
      debugPrint('Cached ${banners.length} banners');
    } catch (e) {
      debugPrint('Error caching banners: $e');
      rethrow;
    }
  }

  static Future<List<BannerModel>?> getCachedBanners() async {
    try {
      final cached = _adsBox?.get(_bannersKey);
      if (cached == null) {
        debugPrint('No cached banners found');
        return null;
      }
      final banners =
          cached.cast<LocalBannerModel>().map((e) => e.banner).toList();
      debugPrint('Retrieved ${banners.length} cached banners');
      return banners;
    } catch (e) {
      debugPrint('Error getting cached banners: $e');
      return null;
    }
  }

  static Future<void> cacheAdvertisements(
    List<AdvertModel> ads,
    int page,
  ) async {
    try {
      await _adsBox?.put(
        '$_pagePrefix$page',
        ads.map((e) => LocalAdvertModel.fromAdvertModel(e)).toList(),
      );
      debugPrint('Cached ${ads.length} advertisements for page $page');
    } catch (e) {
      debugPrint('Error caching advertisements: $e');
      rethrow;
    }
  }

  static Future<List<AdvertModel>?> getCachedAdvertisements(int page) async {
    try {
      final cached = _adsBox?.get('$_pagePrefix$page');
      if (cached == null) {
        debugPrint('No cached ads found for page $page');
        return null;
      }
      final ads =
          cached
              .cast<LocalAdvertModel>()
              .map((e) {
                try {
                  return e.advert;
                } catch (e) {
                  debugPrint('Error deserializing advert: $e');
                  return null;
                }
              })
              .where((e) => e != null)
              .cast<AdvertModel>()
              .toList();
      debugPrint('Retrieved ${ads.length} cached ads for page $page');
      return ads.isEmpty ? null : ads;
    } catch (e) {
      debugPrint('Error getting cached ads: $e');
      return null;
    }
  }

  static Future<bool> hasPageInCache(int page) async {
    final hasKey = _adsBox?.containsKey('$_pagePrefix$page') ?? false;
    debugPrint('Page $page in cache: $hasKey');
    return hasKey;
  }

  static Future<void> clearAdsCache() async {
    try {
      await _adsBox?.clear();
      debugPrint('Cleared ads cache');
    } catch (e) {
      debugPrint('Error clearing ads cache: $e');
      rethrow;
    }
  }

  static Future<void> cacheFilteredAds(
    List<AdvertModel> ads,
    Map<String, String> filterParams,
  ) async {
    try {
      final filterKey = _getFilterKey(filterParams);
      await _adsBox?.put(
        filterKey,
        ads.map((e) => LocalAdvertModel.fromAdvertModel(e)).toList(),
      );
      debugPrint('Cached ${ads.length} filtered ads for key $filterKey');
    } catch (e) {
      debugPrint('Error caching filtered ads: $e');
      rethrow;
    }
  }

  static Future<List<AdvertModel>?> getCachedFilteredAds(
    Map<String, String> filterParams,
  ) async {
    try {
      final filterKey = _getFilterKey(filterParams);
      final cached = _adsBox?.get(filterKey);
      if (cached == null) {
        debugPrint('No cached filtered ads found for key $filterKey');
        return null;
      }
      final ads =
          cached
              .cast<LocalAdvertModel>()
              .map((e) {
                try {
                  return e.advert;
                } catch (e) {
                  debugPrint('Error deserializing filtered advert: $e');
                  return null;
                }
              })
              .where((e) => e != null)
              .cast<AdvertModel>()
              .toList();
      debugPrint(
        'Retrieved ${ads.length} cached filtered ads for key $filterKey',
      );
      return ads.isEmpty ? null : ads;
    } catch (e) {
      debugPrint('Error getting cached filtered ads: $e');
      return null;
    }
  }

  static Future<bool> hasFilteredResultsInCache(
    Map<String, String> filterParams,
  ) async {
    final filterKey = _getFilterKey(filterParams);
    final hasKey = _adsBox?.containsKey(filterKey) ?? false;
    debugPrint('Filtered results in cache for key $filterKey: $hasKey');
    return hasKey;
  }

  static String _getFilterKey(Map<String, String> filterParams) {
    final sortedParams = Map.fromEntries(
      filterParams.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    final paramsString = sortedParams.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return '$_filterPrefix${paramsString.hashCode}';
  }

  static void debugCache() {
    final box = _adsBox ?? Hive.box<List<dynamic>>(_adsBoxName);
    debugPrint('Cache keys: ${box.keys}');
    for (var key in box.keys) {
      final items = box.get(key);
      debugPrint('Key $key: ${items?.length ?? 0} items');
    }
  }

  static Future<void> clearFilteredAdsCache() async {
    try {
      final box = _adsBox ?? await Hive.openBox<List<dynamic>>(_adsBoxName);
      final filterKeys =
          box.keys
              .where((key) => key.toString().startsWith(_filterPrefix))
              .toList();
      for (var key in filterKeys) {
        await box.delete(key);
        debugPrint('🧹 Deleted filtered ads cache for key $key');
      }
      debugPrint('Cleared all filtered ads cache');
    } catch (e) {
      debugPrint('Error clearing filtered ads cache: $e');
      rethrow;
    }
  }
}
