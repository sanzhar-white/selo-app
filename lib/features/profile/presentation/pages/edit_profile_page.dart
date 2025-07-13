import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:selo/core/constants/regions_districts.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:selo/core/theme/phone_custom_formatter.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/features/authentication/presentation/provider/index.dart';
import 'package:selo/features/profile/data/models/profile_user.dart';
import 'package:selo/features/profile/presentation/providers/index.dart';
import 'package:selo/features/profile/presentation/widgets/image_source_picker.dart';
import 'package:selo/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/shared/widgets/custom_text_field.dart';
import 'package:selo/shared/widgets/location_picker.dart';
import 'package:selo/core/utils/utils.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  String? _region;
  String? _district;

  // Masked phone formatter
  final phoneMaskFormatter = MaskTextInputFormatter(
    mask: '+7 (###) ### ####',
    filter: {"#": RegExp(r'\d')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    super.initState();
    final user = ref.read(userNotifierProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _phoneController = TextEditingController(
      text:
          user?.phoneNumber != null
              ? phoneMaskFormatter.maskText(user!.phoneNumber)
              : '',
    );
    _region = user?.region != null ? getRegionName(user!.region) : null;
    _district =
        user?.district != null && user?.region != null
            ? getDistrictName(user!.district, user.region)
            : null;

    Future.microtask(
      () => ref.read(selectedImageProvider.notifier).state = null,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              S.of(context)!.select_image_source,
              style: contrastBoldM(context),
            ),
            content: const ImageSourcePicker(),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context)!.cancel),
              ),
            ],
          ),
    );

    if (source != null) {
      await ref.read(editProfileNotifierProvider.notifier).pickImage(source);
    }
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final uid = ref.read(userNotifierProvider).user?.uid;
    if (uid == null) return;

    final updateUserModel = UpdateUserModel(
      uid: uid,
      name: _nameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: toRawPhone(_phoneController.text),
      region: _region != null ? getRegionID(_region!) : null,
      district:
          _district != null && _region != null
              ? getDistrictID(_district!, getRegionID(_region!))
              : null,
    );

    ref.read(editProfileNotifierProvider.notifier).updateUser(updateUserModel);
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              S.of(context)!.delete_account,
              style: contrastM(context),
            ),
            content: Text(
              S.of(context)!.delete_account_confirmation,
              style: contrastM(context),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context)!.cancel, style: contrastM(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(editProfileNotifierProvider.notifier).deleteUser();
                },
                child: Text(S.of(context)!.delete, style: overGreenM(context)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = ResponsiveRadius.screenBased(context);
    final user = ref.watch(userNotifierProvider).user;
    final selectedImage = ref.watch(selectedImageProvider);
    final editProfileState = ref.watch(editProfileNotifierProvider);

    ref.listen<AsyncValue<void>>(editProfileNotifierProvider, (_, state) {
      state.whenOrNull(
        data: (_) {
          if (state.isRefreshing) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  S.of(context)!.change_saved,
                  style: contrastBoldM(context),
                ),
              ),
            );
        },
        error: (error, __) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(error.toString(), style: contrastBoldM(context)),
              ),
            );
        },
      );
    });

    ref.listen<UserState>(userNotifierProvider, (_, next) {
      if (next.user == null) {
        context.go(Routes.authenticationPage);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context)!.edit_profile, style: contrastBoldM(context)),
        iconTheme: IconThemeData(color: colorScheme.inversePrimary),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildAvatarSection(
                    context,
                    user?.profileImage,
                    selectedImage,
                    colorScheme,
                  ),
                  const SizedBox(height: 16),
                  _buildFormFields(context, colorScheme),
                  const SizedBox(height: 24),
                  _buildButtons(context, editProfileState, radius),
                ],
              ),
            ),
          ),
          if (editProfileState.isLoading)
            ColoredBox(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator.adaptive()),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(
    BuildContext context,
    String? imageUrl,
    XFile? selectedImage,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        RepaintBoundary(
          child: ProfileAvatar(
            key: const ValueKey('profile_avatar'),
            imageUrl: imageUrl,
            localImage: selectedImage != null ? File(selectedImage.path) : null,
            radius: 60,
            backgroundColor: colorScheme.inversePrimary,
            iconColor: colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _pickProfileImage,
          child: Text(S.of(context)!.change_profile_photo),
        ),
      ],
    );
  }

  Widget _buildFormFields(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        CustomTextField(
          controller: _nameController,
          hintText: S.of(context)!.name_hint,
          keyboardType: TextInputType.name,
          theme: colorScheme,
          style: contrastM(context),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _lastNameController,
          hintText: S.of(context)!.lastname_hint,
          keyboardType: TextInputType.name,
          theme: colorScheme,
          style: contrastM(context),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          style: contrastM(context),
          decoration: InputDecoration(
            isDense: true,
            fillColor: colorScheme.onSurface,
            filled: true,
            hintText: S.of(context)!.phone_number_hint,
            hintStyle: grayM(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            errorStyle: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [phoneMaskFormatter],
          validator: (value) {
            if (value == null ||
                value.replaceAll(RegExp(r'\D'), '').length < 11) {
              return S.of(context)!.phone_number_invalid;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        LocationPicker(
          region: _region,
          district: _district,
          locations: regions,
          onRegionChanged:
              (value) => setState(() {
                _region = value;
                _district = null;
              }),
          onDistrictChanged: (value) => setState(() => _district = value),
          regionHint: S.of(context)!.region_select,
          districtHint: S.of(context)!.district_select,
          regionLabel: S.of(context)!.region,
          districtLabel: S.of(context)!.district,
        ),
      ],
    );
  }

  Widget _buildButtons(
    BuildContext context,
    AsyncValue<void> state,
    BorderRadius radius,
  ) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: state.isLoading ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: radius),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: Text(S.of(context)!.apply, style: overGreenBoldM(context)),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: state.isLoading ? null : _deleteAccount,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: Theme.of(context).colorScheme.error,
            shape: RoundedRectangleBorder(borderRadius: radius),
          ),
          child: Text(
            S.of(context)!.delete_account,
            style: overGreenBoldM(context),
          ),
        ),
      ],
    );
  }
}
