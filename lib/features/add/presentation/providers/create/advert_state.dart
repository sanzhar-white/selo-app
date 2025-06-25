import 'package:selo/shared/models/advert_model.dart';

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
