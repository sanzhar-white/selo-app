import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:selo/core/services/local_storage_service.dart';
import 'package:selo/core/di/di.dart';
import 'package:selo/core/constants/error_message.dart';
import 'package:talker_flutter/talker_flutter.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  Talker get _talker => di<Talker>();

  Future<void> _loadLocale() async {
    try {
      final languageCode = LocalStorageService.getLocale();
      if (languageCode != null && ['en', 'ru', 'kk'].contains(languageCode)) {
        state = Locale(languageCode);
      } else {
        _talker.warning(ErrorMessages.invalidOrNoSavedLocale);
      }
    } catch (e, stack) {
      _talker.error(ErrorMessages.errorLoadingLocale, e, stack);
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!['en', 'ru', 'kk'].contains(locale.languageCode)) {
      _talker.warning(
        '${ErrorMessages.unsupportedLocale}: ${locale.languageCode}',
      );
      return;
    }
    try {
      state = locale;
      await LocalStorageService.saveLocale(locale.languageCode);
      _talker.info('🌐 Locale set to ${locale.languageCode}');
    } catch (e, stack) {
      _talker.error(ErrorMessages.errorSavingLocale, e, stack);
    }
  }
}
