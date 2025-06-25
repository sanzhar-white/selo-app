import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:selo/core/services/crashlytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

final GetIt di = GetIt.instance;
void initDependencies() {
  di.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  di.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  di.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);
  di.registerSingleton<FirebaseCrashlytics>(FirebaseCrashlytics.instance);
  di.registerLazySingleton<Talker>(
    () => TalkerFlutter.init(observer: CrashlyticsObserver()),
  );
}
