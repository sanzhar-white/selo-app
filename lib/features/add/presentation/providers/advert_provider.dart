import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:selo/features/add/domain/repositories/advert_repository.dart';
import 'package:selo/features/add/domain/usecases/create_ad_usecase.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:selo/features/add/data/datasources/firebase_datasource.dart';
import 'package:selo/features/add/data/datasources/advert_interface.dart';
import 'package:selo/features/add/data/repositories/advert_repository_impl.dart';
import 'package:selo/core/resources/data_state.dart';

final firebaseDatasourceProvider = Provider<AdvertInteface>((ref) {
  return FirebaseDatasource(
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
  );
});

final advertRepositoryProvider = Provider<AdvertRepository>((ref) {
  final datasource = ref.watch(firebaseDatasourceProvider);
  return AdvertRepositoryImpl(datasource);
});

final createAdUseCaseProvider = Provider<CreateAdUseCase>((ref) {
  final repository = ref.watch(advertRepositoryProvider);
  return CreateAdUseCase(repository);
});

class AdvertState {
  final AdvertModel? advert;
  final bool isLoading;
  final String? error;

  const AdvertState({this.advert, this.isLoading = false, this.error});

  AdvertState copyWith({AdvertModel? advert, bool? isLoading, String? error}) {
    return AdvertState(
      advert: advert ?? this.advert,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final advertNotifierProvider =
    StateNotifierProvider<AdvertNotifier, AdvertState>((ref) {
      return AdvertNotifier(ref);
    });

class AdvertNotifier extends StateNotifier<AdvertState> {
  final Ref ref;

  AdvertNotifier(this.ref) : super(const AdvertState());

  Future<bool> createAdvert(AdvertModel advert) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = ref.read(createAdUseCaseProvider);
      final filteredData = advert.toFilteredMap();
      final cleanAdvert = AdvertModel.fromMap(filteredData);
      final result = await useCase.call(params: cleanAdvert);
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

extension AdvertModelFirebaseMap on AdvertModel {
  Map<String, dynamic> toFilteredMap() {
    final data = toMap();
    if (!tradeable) {
      data['price'] = 0;
      data['maxPrice'] = 0;
      data['unitPer'] = 'kg';
    }
    if (quantity == 0) {
      data['quantity'] = 0;
      data['maxQuantity'] = 0;
      data['unit'] = 'kg';
    }
    if (companyName?.isEmpty ?? true) {
      data.remove('companyName');
    }
    if (contactPerson?.isEmpty ?? true) {
      data.remove('contactPerson');
    }
    if (year == 0) {
      data.remove('year');
    }
    if (condition == 0 && !data.containsKey('condition')) {
      data.remove('condition');
    }
    return data;
  }
}
