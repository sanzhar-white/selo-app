// lib/features/add/presentation/providers/advert_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selo/features/add/domain/repositories/advert_repository.dart';
import 'package:selo/features/add/domain/usecases/create_ad_usecase.dart';
import 'package:selo/features/add/domain/entities/advert_entity.dart';
import 'package:selo/features/add/data/datasources/firebase_datasource.dart';
import 'package:selo/features/add/data/datasources/advert_interface.dart';
import 'package:selo/features/add/data/repositories/advert_repository_impl.dart';
import 'package:selo/core/resources/data_state.dart';

// Провайдер FirebaseDatasource
final firebaseDatasourceProvider = Provider<AdvertInteface>((ref) {
  return FirebaseDatasource(FirebaseFirestore.instance);
});

// Провайдер репозитория
final advertRepositoryProvider = Provider<AdvertRepository>((ref) {
  final datasource = ref.watch(firebaseDatasourceProvider);
  return AdvertRepositoryImpl(datasource);
});

// Провайдер use case
final createAdUseCaseProvider = Provider<CreateAdUseCase>((ref) {
  final repository = ref.watch(advertRepositoryProvider);
  return CreateAdUseCase(repository);
});

// Провайдер состояния
final advertNotifierProvider =
    StateNotifierProvider<AdvertNotifier, AsyncValue<AdvertEntity?>>((ref) {
      return AdvertNotifier(ref);
    });

// Notifier для управления состоянием
class AdvertNotifier extends StateNotifier<AsyncValue<AdvertEntity?>> {
  final Ref ref;

  AdvertNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> createAd(AdvertEntity advert) async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.read(createAdUseCaseProvider);
      final result = await useCase.call(params: advert);
      if (result is DataSuccess) {
        state = AsyncValue.data(result.data);
      } else if (result is DataFailed && result.error != null) {
        state = AsyncValue.error(result.error!, StackTrace.current);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
