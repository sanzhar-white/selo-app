import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'advert_state.dart';
import '../advert_provider.dart';
import 'package:selo/core/resources/data_state.dart';

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
