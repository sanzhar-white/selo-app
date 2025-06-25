import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:selo/core/di/di.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/add/data/datasources/categories_interface.dart';
import 'package:selo/features/add/data/datasources/firebase_datasource.dart';
import 'package:selo/features/add/data/repositories/categories_repository_impl.dart';
import 'package:selo/features/add/domain/repositories/categories_repository.dart';
import 'package:selo/features/add/domain/usecases/get_categories_usecase.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'index.dart';

final categoriesDatasourceProvider = Provider<CategoriesInteface>((ref) {
  return FirebaseDatasource(
    di<FirebaseFirestore>(),
    di<FirebaseStorage>(),
    di<Talker>(),
  );
});

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  final datasource = ref.watch(categoriesDatasourceProvider);
  return CategoriesRepositoryImpl(datasource);
});

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  final repository = ref.watch(categoriesRepositoryProvider);
  return GetCategoriesUseCase(repository);
});

final categoriesNotifierProvider =
    StateNotifierProvider<CategoriesNotifier, AsyncValue<List<AdCategory>>>((
      ref,
    ) {
      return CategoriesNotifier(ref);
    });
