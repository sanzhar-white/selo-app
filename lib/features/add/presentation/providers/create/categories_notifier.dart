import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/core/resources/data_state.dart';
import '../categories_provider.dart';

class CategoriesNotifier extends StateNotifier<AsyncValue<List<AdCategory>>> {

  CategoriesNotifier(this.ref) : super(const AsyncValue.data([]));
  final Ref ref;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 10);

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
        state = AsyncValue.data(result.data!);
        _lastFetchTime = DateTime.now();
      } else if (result is DataFailed && result.error != null) {
        state = AsyncValue.error(result.error!, StackTrace.current);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshCategories() async {
    await loadCategories(forceRefresh: true);
  }
}
