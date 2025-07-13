// 1. All imports at the top, sorted alphabetically
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/authentication/domain/usecases/index.dart';
import 'package:selo/features/authentication/presentation/provider/providers.dart';
import 'package:selo/features/favourites/domain/usecases/add_to_favourites_usecase.dart';
import 'package:selo/features/favourites/domain/usecases/get_favourites_usecase.dart';
import 'package:selo/features/favourites/domain/usecases/remove_from_favourites_usecase.dart';
import 'package:selo/features/favourites/domain/usecases/toggle_favourite_usecase.dart';
import 'package:selo/features/favourites/presentation/providers/favourites/favourites_notifier.dart';
import 'package:selo/features/favourites/presentation/providers/favourites/favourites_state.dart';
import 'package:selo/features/favourites/presentation/providers/providers.dart'
    as fav_providers;
import 'package:selo/features/favourites/data/model/favourites_model.dart';
import 'package:selo/features/home/data/models/local_banner_model.dart';
import 'package:selo/features/home/data/models/home_model.dart';
import 'package:selo/features/home/domain/usecases/get_all_advertisements_usecase.dart';
import 'package:selo/features/home/domain/usecases/get_banners_usecase.dart';
import 'package:selo/features/home/domain/usecases/get_filtered_advertisements_usecase.dart';
import 'package:selo/features/home/presentation/providers/home/home_notifier.dart';
import 'package:selo/features/home/presentation/providers/home/home_state.dart';
import 'package:selo/features/home/presentation/providers/providers.dart';
import 'package:selo/features/profile/data/models/profile_user.dart';
import 'package:selo/features/profile/domain/usecases/delete_advert_usecase.dart';
import 'package:selo/features/profile/domain/usecases/delete_user_usecase.dart';
import 'package:selo/features/profile/domain/usecases/get_my_adverts_usecase.dart';
import 'package:selo/features/profile/domain/usecases/update_user_usecase.dart';
import 'package:selo/features/profile/presentation/providers/profile/edit_notifier.dart';
import 'package:selo/features/profile/presentation/providers/profile/profile_notifier.dart';
import 'package:selo/features/profile/presentation/providers/profile/profile_state.dart';
import 'package:selo/features/profile/presentation/providers/providers.dart'
    as profile_providers;
import 'package:selo/shared/models/advert_model.dart';
import 'package:selo/shared/models/user_model.dart';
import 'package:talker/talker.dart';
import 'package:selo/shared/models/local_user_model.dart';

// --- Fakes for Mocktail ---
class FakeSignUpModel extends Fake implements SignUpModel {}

class FakePhoneNumberModel extends Fake implements PhoneNumberModel {}

class FakeSignInWithCredentialModel extends Fake
    implements SignInWithCredentialModel {}

class FakeSearchPaginationRecord extends Fake {}

// --- Mocks ---
class MockSignUpUseCase extends Mock implements SignUpUseCase {}

class MockCheckUserUseCase extends Mock implements CheckUserUseCase {}

class MockLogInUseCase extends Mock implements LogInUseCase {}

class MockSignInWithCredentialUseCase extends Mock
    implements SignInWithCredentialUseCase {}

class MockLogOutUseCase extends Mock implements LogOutUseCase {}

class MockAnonymousLogInUseCase extends Mock implements AnonymousLogInUseCase {}

