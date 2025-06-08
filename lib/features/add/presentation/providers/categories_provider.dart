import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/add/data/datasources/categories_interface.dart';
import 'package:selo/features/add/data/datasources/firebase_datasource.dart';
import 'package:selo/features/add/data/repositories/categories_repository_impl.dart';
import 'package:selo/features/add/domain/repositories/categories_repository.dart';
import 'package:selo/features/add/domain/usecases/get_categories_usecase.dart';

// Провайдер FirebaseDatasource для категорий
final categoriesDatasourceProvider = Provider<CategoriesInteface>((ref) {
  return FirebaseDatasource(
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
  );
});

// Провайдер репозитория категорий
final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  final datasource = ref.watch(categoriesDatasourceProvider);
  return CategoriesRepositoryImpl(datasource);
});

// Провайдер use case для получения категорий
final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  final repository = ref.watch(categoriesRepositoryProvider);
  return GetCategoriesUseCase(repository);
});

// Провайдер состояния категорий
final categoriesNotifierProvider =
    StateNotifierProvider<CategoriesNotifier, AsyncValue<List<AdCategory>>>((
      ref,
    ) {
      return CategoriesNotifier(ref);
    });

// Notifier для управления состоянием категорий
class CategoriesNotifier extends StateNotifier<AsyncValue<List<AdCategory>>> {
  final Ref ref;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 10);

  CategoriesNotifier(this.ref) : super(const AsyncValue.data([]));

  // Загрузка категорий с кэшированием
  Future<void> loadCategories({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration &&
        state.value != null &&
        state.value!.isNotEmpty) {
      return;
    }

    state = const AsyncValue.loading();
    try {
      final useCase = ref.read(getCategoriesUseCaseProvider);
      final result = await useCase.call();
      if (result is DataSuccess) {
        state = AsyncValue.data(result.data as List<AdCategory>);
        _lastFetchTime = DateTime.now();
      } else if (result is DataFailed && result.error != null) {
        state = AsyncValue.error(result.error!, StackTrace.current);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Обновление категорий
  Future<void> refreshCategories() async {
    await loadCategories(forceRefresh: true);
  }
}
