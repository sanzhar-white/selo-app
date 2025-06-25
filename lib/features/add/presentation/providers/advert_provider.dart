import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:selo/core/di/di.dart';
import 'package:selo/features/add/domain/repositories/advert_repository.dart';
import 'package:selo/features/add/domain/usecases/create_ad_usecase.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:selo/features/add/data/datasources/firebase_datasource.dart';
import 'package:selo/features/add/data/datasources/advert_interface.dart';
import 'package:selo/features/add/data/repositories/advert_repository_impl.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'create/advert_state.dart';
import 'create/advert_notifier.dart';

final firebaseDatasourceProvider = Provider<AdvertInteface>((ref) {
  return FirebaseDatasource(
    di<FirebaseFirestore>(),
    di<FirebaseStorage>(),
    di<Talker>(),
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

final advertNotifierProvider =
    StateNotifierProvider<AdvertNotifier, AdvertState>((ref) {
      return AdvertNotifier(ref);
    });

extension AdvertModelFirebaseMap on AdvertModel {
  Map<String, dynamic> toFilteredMap() {
    final data = toMap();
    if (data['price'] == 0) {
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
    if (!data.containsKey('condition')) {
      data.remove('condition');
    }
    return data;
  }
}
