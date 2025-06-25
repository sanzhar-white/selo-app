import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/features/init/data/datasources/init_datasource.dart';
import 'package:selo/features/init/data/models/init_state_model.dart';
import 'package:selo/features/init/data/repositories/init_repository_impl.dart';
import 'package:selo/features/init/domain/usecases/get_initial_state_usecase.dart';
import 'package:selo/core/resources/data_state.dart';

final Provider<InitDatasource> initDatasourceProvider = Provider((ref) => InitDatasource());

final Provider<InitRepositoryImpl> initRepositoryProvider = Provider(
  (ref) => InitRepositoryImpl(ref.watch(initDatasourceProvider)),
);

final Provider<GetInitialStateUseCase> getInitialStateUseCaseProvider = Provider(
  (ref) => GetInitialStateUseCase(ref.watch(initRepositoryProvider)),
);

final initStateProvider =
    StateNotifierProvider<InitStateNotifier, InitStateModel>((ref) {
      return InitStateNotifier(ref.watch(getInitialStateUseCaseProvider));
    });

class InitStateNotifier extends StateNotifier<InitStateModel> {

  InitStateNotifier(this._getInitialStateUseCase)
    : super(const InitStateModel()) {
    initialize();
  }
  final GetInitialStateUseCase _getInitialStateUseCase;

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      final results = await Future.wait([
        _getInitialStateUseCase.call(),
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
