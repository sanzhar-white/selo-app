import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:selo/core/di/di.dart';

class CrashlyticsObserver extends TalkerObserver {
  @override
  void onError(TalkerError err) {
    di<FirebaseCrashlytics>().recordError(
      err.error,
      err.stackTrace,
      reason: err.message,
    );
  }

  @override
  void onException(TalkerException err) {
    di<FirebaseCrashlytics>().recordError(
      err.exception,
      err.stackTrace,
      reason: err.message,
    );
  }
}
