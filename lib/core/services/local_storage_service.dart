import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:selo/core/di/di.dart';
import 'package:selo/shared/models/local_user_model.dart';
import 'package:selo/features/home/data/models/home_model.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:selo/shared/models/local_advert_model.dart';
import 'package:selo/features/home/data/models/local_banner_model.dart';
import 'package:talker_flutter/talker_flutter.dart';

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

  static final Talker _talker = di<Talker>();

  static Future<void> init() async {
    try {
      await Hive.initFlutter();

      Hive.registerAdapter(LocalUserModelAdapter());
      Hive.registerAdapter(LocalAdvertModelAdapter());
      Hive.registerAdapter(LocalBannerModelAdapter());

      _userBox = await Hive.openBox<LocalUserModel>(_userBoxName);
      _adsBox = await Hive.openBox<List<dynamic>>(_adsBoxName);
      await Hive.openBox(_settingsBoxName);

      _talker.info('LocalStorageService initialized successfully');
    } catch (e, stackTrace) {
      _talker.error('Error initializing LocalStorageService', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> saveUser(LocalUserModel user) async {
    try {
      final box = _userBox ?? await Hive.openBox<LocalUserModel>(_userBoxName);
      await box.put(_userKey, user);
    } catch (e, stack) {
      _talker.error('Error saving user', e, stack);
      rethrow;
    }
  }

  static LocalUserModel? getUser() {
    try {
      final box = _userBox ?? Hive.box<LocalUserModel>(_userBoxName);
      return box.get(_userKey);
    } catch (e, stack) {
      _talker.error('Error getting user', e, stack);
      return null;
    }
  }

  static Future<void> deleteUser() async {
    try {
      final box = _userBox ?? await Hive.openBox<LocalUserModel>(_userBoxName);
      await box.delete(_userKey);
    } catch (e, stack) {
      _talker.error('Error deleting user', e, stack);
      rethrow;
    }
  }

  static bool isUserLoggedIn() {
    try {
      return getUser() != null;
    } catch (e, stack) {
      _talker.error('Error checking user login status', e, stack);
      return false;
    }
  }

  static Future<void> clearAll() async {
    try {
      final box = _userBox ?? await Hive.openBox<LocalUserModel>(_userBoxName);
      await box.clear();
    } catch (e, stack) {
      _talker.error('Error clearing all data', e, stack);
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
      _talker.info('Cached [32m${banners.length}[0m banners');
    } catch (e, stack) {
      _talker.error('Error caching banners', e, stack);
      rethrow;
    }
  }

  static Future<List<BannerModel>?> getCachedBanners() async {
    try {
      final cached = _adsBox?.get(_bannersKey);
      if (cached == null) {
        _talker.info('No cached banners found');
        return null;
      }
      final banners =
          cached.cast<LocalBannerModel>().map((e) => e.banner).toList();
      _talker.info('Retrieved ${banners.length} cached banners');
      return banners;
    } catch (e, stack) {
      _talker.error('Error getting cached banners', e, stack);
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
      _talker.info('Cached ${ads.length} advertisements for page $page');
    } catch (e, stack) {
      _talker.error('Error caching advertisements', e, stack);
      rethrow;
    }
  }

  static Future<List<AdvertModel>?> getCachedAdvertisements(int page) async {
    try {
      final cached = _adsBox?.get('$_pagePrefix$page');
      if (cached == null) {
        _talker.info('No cached ads found for page $page');
        return null;
      }
      final ads =
          cached
              .cast<LocalAdvertModel>()
              .map((e) {
                try {
                  return e.advert;
                } catch (e) {
                  _talker.error('Error deserializing advert', e);
                  return null;
                }
              })
              .where((e) => e != null)
              .cast<AdvertModel>()
              .toList();
      _talker.info('Retrieved ${ads.length} cached ads for page $page');
      return ads.isEmpty ? null : ads;
    } catch (e, stack) {
      _talker.error('Error getting cached ads', e, stack);
      return null;
    }
  }

  static Future<bool> hasPageInCache(int page) async {
    final hasKey = _adsBox?.containsKey('$_pagePrefix$page') ?? false;
    _talker.info('Page $page in cache: $hasKey');
    return hasKey;
  }

  static Future<void> clearAdsCache() async {
    try {
      await _adsBox?.clear();
      _talker.info('Cleared ads cache');
    } catch (e, stack) {
      _talker.error('Error clearing ads cache', e, stack);
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
      _talker.info('Cached ${ads.length} filtered ads for key $filterKey');
    } catch (e, stack) {
      _talker.error('Error caching filtered ads', e, stack);
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
        _talker.info('No cached filtered ads found for key $filterKey');
        return null;
      }
      final ads =
          cached
              .cast<LocalAdvertModel>()
              .map((e) {
                try {
                  return e.advert;
                } catch (e) {
                  _talker.error('Error deserializing filtered advert', e);
                  return null;
                }
              })
              .where((e) => e != null)
              .cast<AdvertModel>()
              .toList();
      _talker.info(
        'Retrieved ${ads.length} cached filtered ads for key $filterKey',
      );
      return ads.isEmpty ? null : ads;
    } catch (e, stack) {
      _talker.error('Error getting cached filtered ads', e, stack);
      return null;
    }
  }

  static Future<bool> hasFilteredResultsInCache(
    Map<String, String> filterParams,
  ) async {
    final filterKey = _getFilterKey(filterParams);
    final hasKey = _adsBox?.containsKey(filterKey) ?? false;
    _talker.info('Filtered results in cache for key $filterKey: $hasKey');
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
    _talker.info('Cache keys: ${box.keys}');
    for (var key in box.keys) {
      final items = box.get(key);
      _talker.info('Key $key: ${items?.length ?? 0} items');
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
        _talker.info('🧹 Deleted filtered ads cache for key $key');
      }
      _talker.info('Cleared all filtered ads cache');
    } catch (e, stack) {
      _talker.error('Error clearing filtered ads cache', e, stack);
      rethrow;
    }
  }
}
