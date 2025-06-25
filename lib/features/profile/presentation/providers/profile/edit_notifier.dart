import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:selo/core/constants/error_message.dart';
import 'package:selo/features/authentication/presentation/provider/index.dart';
import 'package:selo/features/profile/data/models/profile_user.dart';
import 'package:selo/features/profile/presentation/providers/providers.dart';

class EditProfileNotifier extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<void> pickImage(ImageSource source) async {
    final picker = ref.read(imagePickerProvider);
    final file = await picker.pickImage(source: source, imageQuality: 80);
    if (file != null) {
      ref.read(selectedImageProvider.notifier).state = file;
    }
  }

  Future<void> updateUser(UpdateUserModel model) async {
    state = const AsyncLoading();
    final useCase = ref.read(updateUserUseCaseProvider);
    final selectedImage = ref.read(selectedImageProvider);
    final currentUser = ref.read(userNotifierProvider).user;

    final finalModel = model.copyWith(
      profileImage: selectedImage?.path ?? currentUser?.profileImage,
    );

    state = await AsyncValue.guard(() => useCase.call(params: finalModel));

    if (!state.hasError) {
      ref.read(selectedImageProvider.notifier).state = null;
    }
  }

  Future<void> deleteUser() async {
    state = const AsyncLoading();
    final useCase = ref.read(deleteUserUseCaseProvider);
    final uid = ref.read(userNotifierProvider).user?.uid;

    if (uid == null) {
      state = AsyncError(ErrorMessages.userNotFound, StackTrace.current);
      return;
    }

    state = await AsyncValue.guard(() => useCase.call(params: uid));

    if (!state.hasError) {
      await ref.read(userNotifierProvider.notifier).logOut();
    }
  }
}
