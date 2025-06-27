import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/features/init/data/datasources/init_datasource.dart';
import 'package:selo/features/init/data/models/init_state_model.dart';
import 'package:selo/features/init/data/repositories/init_repository_impl.dart';
import 'package:selo/features/init/domain/usecases/get_initial_state_usecase.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/home/presentation/providers/index.dart';
import 'package:selo/features/favourites/presentation/providers/index.dart';
import 'package:selo/features/add/presentation/providers/categories_provider.dart';
import 'package:selo/features/home/presentation/providers/home/home_notifier.dart';
import 'package:selo/features/home/presentation/providers/home/home_state.dart';
import 'package:selo/features/authentication/presentation/provider/index.dart';
import 'package:selo/features/favourites/data/model/favourites_model.dart';

final Provider<InitDatasource> initDatasourceProvider = Provider(
  (ref) => InitDatasource(),
);

final Provider<InitRepositoryImpl> initRepositoryProvider = Provider(
  (ref) => InitRepositoryImpl(ref.watch(initDatasourceProvider)),
);

final Provider<GetInitialStateUseCase> getInitialStateUseCaseProvider =
    Provider(
      (ref) => GetInitialStateUseCase(ref.watch(initRepositoryProvider)),
    );

final initStateProvider =
    StateNotifierProvider<InitStateNotifier, InitStateModel>((ref) {
      return InitStateNotifier(ref.watch(getInitialStateUseCaseProvider), ref);
    });

class InitStateNotifier extends StateNotifier<InitStateModel> {
  InitStateNotifier(this._getInitialStateUseCase, this.ref)
    : super(const InitStateModel());
  final GetInitialStateUseCase _getInitialStateUseCase;
  final Ref ref;

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      // Eager data loading
      final categoriesFuture =
          ref.read(categoriesNotifierProvider.notifier).loadCategories();
      final homeNotifier = ref.read(homeNotifierProvider.notifier);
      final bannersFuture = homeNotifier.loadBanners();
      final advertsFuture = homeNotifier.loadAllAdvertisements();
      final user = ref.read(userNotifierProvider).user;
      Future favouritesFuture = Future.value();
      if (user != null) {
        favouritesFuture = ref
            .read(favouritesNotifierProvider.notifier)
            .getFavourites(UserUidModel(uid: user.uid));
      }
      final results = await Future.wait([
        _getInitialStateUseCase.call(),
        categoriesFuture,
        bannersFuture,
        advertsFuture,
        favouritesFuture,
        Future.delayed(const Duration(milliseconds: 1500)),
      ]);

      final result = results[0] as DataState<InitStateModel>;

      if (result is DataSuccess<InitStateModel>) {
        state = result.data!;
      } else if (result is DataFailed<InitStateModel>) {
        state = state.copyWith(
          isLoading: false,
          error: result.error.toString(),
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = const InitStateModel();
  }
}
