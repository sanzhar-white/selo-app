import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:selo/core/services/local_storage_service.dart';
import 'package:selo/seloapp.dart';
import 'package:path_provider/path_provider.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger_observer.dart';
import 'package:selo/core/di/di.dart';

/// Класс для инициализации всех сервисов приложения
class AppInitializer {
  static Future<void> initialize() async {
    // Configure system UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );

    // Ensure path_provider is initialized
    await getApplicationDocumentsDirectory();

    // Initialize Firebase
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    initDependencies();

    if (kDebugMode) {
      di<FirebaseAuth>().setSettings(appVerificationDisabledForTesting: true);
    }

    // Initialize Hive after path_provider
    await LocalStorageService.init();
  }
}

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await AppInitializer.initialize();
    runApp(
      ProviderScope(
        child: const SeloApp(),
        observers: [TalkerRiverpodObserver(talker: di<Talker>())],
      ),
    );
  } catch (e, stackTrace) {
    di<Talker>().debug('Error during initialization: $e');
    di<Talker>().debug('Stack trace: $stackTrace');
    // Rethrow if in debug mode
    if (kDebugMode) {
      rethrow;
    }
    // In production, try to run the app anyway
    runApp(
      ProviderScope(
        child: const SeloApp(),
        observers: [TalkerRiverpodObserver(talker: di<Talker>())],
      ),
    );
  }
}
