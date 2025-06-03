// lib/features/add/presentation/providers/advert_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:selo/features/add/domain/repositories/advert_repository.dart';
import 'package:selo/features/add/domain/usecases/create_ad_usecase.dart';
import 'package:selo/features/add/domain/entities/advert_entity.dart';
import 'package:selo/features/add/data/datasources/firebase_datasource.dart';
import 'package:selo/features/add/data/datasources/advert_interface.dart';
import 'package:selo/features/add/data/repositories/advert_repository_impl.dart';
import 'package:selo/core/resources/data_state.dart';

// Provider for FirebaseDatasource
final firebaseDatasourceProvider = Provider<AdvertInteface>((ref) {
  return FirebaseDatasource(
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
  );
});

// Provider for repository
final advertRepositoryProvider = Provider<AdvertRepository>((ref) {
  final datasource = ref.watch(firebaseDatasourceProvider);
  return AdvertRepositoryImpl(datasource);
});

// Provider for use case
final createAdUseCaseProvider = Provider<CreateAdUseCase>((ref) {
  final repository = ref.watch(advertRepositoryProvider);
  return CreateAdUseCase(repository);
});

// State class to handle loading and error states
class AdvertState {
  final AdvertEntity? advert;
  final bool isLoading;
  final String? error;

  const AdvertState({this.advert, this.isLoading = false, this.error});

  AdvertState copyWith({AdvertEntity? advert, bool? isLoading, String? error}) {
    return AdvertState(
      advert: advert ?? this.advert,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Provider for state
final advertNotifierProvider =
    StateNotifierProvider<AdvertNotifier, AdvertState>((ref) {
      return AdvertNotifier(ref);
    });

// Notifier for managing advert state
class AdvertNotifier extends StateNotifier<AdvertState> {
  final Ref ref;

  AdvertNotifier(this.ref) : super(const AdvertState());

  Future<bool> createAdvert(AdvertEntity advert) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(createAdUseCaseProvider);
      final result = await useCase.call(params: advert);

      if (result is DataSuccess) {
        state = state.copyWith(
          advert: result.data,
          isLoading: false,
          error: null,
        );
        return true;
      } else if (result is DataFailed) {
        state = state.copyWith(
          isLoading: false,
          error: result.error.toString(),
        );
        return false;
      }

      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
