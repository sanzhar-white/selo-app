import 'package:selo/shared/models/user_model.dart';

class UserState {
  const UserState({this.user, this.isLoading = false, this.error});
  final UserModel? user;
  final bool isLoading;
  final String? error;

  UserState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
