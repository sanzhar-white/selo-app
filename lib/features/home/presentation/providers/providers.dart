import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selo/features/home/data/datasources/home_interface.dart';
import 'package:selo/features/home/data/datasources/firebase_datasource.dart';
import 'package:selo/features/home/data/repositories/home_repository_impl.dart';
import 'package:selo/features/home/domain/repositories/home_repository.dart';
import 'package:selo/features/home/domain/usecases/index.dart';
import 'home/home_notifier.dart';
import 'home/home_state.dart';

final firebaseDatasourceProvider =
    Provider<HomeScreenRemoteDataSourceInterface>(
      (ref) => FirebaseHomeScreenRemoteDataSource(
        firestore: FirebaseFirestore.instance,
      ),
    );

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepositoryImpl(ref.watch(firebaseDatasourceProvider)),
);

final getBannersUseCaseProvider = Provider<GetBannersUseCase>(
  (ref) => GetBannersUseCase(ref.watch(homeRepositoryProvider)),
);

final getAllAdvertisementsUseCaseProvider =
    Provider<GetAllAdvertisementsUseCase>(
      (ref) => GetAllAdvertisementsUseCase(ref.watch(homeRepositoryProvider)),
    );

final getFilteredAdvertisementsUseCaseProvider = Provider<
  GetFilteredAdvertisementsUseCase
>((ref) => GetFilteredAdvertisementsUseCase(ref.watch(homeRepositoryProvider)));

final viewAdvertUseCaseProvider = Provider<ViewAdvertUseCase>(
  (ref) => ViewAdvertUseCase(ref.watch(homeRepositoryProvider)),
);

final homeNotifierProvider = StateNotifierProvider<HomeNotifier, HomeState>(
  (ref) => HomeNotifier(ref),
);
