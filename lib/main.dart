import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:selo/core/constants/error_message.dart';
import 'package:selo/seloapp.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger_observer.dart';
import 'package:selo/core/di/di.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await AppInitializer.initialize();
    _runSeloApp();
  } catch (e, stackTrace) {
    final errorMessage = '${ErrorMessages.failedToInitApp}: $e';
    if (di.isRegistered<Talker>()) {
      di<Talker>().critical(errorMessage, e, stackTrace);
    } else {
      debugPrint('CRITICAL ERROR DURING INITIALIZATION: $errorMessage');
      debugPrint(stackTrace.toString());
    }
    runApp(InitializationErrorScreen(error: errorMessage));
  }
}

void _runSeloApp() {
  runApp(
    ProviderScope(
      observers: [TalkerRiverpodObserver(talker: di<Talker>())],
      child: const SeloApp(),
    ),
  );
}
