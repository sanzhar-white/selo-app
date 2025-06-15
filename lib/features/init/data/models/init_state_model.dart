import 'package:equatable/equatable.dart';
import 'package:selo/shared/models/user_model.dart';

class InitStateModel extends Equatable {
  final bool isInitialized;
  final bool isLoading;
  final String? error;
  final StackTrace? stackTrace;
  final UserModel? user;
  final Map<String, dynamic> cachedData;

  const InitStateModel({
    this.isInitialized = false,
    this.isLoading = false,
    this.error,
    this.stackTrace,
    this.user,
    this.cachedData = const {},
  });

  InitStateModel copyWith({
    bool? isInitialized,
    bool? isLoading,
    String? error,
    StackTrace? stackTrace,
    UserModel? user,
    Map<String, dynamic>? cachedData,
  }) {
    return InitStateModel(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
      user: user ?? this.user,
      cachedData: cachedData ?? this.cachedData,
    );
  }

  @override
  List<Object?> get props => [
    isInitialized,
    isLoading,
    error,
    stackTrace,
    user,
    cachedData,
  ];
}