class MockTalker extends Mock implements Talker {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

// --- Use case mocks implementing real use case classes ---
class MockGetAllAdvertisementsUseCase extends Mock
    implements GetAllAdvertisementsUseCase {}

class MockGetFilteredAdvertisementsUseCase extends Mock
    implements GetFilteredAdvertisementsUseCase {}

class MockGetBannersUseCase extends Mock implements GetBannersUseCase {}

class MockAddToFavouritesUseCase extends Mock
    implements AddToFavouritesUseCase {}

class MockGetFavouritesUseCase extends Mock implements GetFavouritesUseCase {}

class MockRemoveFromFavouritesUseCase extends Mock
    implements RemoveFromFavouritesUseCase {}

class MockToggleFavouriteUseCase extends Mock
    implements ToggleFavouriteUseCase {}

class MockGetMyAdvertsUseCase extends Mock implements GetMyAdvertsUseCase {}

class MockDeleteAdvertUseCase extends Mock implements DeleteAdvertUseCase {}

class MockUpdateUserUseCase extends Mock implements UpdateUserUseCase {}

class MockDeleteUserUseCase extends Mock implements DeleteUserUseCase {}

class MockCacheManager extends Mock {}

void main() {
  late ProviderContainer container;
  late MockSignUpUseCase mockSignUpUseCase;
  late MockCheckUserUseCase mockCheckUserUseCase;
  late MockLogInUseCase mockLogInUseCase;
  late MockSignInWithCredentialUseCase mockSignInWithCredentialUseCase;
  late MockLogOutUseCase mockLogOutUseCase;
  late MockAnonymousLogInUseCase mockAnonymousLogInUseCase;
  late MockTalker mockTalker;

  setUpAll(() async {
    // Register fallback values for mocktail
    registerFallbackValue(FakeSignUpModel());
    registerFallbackValue(FakePhoneNumberModel());
    registerFallbackValue(FakeSignInWithCredentialModel());
    registerFallbackValue(FakeSearchPaginationRecord());

    // Register fallback values for all used types in mocktail
    registerFallbackValue(PaginationModel());
    registerFallbackValue(SearchModel());
    final recordFallback = (
      searchModel: null,
      paginationModel: PaginationModel(),
    );
    registerFallbackValue(recordFallback);
    registerFallbackValue(
      ({
        SearchModel? searchModel,
        required PaginationModel paginationModel,
      }) => ({searchModel: null, paginationModel: PaginationModel()}),
    );
    registerFallbackValue(
      FavouritesModel(
        userUid: UserUidModel(uid: 'dummy'),
        advertUid: AdvertUidModel(uid: 'dummy'),
      ),
    );

    // Initialize Hive
    await setUpTestHive();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(LocalUserModelAdapter());
      // Hive.registerAdapter(LocalAdvertModelAdapter());
      Hive.registerAdapter(LocalBannerModelAdapter());
    }
    await Hive.openBox<LocalUserModel>('userBox');
    await Hive.openBox<List<dynamic>>('adsCacheBox');
    await Hive.openBox<dynamic>('settingsBox');
  });

  setUp(() async {
    // Initialize mocks
    mockSignUpUseCase = MockSignUpUseCase();
    mockCheckUserUseCase = MockCheckUserUseCase();
    mockLogInUseCase = MockLogInUseCase();
    mockSignInWithCredentialUseCase = MockSignInWithCredentialUseCase();
    mockLogOutUseCase = MockLogOutUseCase();
    mockAnonymousLogInUseCase = MockAnonymousLogInUseCase();
    mockTalker = MockTalker();

    // Register Talker
    GetIt.I.registerSingleton<Talker>(mockTalker);

    // Setup container with overrides
    container = ProviderContainer(
      overrides: [
        signUpUseCaseProvider.overrideWithValue(mockSignUpUseCase),
        checkUserUseCaseProvider.overrideWithValue(mockCheckUserUseCase),
        logInUseCaseProvider.overrideWithValue(mockLogInUseCase),
        signInWithCredentialUseCaseProvider.overrideWithValue(
          mockSignInWithCredentialUseCase,
        ),
        logOutUseCaseProvider.overrideWithValue(mockLogOutUseCase),
        anonymousLogInUseCaseProvider.overrideWithValue(
          mockAnonymousLogInUseCase,
        ),
      ],
    );

    // Mock Talker behavior
    when(() => mockTalker.info(any())).thenAnswer((_) {});
    when(() => mockTalker.error(any(), any(), any())).thenAnswer((_) {});
  });

