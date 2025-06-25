import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/routes/router.dart';
import 'package:selo/core/providers/locale_provider.dart';
import 'package:selo/core/providers/theme_provider.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:selo/core/services/local_storage_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:selo/core/di/di.dart';
import 'dart:io';
import 'package:recaptcha_enterprise_flutter/recaptcha.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppInitializer {
  static Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    initDependencies();
    final talker = di<Talker>();
    talker.info('Starting app initialization...');

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );

    talker.info('Initializing other services in parallel...');
    final initializations = [
      _initAppCheck(),
      _initRecaptcha(),
      _initLocalStorage(),
    ];
    await Future.wait(initializations);
    talker.info('All services initialized successfully.');

    if (kDebugMode) {
      talker.info('Applying debug settings...');
      di<FirebaseAuth>().setSettings(appVerificationDisabledForTesting: true);
      talker.info('Debug settings applied.');
    }
  }

  static Future<void> _initAppCheck() async {
    final talker = di<Talker>();
    talker.info('Initializing Firebase App Check...');
    await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
    if (kDebugMode) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
    } else {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.deviceCheck,
      );
    }
    talker.info('Firebase App Check initialized.');
  }

  static Future<void> _initRecaptcha() async {
    final talker = di<Talker>();
    talker.info('Initializing Recaptcha...');
    final siteKey =
        Platform.isAndroid
            ? dotenv.env['RECAPTCHA_SITE_KEY_ANDROID']
            : dotenv.env['RECAPTCHA_SITE_KEY_IOS'];
    if (siteKey == null || siteKey.isEmpty) {
      talker.error('Recaptcha siteKey not found in environment variables');
      throw Exception('Recaptcha siteKey not found in environment variables');
    }
    await Recaptcha.fetchClient(siteKey);
    talker.info('Recaptcha initialized.');
  }

  static Future<void> _initLocalStorage() async {
    final talker = di<Talker>();
    talker.info('Initializing Local Storage (Hive)...');
    await LocalStorageService.init();
    talker.info('Local Storage initialized.');
  }
}

class SeloApp extends ConsumerWidget {
  const SeloApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final theme = ref.watch(themeProvider);
    return MaterialApp.router(
      locale: locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ru'), Locale('kk')],
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: theme,
    );
  }
}

class InitializationErrorScreen extends StatelessWidget {
  final String error;

  const InitializationErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${S.of(context).critical_error_when_launching_app}:\n\n$error',
              textAlign: TextAlign.center,
              style: contrastBoldM(context),
            ),
          ),
        ),
      ),
    );
  }
}
