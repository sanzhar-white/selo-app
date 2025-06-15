import 'package:selo/shared/models/advert_model.dart';

class ProfileState {
  final List<AdvertModel>? myAdverts;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.myAdverts = const [],
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    List<AdvertModel>? myAdverts,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      myAdverts: myAdverts ?? this.myAdverts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