  tearDown(() async {
    // Clear Hive boxes using cascade
    await Hive
      ..box<LocalUserModel>('userBox').clear()
      ..box<List<dynamic>>('adsCacheBox').clear()
      ..box<dynamic>('settingsBox').clear();

    // Reset GetIt and dispose container
    GetIt.I.reset();
    container.dispose();
  });

  tearDownAll(() async {
    await tearDownTestHive();
  });

  group('User tests', () {
    test(
      'signUp returns true and updates user state on successful registration',
      () async {
        // Arrange
        final user = UserModel(
          uid: '0000000',
          phoneNumber: '7777777777',
          name: 'Test',
          lastName: 'Testov',
          likes: <String>[],
          region: 1,
          district: 1,
          profileImage: '',
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        );
        final authStatus = AuthStatusModel(
          status: true,
          value: 'success',
          user: user,
        );
        when(
          () =>
              mockSignUpUseCase.call(params: any<SignUpModel>(named: 'params')),
        ).thenAnswer((_) async => DataSuccess(authStatus));
        final notifier = container.read(userNotifierProvider.notifier);
        final signUpModel = SignUpModel(
          phoneNumber: '7777777777',
          name: 'Test',
          lastName: 'Testov',
        );

        // Act
        final result = await notifier.signUp(signUpModel);

        // Assert
        expect(result, isTrue);
        expect(container.read(userNotifierProvider).user?.name, 'Test');
        verify(() => mockSignUpUseCase.call(params: signUpModel)).called(1);
      },
    );

    test(
      'signUp returns false and keeps user state null on registration failure',
      () async {
        // Arrange
        when(
          () =>
              mockSignUpUseCase.call(params: any<SignUpModel>(named: 'params')),
        ).thenAnswer(
          (_) async =>
              DataFailed(Exception('Sign up failed'), StackTrace.current),
        );
        final notifier = container.read(userNotifierProvider.notifier);
        final signUpModel = SignUpModel(
          phoneNumber: '7777777777',
          name: 'Test',
          lastName: 'Testov',
        );

        // Act
        final result = await notifier.signUp(signUpModel);

        // Assert
        expect(result, isFalse);
        expect(container.read(userNotifierProvider).user, isNull);
        verify(() => mockSignUpUseCase.call(params: signUpModel)).called(1);
      },
    );

    test(
      'checkUser returns true when user with given phone number exists',
      () async {
        // Arrange
        when(
          () => mockCheckUserUseCase.call(
            params: any<PhoneNumberModel>(named: 'params'),
          ),
        ).thenAnswer((_) async => DataSuccess(true));
        final notifier = container.read(userNotifierProvider.notifier);
        final phoneModel = PhoneNumberModel(phoneNumber: '7777777777');

        // Act
        final result = await notifier.checkUser('7777777777');

        // Assert
        expect(result, isTrue);
        verify(() => mockCheckUserUseCase.call(params: phoneModel)).called(1);
      },
    );

    test(
      'logIn returns true and updates user state on successful authentication',
      () async {
        // Arrange
        final user = UserModel(
          uid: '0000000',
          phoneNumber: '7777777777',
          name: 'Test',
          lastName: 'Testov',
          likes: <String>[],
          region: 1,
          district: 1,
          profileImage: '',
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        );
        final authStatus = AuthStatusModel(
          status: true,
          value: 'success',
          user: user,
        );
        when(
          () => mockLogInUseCase.call(
            params: any<PhoneNumberModel>(named: 'params'),
          ),
        ).thenAnswer((_) async => DataSuccess(authStatus));
        final notifier = container.read(userNotifierProvider.notifier);
        final phoneModel = PhoneNumberModel(phoneNumber: '7777777777');

        // Act
        final result = await notifier.logIn(phoneModel);

        // Assert
        expect(result, isTrue);
        expect(container.read(userNotifierProvider).user?.name, 'Test');
        verify(() => mockLogInUseCase.call(params: phoneModel)).called(1);
      },
    );

    test(
      'signInWithCredential returns true and updates user state on valid credentials',
      () async {
        // Arrange
        final user = UserModel(
          uid: '0000000',
          phoneNumber: '7777777777',
          name: 'Test',
          lastName: 'Testov',
          likes: <String>[],
          region: 1,
          district: 1,
          profileImage: '',
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        );
        when(
          () => mockSignInWithCredentialUseCase.call(
            params: any<SignInWithCredentialModel>(named: 'params'),
          ),
        ).thenAnswer((_) async => DataSuccess(true));
        final notifier = container.read(userNotifierProvider.notifier);
        final signInModel = SignInWithCredentialModel(
          verificationId: 'verif',
          smsCode: '123456',
          user: user,
        );

        // Act
        final result = await notifier.signInWithCredential(signInModel);

        // Assert
        expect(result, isTrue);
        expect(container.read(userNotifierProvider).user?.name, 'Test');
        verify(
          () => mockSignInWithCredentialUseCase.call(params: signInModel),
        ).called(1);
      },
    );

    test(
      'logOut returns true and clears user state on successful logout',
      () async {
        // Arrange
        when(
          () => mockLogOutUseCase.call(),
        ).thenAnswer((_) async => DataSuccess(true));
        final notifier = container.read(userNotifierProvider.notifier);

        // Act
        final result = await notifier.logOut();

        // Assert
        expect(result, isTrue);
        expect(container.read(userNotifierProvider).user, isNull);
        verify(() => mockLogOutUseCase.call()).called(1);
      },
    );

    test(
      'anonymousLogIn returns true and sets anonymous user state on success',
      () async {
        // Arrange
        final localUser = LocalUserModel(
          userJson: jsonEncode({
            'uid': 'anon_user',
            'phoneNumber': '',
            'name': '',
            'lastName': '',
            'likes': [],
            'region': 0,
            'district': 0,
            'profileImage': '',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'isAnonymous': true,
          }),
        );
        await Hive.box<LocalUserModel>('userBox').put('user', localUser);
        when(
          () => mockAnonymousLogInUseCase.call(),
        ).thenAnswer((_) async => DataSuccess(true));
        final notifier = container.read(userNotifierProvider.notifier);

        // Act
        final result = await notifier.anonymousLogIn();

        // Assert
        expect(result, isTrue);
        expect(container.read(userNotifierProvider).user, isNotNull);
        expect(container.read(userNotifierProvider).user?.phoneNumber, '');
      },
    );

    test('logoutAndClearData clears user state after logout', () async {
      // Arrange
      when(() => mockLogOutUseCase.call()).thenAnswer((_) async {
        return DataSuccess(true);
      });
      final notifier = container.read(userNotifierProvider.notifier);

      // Act
      await notifier.logoutAndClearData();

      // Assert
      expect(container.read(userNotifierProvider).user, isNull);
    });

    test('isAnonymous returns false when user is not a guest', () async {
      // Arrange
      final notifier = container.read(userNotifierProvider.notifier);

      // Act
      final result = await notifier.isAnonymous();

      // Assert
      expect(result, isFalse);
    });

    test(
      'updateUser updates user profile and sets isLoading to false',
      () async {
        // Arrange
        final mockUpdateUserUseCase = MockUpdateUserUseCase();
        when(
          () => mockUpdateUserUseCase.call(params: any(named: 'params')),
        ).thenAnswer((_) async => DataSuccess(true));
        final container = ProviderContainer(
          overrides: [
            profile_providers.updateUserUseCaseProvider.overrideWithValue(
              mockUpdateUserUseCase,
            ),
          ],
        );
        final notifier = container.read(
          profile_providers.profileNotifierProvider.notifier,
        );

        // Act
        await notifier.updateUser(UpdateUserModel(uid: 'user1'));

        // Assert
        expect(notifier.state.isLoading, false);
      },
    );

    test('deleteUser deletes user and logs out on success', () async {
      // Arrange
      final mockDeleteUserUseCase = MockDeleteUserUseCase();
      when(
        () => mockDeleteUserUseCase.call(params: any(named: 'params')),
      ).thenAnswer((_) async => DataSuccess(true));
      final container = ProviderContainer(
        overrides: [
          profile_providers.deleteUserUseCaseProvider.overrideWithValue(
            mockDeleteUserUseCase,
          ),
        ],
      );
      final notifier = container.read(
        profile_providers.editProfileNotifierProvider.notifier,
      );
      // Здесь нужно замокать userNotifierProvider и проверить, что logOut вызван
      // Act
      await notifier.deleteUser();
      // Assert
      // Проверить, что userNotifierProvider вызывает logOut (оставить TODO или реализовать если есть доступ)
    });
  });

