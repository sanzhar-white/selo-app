import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:selo/core/services/local_storage_service.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final languageCode = await LocalStorageService.getLocale();
      if (languageCode != null && ['en', 'ru', 'kk'].contains(languageCode)) {
        state = Locale(languageCode);
      } else {
        print('⚠️ Invalid or no saved locale, defaulting to en');
      }
    } catch (e) {
      print('💥 Error loading locale: $e');
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!['en', 'ru', 'kk'].contains(locale.languageCode)) {
      print('⚠️ Unsupported locale: ${locale.languageCode}');
      return;
    }
    try {
      state = locale;
      await LocalStorageService.saveLocale(locale.languageCode);
      print('🌐 Locale set to ${locale.languageCode}');
    } catch (e) {
      print('💥 Error saving locale: $e');
    }
  }
}
