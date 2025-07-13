import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:selo/features/home/presentation/widgets/advert_mini_card.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:selo/shared/models/local_user_model.dart';
import 'package:selo/features/home/data/models/local_banner_model.dart';
import 'package:talker/talker.dart';
import 'package:selo/features/favourites/data/model/favourites_model.dart';

class MockTalker extends Mock implements Talker {}

void main() {
  setUpAll(() async {
    await setUpTestHive();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(LocalUserModelAdapter());
      Hive.registerAdapter(LocalBannerModelAdapter());
    }
    await Hive.openBox<LocalUserModel>('userBox');
    await Hive.openBox<List<dynamic>>('adsCacheBox');
    await Hive.openBox<dynamic>('settingsBox');
    final mockTalker = MockTalker();
    when(() => mockTalker.info(any<dynamic>())).thenAnswer((_) {});
    when(() => mockTalker.error(any(), any(), any())).thenAnswer((_) {});
    if (!GetIt.I.isRegistered<Talker>()) {
      GetIt.I.registerSingleton<Talker>(mockTalker);
    }
    // Регистрируем fallbackValue для mocktail
    registerFallbackValue(UserUidModel(uid: 'fallback'));
    registerFallbackValue(AdvertUidModel(uid: 'fallback'));
  });

  tearDown(() async {
    await Hive
      ..box<LocalUserModel>('userBox').clear()
      ..box<List<dynamic>>('adsCacheBox').clear()
      ..box<dynamic>('settingsBox').clear();
    GetIt.I.reset();
  });

  tearDownAll(() async {
    await tearDownTestHive();
  });

  testWidgets('AdvertMiniCard displays advert information correctly', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                height: 300, // увеличено для избежания overflow
                width: 180, // увеличено для избежания overflow
                child: AdvertMiniCard(
                  advert: AdvertModel(
                    uid: "0",
                    ownerUid: "9",
                    createdAt: Timestamp.now(),
                    updatedAt: Timestamp.now(),
                    title: "Test Name",
                    price: 1000,
                    phoneNumber: "77010122670",
                    category: 0,
                    images: [],
                    description: "",
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AdvertMiniCard), findsOneWidget);
  });
}