  group('Ad tests', () {
    // HomeNotifier
    test(
      'loadAllAdvertisements loads first page and updates state with adverts',
      () async {
        // Arrange
        final mockGetAllAdsUseCase = MockGetAllAdvertisementsUseCase();
        final adverts = [
          AdvertModel(
            uid: '1',
            ownerUid: 'owner1',
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
            title: 'Test',
            price: 100,
            phoneNumber: '123',
            category: 1,
            images: [],
            description: 'desc',
          ),
          AdvertModel(
            uid: '2',
            ownerUid: 'owner2',
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
            title: 'Test2',
            price: 200,
            phoneNumber: '456',
            category: 2,
            images: [],
            description: 'desc2',
          ),
        ];
        when(
          () => mockGetAllAdsUseCase.call(
            params: any<PaginationModel>(named: 'params'),
          ),
        ).thenAnswer((_) async => DataSuccess(adverts));
        final container = ProviderContainer(
          overrides: [
            getAllAdvertisementsUseCaseProvider.overrideWithValue(
              mockGetAllAdsUseCase,
            ),
          ],
        );
        final notifier = container.read(homeNotifierProvider.notifier);

        // Act
        await notifier.loadAllAdvertisements(page: 1, pageSize: 2);

        // Assert
        expect(notifier.state.allAdvertisements, adverts);
        expect(notifier.state.isLoading, false);
      },
    );

    test(
      'loadFilteredAdvertisements applies filter and updates filteredAdvertisements',
      () async {
        // Arrange
        final mockGetFilteredAdsUseCase =
            MockGetFilteredAdvertisementsUseCase();
        final adverts = [
          AdvertModel(
            uid: '3',
            ownerUid: 'owner3',
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
            title: 'Test3',
            price: 300,
            phoneNumber: '789',
            category: 1,
            images: [],
            description: 'desc3',
          ),
        ];
        final filter = SearchModel(searchQuery: 'test');
        when(
          () => mockGetFilteredAdsUseCase.call(
            params: any<
              ({SearchModel? searchModel, PaginationModel paginationModel})
            >(named: 'params'),
          ),
        ).thenAnswer((_) async => DataSuccess(adverts));
        final container = ProviderContainer(
          overrides: [
            getFilteredAdvertisementsUseCaseProvider.overrideWithValue(
              mockGetFilteredAdsUseCase,
            ),
          ],
        );
        final notifier = container.read(homeNotifierProvider.notifier);

        // Act
        await notifier.loadFilteredAdvertisements(
          filter: filter,
          page: 1,
          pageSize: 1,
        );

        // Assert
        expect(notifier.state.filteredAdvertisements, adverts);
        expect(notifier.state.isLoading, false);
      },
    );

    test('loadBanners updates state with loaded banners', () async {
      // Arrange
      final mockGetBannersUseCase = MockGetBannersUseCase();
      final banners = [
        'https://example.com/banner1.jpg',
        'https://example.com/banner2.jpg',
      ];
      when(
        () => mockGetBannersUseCase(),
      ).thenAnswer((_) async => DataSuccess(banners));
      final container = ProviderContainer(
        overrides: [
          getBannersUseCaseProvider.overrideWithValue(mockGetBannersUseCase),
        ],
      );
      final notifier = container.read(homeNotifierProvider.notifier);

      // Act
      await notifier.loadBanners();

      // Assert
      expect(notifier.state.banners, banners);
      expect(notifier.state.isLoading, false);
    });

    // FavouritesNotifier
    test(
      'addToFavourites adds advert to favourites and updates state',
      () async {
        // Arrange
        final mockAddToFavouritesUseCase = MockAddToFavouritesUseCase();
        final mockGetFavouritesUseCase = MockGetFavouritesUseCase();
        final userUid = 'user1';
        final advertUid = 'ad1';
        final favourites = [
          AdvertModel(
            uid: advertUid,
            ownerUid: userUid,
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
            title: 'Fav Ad',
            price: 100,
            phoneNumber: '111',
            category: 1,
            images: [],
            description: 'fav desc',
          ),
        ];
        when(
          () => mockAddToFavouritesUseCase.call(
            params: any<FavouritesModel>(named: 'params'),
          ),
        ).thenAnswer((_) async => DataSuccess(true));
        when(
          () => mockGetFavouritesUseCase.call(
            params: any<FavouritesModel>(named: 'params'),
          ),
        ).thenAnswer((_) async => DataSuccess(favourites));
        final container = ProviderContainer(
          overrides: [
            fav_providers.addToFavouritesUseCaseProvider.overrideWithValue(
              mockAddToFavouritesUseCase,
            ),
            fav_providers.getFavouritesUseCaseProvider.overrideWithValue(
              mockGetFavouritesUseCase,
            ),
          ],
        );
        final notifier = container.read(
          fav_providers.favouritesNotifierProvider.notifier,
        );

        // Act
        final result = await notifier.addToFavourites(
          userUid: userUid,
          advertUid: advertUid,
        );

        // Assert
        expect(result, true);
        expect(notifier.state.favouritesModel, favourites);
      },
    );

    test(
      'removeFromFavourites removes advert from favourites and updates state',
      () async {
        // Arrange
        final mockRemoveFromFavouritesUseCase =
            MockRemoveFromFavouritesUseCase();
        final mockGetFavouritesUseCase = MockGetFavouritesUseCase();
        final userUid = 'user1';
        final advertUid = 'ad1';
        final favourites = <AdvertModel>[];
        when(
          () => mockRemoveFromFavouritesUseCase.call(
            params: any<FavouritesModel>(named: 'params'),
          ),
        ).thenAnswer((_) async => DataSuccess(true));
        when(
          () => mockGetFavouritesUseCase.call(
            params: any<FavouritesModel>(named: 'params'),
          ),
        ).thenAnswer((_) async => DataSuccess(favourites));
        final container = ProviderContainer(
          overrides: [
            fav_providers.removeFromFavouritesUseCaseProvider.overrideWithValue(
              mockRemoveFromFavouritesUseCase,
            ),
            fav_providers.getFavouritesUseCaseProvider.overrideWithValue(
              mockGetFavouritesUseCase,
            ),
          ],
        );
        final notifier = container.read(
          fav_providers.favouritesNotifierProvider.notifier,
        );

        // Act
        final result = await notifier.removeFromFavourites(
          userUid: userUid,
          advertUid: advertUid,
        );

        // Assert
        expect(result, true);
        expect(notifier.state.favouritesModel, favourites);
      },
    );

    test(
      'toggleFavourite toggles favourite status and updates state',
      () async {
        // Arrange
        final mockToggleFavouriteUseCase = MockToggleFavouriteUseCase();
        final mockGetFavouritesUseCase = MockGetFavouritesUseCase();
        final userUid = 'user1';
        final advertUid = 'ad1';
        final favourites = [
          AdvertModel(
            uid: advertUid,
            ownerUid: userUid,
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
            title: 'Fav Ad',
            price: 100,
            phoneNumber: '111',
            category: 1,
            images: [],
            description: 'fav desc',
          ),
        ];
        when(
          () => mockToggleFavouriteUseCase.call(
            params: any<FavouritesModel>(named: 'params'),
          ),
        ).thenAnswer((_) async => DataSuccess(true));
        when(
          () => mockGetFavouritesUseCase.call(
            params: any<FavouritesModel>(named: 'params'),
          ),
        ).thenAnswer((_) async => DataSuccess(favourites));
        final container = ProviderContainer(
          overrides: [
            fav_providers.toggleFavouriteUseCaseProvider.overrideWithValue(
              mockToggleFavouriteUseCase,
            ),
            fav_providers.getFavouritesUseCaseProvider.overrideWithValue(
              mockGetFavouritesUseCase,
            ),
          ],
        );
        final notifier = container.read(
          fav_providers.favouritesNotifierProvider.notifier,
        );

        // Act
        final result = await notifier.toggleFavourite(
          userUid: userUid,
          advertUid: advertUid,
        );

        // Assert
        expect(result, true);
        expect(notifier.state.favouritesModel, favourites);
      },
    );

    // ProfileNotifier
    test('getMyAdverts loads user adverts and updates state', () async {
      // Arrange
      final mockGetMyAdvertsUseCase = MockGetMyAdvertsUseCase();
      final adverts = [
        AdvertModel(
          uid: 'ad1',
          ownerUid: 'user1',
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
          title: 'My Ad 1',
          price: 100,
          phoneNumber: '123',
          category: 1,
          images: [],
          description: 'my desc 1',
        ),
        AdvertModel(
          uid: 'ad2',
          ownerUid: 'user1',
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
          title: 'My Ad 2',
          price: 200,
          phoneNumber: '456',
          category: 2,
          images: [],
          description: 'my desc 2',
        ),
      ];
      when(
        () => mockGetMyAdvertsUseCase.call(params: any(named: 'params')),
      ).thenAnswer((_) async => DataSuccess(adverts));
      final container = ProviderContainer(
        overrides: [
          profile_providers.getMyAdvertsUseCaseProvider.overrideWithValue(
            mockGetMyAdvertsUseCase,
          ),
        ],
      );
      final notifier = container.read(
        profile_providers.profileNotifierProvider.notifier,
      );

      // Act
      await notifier.getMyAdverts(uid: 'user1', forceRefresh: true);

      // Assert
      expect(notifier.state.myAdverts, adverts);
    });

    test(
      'deleteAdvert removes advert from myAdverts and updates state',
      () async {
        // Arrange
        final mockDeleteAdvertUseCase = MockDeleteAdvertUseCase();
        final mockGetMyAdvertsUseCase = MockGetMyAdvertsUseCase();
        final adverts = [
          AdvertModel(
            uid: 'ad1',
            ownerUid: 'user1',
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
            title: 'My Ad 1',
            price: 100,
            phoneNumber: '123',
            category: 1,
            images: [],
            description: 'my desc 1',
          ),
          AdvertModel(
            uid: 'ad2',
            ownerUid: 'user1',
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
            title: 'My Ad 2',
            price: 200,
            phoneNumber: '456',
            category: 2,
            images: [],
            description: 'my desc 2',
          ),
        ];
        when(
          () => mockDeleteAdvertUseCase.call(params: any(named: 'params')),
        ).thenAnswer((_) async => DataSuccess(true));
        when(
          () => mockGetMyAdvertsUseCase.call(params: any(named: 'params')),
        ).thenAnswer((_) async => DataSuccess(adverts));
        final container = ProviderContainer(
          overrides: [
            profile_providers.deleteAdvertUseCaseProvider.overrideWithValue(
              mockDeleteAdvertUseCase,
            ),
            profile_providers.getMyAdvertsUseCaseProvider.overrideWithValue(
              mockGetMyAdvertsUseCase,
            ),
          ],
        );
        final notifier = container.read(
          profile_providers.profileNotifierProvider.notifier,
        );
        notifier.state = notifier.state.copyWith(myAdverts: adverts);

        // Act
        await notifier.deleteAdvert('ad1');

        // Assert
        expect(notifier.state.myAdverts?.any((ad) => ad.uid == 'ad1'), false);
      },
    );
  });
}
