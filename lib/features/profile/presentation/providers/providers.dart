import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/di/di.dart';
import 'package:selo/features/profile/data/datasources/firebase_datasource.dart';
import 'package:selo/features/profile/data/datasources/profile_interface.dart';
import 'package:selo/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:selo/features/profile/domain/repositories/profile_repository.dart';
import 'package:selo/features/profile/domain/usecases/delete_advert_usecase.dart';
import 'package:selo/features/profile/domain/usecases/delete_user_usecase.dart';
import 'package:selo/features/profile/domain/usecases/get_my_adverts_usecase.dart';
import 'package:selo/features/profile/domain/usecases/update_user_usecase.dart';
import 'package:selo/core/services/cache_manager.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'index.dart';
import 'package:image_picker/image_picker.dart';

final firebaseDatasourceProvider = Provider<ProfileInterface>(
  (ref) => FirebaseProfileRemoteDataSource(
    firestore: di<FirebaseFirestore>(),
    storage: di<FirebaseStorage>(),
    talker: di<Talker>(),
  ),
);
final cacheManagerProvider = Provider<CacheManager>((ref) => CacheManager());

final selectedImageProvider = StateProvider<XFile?>((ref) => null);

final imagePickerProvider = Provider((_) => ImagePicker());

final editProfileNotifierProvider =
    AsyncNotifierProvider<EditProfileNotifier, void>(EditProfileNotifier.new);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ref.watch(firebaseDatasourceProvider)),
);

final getMyAdvertsUseCaseProvider = Provider<GetMyAdvertsUseCase>(
  (ref) => GetMyAdvertsUseCase(ref.watch(profileRepositoryProvider)),
);

final deleteAdvertUseCaseProvider = Provider<DeleteAdvertUseCase>(
  (ref) => DeleteAdvertUseCase(ref.watch(profileRepositoryProvider)),
);

final deleteUserUseCaseProvider = Provider<DeleteUserUseCase>(
  (ref) => DeleteUserUseCase(ref.watch(profileRepositoryProvider)),
);

final updateUserUseCaseProvider = Provider<UpdateUserUseCase>(
  (ref) => UpdateUserUseCase(ref.watch(profileRepositoryProvider)),
);

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
      return ProfileNotifier(
        ref: ref,
        logger: di<Talker>(),
        cacheManager: ref.read(cacheManagerProvider),
      );
    });
