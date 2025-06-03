import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:selo/core/services/local_storage_service.dart';
import 'package:selo/seloapp.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

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

    if (kDebugMode) {
      FirebaseAuth.instance.setSettings(
        appVerificationDisabledForTesting: true,
      );
    }

    // Initialize Hive after path_provider
    await LocalStorageService.init();
    runApp(ProviderScope(child: SeloApp()));
  } catch (e, stackTrace) {
    debugPrint('Error during initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    // Rethrow if in debug mode
    if (kDebugMode) {
      rethrow;
    }
    // In production, try to run the app anyway
    runApp(ProviderScope(child: SeloApp()));
  }
}
