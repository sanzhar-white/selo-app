import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:selo/core/constants/regions_districts.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/features/authentication/presentation/provider/index.dart';
import 'package:selo/features/profile/presentation/providers/index.dart';
import 'package:selo/features/profile/data/models/profile_user.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/shared/widgets/custom_text_field.dart';
import 'package:selo/shared/widgets/location_picker.dart';
import 'package:selo/core/utils/utils.dart';

// Константы для отступов и размеров
const _padding = EdgeInsets.all(16.0);
const _avatarRadius = 60.0;
const _verticalSpacing = 16.0;

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  // Контроллеры для текстовых полей
  late final TextEditingController _nameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  String? _region;
  String? _district;
  File? _selectedImage; // Локально выбранное изображение
  bool _phoneError = false;
  bool _isSaving = false; // Индикатор сохранения

  @override
  void initState() {
    super.initState();
    final user = ref.read(userNotifierProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _phoneController = TextEditingController(
      text:
          user?.phoneNumber != null ? formatPhoneNumber(user!.phoneNumber) : '',
    );
    _region = user?.region != null ? getRegionName(user!.region!) : null;
    _district =
        user?.district != null && user?.region != null
            ? getDistrictName(user!.district!, user.region!)
            : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Метод для валидации номера телефона
  bool _isValidPhone(String phone) {
    return phone.isNotEmpty &&
        RegExp(r'^\+?\d{10,15}$').hasMatch(phone.replaceAll(RegExp(r'\D'), ''));
  }

  // Метод для выбора изображения
  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final colorScheme = Theme.of(context).colorScheme;
    final source = await showDialog<ImageSource>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              S.of(context).select_image_source,
              style: contrastBoldM(context),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.photo_library,
                    color: colorScheme.inversePrimary,
                  ),
                  title: Text(S.of(context).gallery, style: contrastM(context)),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: Icon(
                    Icons.camera_alt,
                    color: colorScheme.inversePrimary,
                  ),
                  title: Text(S.of(context).camera, style: contrastM(context)),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context).cancel),
              ),
            ],
          ),
    );

    if (source == null) return;

    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).image_picker_error)));
    }
  }

  // Метод для загрузки изображения в Firebase Storage
  Future<String?> _uploadImage(String uid) async {
    if (_selectedImage == null) return null;

    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        'profile_images/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final uploadTask = await storageRef.putFile(_selectedImage!);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).image_upload_error)));
      return null;
    }
  }

  // Метод для преобразования данных в UpdateUserModel
  UpdateUserModel _buildUpdateUserModel({String? imageUrl}) {
    final cleanedPhone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final formattedPhone =
        cleanedPhone.isNotEmpty
            ? formatPhoneNumber(cleanedPhone)
            : _phoneController.text;

    return UpdateUserModel(
      name: _nameController.text.isEmpty ? null : _nameController.text,
      lastName:
          _lastNameController.text.isEmpty ? null : _lastNameController.text,
      phoneNumber: formattedPhone,
      region: _region == null ? null : getRegionID(_region!),
      district:
          _district == null || _region == null
              ? null
              : getDistrictID(_district!, getRegionID(_region!)),
      uid: ref.read(userNotifierProvider).user?.uid ?? '',
      profileImage:
          imageUrl ?? ref.read(userNotifierProvider).user?.profileImage,
    );
  }

  // Метод для обновления профиля
  Future<void> _saveProfile() async {
    setState(() {
      _phoneError = !_isValidPhone(_phoneController.text);
      _isSaving = true;
    });

    if (_phoneError) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).phone_number_invalid)),
      );
      return;
    }

    final profileNotifier = ref.read(profileNotifierProvider.notifier);
    String? imageUrl;

    // Загружаем изображение, если выбрано
    if (_selectedImage != null) {
      imageUrl = await _uploadImage(
        ref.read(userNotifierProvider).user?.uid ?? '',
      );
      if (imageUrl == null) {
        setState(() => _isSaving = false);
        return; // Прерываем, если загрузка не удалась
      }
    }

    // Обновляем профиль
    final updateUserModel = _buildUpdateUserModel(imageUrl: imageUrl);
    await profileNotifier
        .updateUser(updateUserModel)
        .then((_) {
          setState(() {
            _isSaving = false;
            _selectedImage = null; // Сбрасываем локальное изображение
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(S.of(context).change_saved)));
        })
        .catchError((e) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).profile_update_error)),
          );
        });
  }

  // Метод для удаления аккаунта
  void _deleteAccount() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              S.of(context).delete_account,
              style: contrastBoldM(context),
            ),
            content: Text(
              S.of(context).delete_account_confirmation,
              style: contrastM(context),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  S.of(context).cancel,
                  style: contrastBoldM(context),
                ),
              ),
              TextButton(
                onPressed: () {
                  final profileNotifier = ref.read(
                    profileNotifierProvider.notifier,
                  );
                  final uid = ref.read(userNotifierProvider).user?.uid ?? '';
                  profileNotifier.deleteUser(uid).then((_) {
                    context.pop();
                    ;

                    ref.read(userNotifierProvider.notifier).logOut();
                    context.go(Routes.authenticationPage);
                  });
                },
                child: Text(
                  S.of(context).delete,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = ResponsiveRadius.screenBased(context);
    final colorScheme = Theme.of(context).colorScheme;
    final profileState = ref.watch(profileNotifierProvider);
    final userState = ref.watch(userNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).edit_profile, style: contrastBoldM(context)),
        iconTheme: IconThemeData(color: colorScheme.inversePrimary),
      ),
      body:
          profileState.isLoading || _isSaving
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: _padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Аватар
                    Center(
                      child: ProfileAvatar(
                        imageUrl: userState.user?.profileImage,
                        localImage: _selectedImage,
                        radius: _avatarRadius,
                        backgroundColor: colorScheme.inversePrimary,
                        iconColor: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: _verticalSpacing),
                    Center(
                      child: TextButton(
                        onPressed: _pickProfileImage,
                        child: Text(S.of(context).change_profile_photo),
                      ),
                    ),
                    const SizedBox(height: _verticalSpacing),
                    // Поле для имени
                    CustomTextField(
                      controller: _nameController,
                      theme: colorScheme,
                      style: contrastM(context),
                      hintText: S.of(context).name_hint,
                      keyboardType: TextInputType.name,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: _verticalSpacing),
                    // Поле для фамилии
                    CustomTextField(
                      controller: _lastNameController,
                      theme: colorScheme,
                      style: contrastM(context),
                      hintText: S.of(context).lastname_hint,
                      keyboardType: TextInputType.name,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: _verticalSpacing),
                    // Поле для номера телефона
                    CustomTextField(
                      controller: _phoneController,
                      theme: colorScheme,
                      style: contrastM(context),
                      hintText: S.of(context).phone_number_hint,
                      keyboardType: TextInputType.phone,
                      error: _phoneError,
                      errorText:
                          _phoneError
                              ? S.of(context).phone_number_invalid
                              : null,
                      onChanged: (value) {
                        final formatted = formatPhoneNumber(value);
                        if (_phoneController.text != formatted) {
                          _phoneController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(
                              offset: formatted.length,
                            ),
                          );
                        }
                        setState(() => _phoneError = false);
                      },
                    ),
                    const SizedBox(height: _verticalSpacing),
                    // Поля для области и района
                    LocationPicker(
                      region: _region,
                      district: _district,
                      locations: regions,
                      onRegionChanged: (value) {
                        setState(() {
                          _region = value;
                          _district = null;
                        });
                      },
                      onDistrictChanged: (value) {
                        setState(() {
                          _district = value;
                        });
                      },
                      regionHint: S.of(context).region_select,
                      districtHint: S.of(context).district_select,
                      regionLabel: S.of(context).region,
                      districtLabel: S.of(context).district,
                      showLabels: true,
                      showDistrict: true,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                    ),
                    const SizedBox(height: _verticalSpacing),
                    // Кнопка сохранения
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: radius),
                      ),
                      child: Text(
                        S.of(context).apply,
                        style: contrastBoldM(context),
                      ),
                    ),
                    const SizedBox(height: _verticalSpacing),
                    // Кнопка удаления аккаунта
                    ElevatedButton(
                      onPressed: _isSaving ? null : _deleteAccount,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: radius),
                      ),
                      child: Text(
                        S.of(context).delete_account,
                        style: contrastBoldM(context),
                      ),
                    ),
                    if (profileState.error != null) ...[
                      const SizedBox(height: _verticalSpacing),
                      Text(
                        profileState.error!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}

// Виджет для аватара с поддержкой локального файла
class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final File? localImage;
  final double radius;
  final Color backgroundColor;
  final Color iconColor;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.localImage,
    required this.radius,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage:
          localImage != null
              ? FileImage(localImage!)
              : imageUrl != null && imageUrl!.isNotEmpty
              ? NetworkImage(imageUrl!)
              : null,
      child:
          localImage == null && (imageUrl == null || imageUrl!.isEmpty)
              ? Icon(Icons.person, size: radius, color: iconColor)
              : null,
    );
  }
}
