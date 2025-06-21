import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:selo/core/constants/error_message.dart';
import 'package:selo/features/authentication/presentation/provider/index.dart';
import 'package:selo/features/profile/data/models/profile_user.dart';
import 'package:selo/features/profile/presentation/providers/providers.dart';

class EditProfileNotifier extends AsyncNotifier<void> {
  @override
  void build() {
    // Не требует начальной инициализации
  }

  // Выбор изображения и обновление StateProvider
  Future<void> pickImage(ImageSource source) async {
    final picker = ref.read(imagePickerProvider);
    final file = await picker.pickImage(source: source, imageQuality: 80);
    if (file != null) {
      ref.read(selectedImageProvider.notifier).state = file;
    }
  }

  // Обновление данных пользователя
  Future<void> updateUser(UpdateUserModel model) async {
    state = const AsyncLoading(); // Устанавливаем состояние загрузки
    final useCase = ref.read(updateUserUseCaseProvider);
    final selectedImage = ref.read(selectedImageProvider);
    final currentUser = ref.read(userNotifierProvider).user;

    // В модель обновления передаем либо путь к новому файлу, либо старый URL
    final finalModel = model.copyWith(
      profileImage: selectedImage?.path ?? currentUser?.profileImage,
    );

    // Выполняем use-case и обновляем состояние
    state = await AsyncValue.guard(() => useCase.call(params: finalModel));

    // При успехе сбрасываем локально выбранное изображение
    if (!state.hasError) {
      ref.read(selectedImageProvider.notifier).state = null;
    }
  }

  // Удаление пользователя
  Future<void> deleteUser() async {
    state = const AsyncLoading();
    final useCase = ref.read(deleteUserUseCaseProvider);
    final uid = ref.read(userNotifierProvider).user?.uid;

    if (uid == null) {
      state = AsyncError(ErrorMessages.userNotFound, StackTrace.current);
      return;
    }

    state = await AsyncValue.guard(() => useCase.call(params: uid));

    // При успехе выходим из аккаунта
    if (!state.hasError) {
      await ref.read(userNotifierProvider.notifier).logOut();
    }
  }
}
