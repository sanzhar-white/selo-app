import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/theme/phone_custom_formatter.dart';
import 'package:selo/shared/widgets/custom_text_field.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/shared/widgets/show_bottom_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:selo/features/add/presentation/widgets/form_section.dart';
import 'package:selo/features/add/presentation/widgets/custom_toggle_buttons.dart';
import 'package:selo/features/add/presentation/widgets/price_section.dart';
import 'package:selo/features/add/presentation/widgets/quantity_section.dart';
import 'package:selo/features/add/presentation/widgets/location_section.dart';
import 'package:selo/features/add/presentation/widgets/image_section.dart';
import 'package:selo/features/add/presentation/providers/advert_provider.dart';
import 'package:selo/features/authentication/presentation/provider/authentication_provider.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:selo/core/utils/utils.dart';
import 'dart:io';

class CreateAdvertPage extends ConsumerStatefulWidget {
  const CreateAdvertPage({super.key, required this.category});
  final AdCategory category;

  @override
  ConsumerState<CreateAdvertPage> createState() => _CreateAdvertPageState();
}

class _CreateAdvertPageState extends ConsumerState<CreateAdvertPage> {
  bool _isPriceFixed = true;
  bool _isQuantityFixed = true;
  bool _isNew = true;
  int _year = DateTime.now().year;
  String _quantityUnit = 'kg';
  String _pricePerUnit = 'kg';
  String _region = '';
  String _district = '';
  String _uid = '';

  Map<String, bool> _validationState = {};
  bool _showValidation = false;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController phoneController = TextEditingController(
    text: '+77010122670',
  );
  final TextEditingController priceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController maxQuantityController = TextEditingController();
  late final Map<String, TextEditingController> settingsControllers;

  final ImagePicker _picker = ImagePicker();
  List<XFile?> _images = [];

  @override
  void initState() {
    super.initState();
    _uid = ref.read(userNotifierProvider).user?.uid ?? '';
    settingsControllers = {};
    for (final key in widget.category.settings.keys) {
      if (widget.category.settings[key] == true) {
        settingsControllers[key] = TextEditingController();
      }
    }
    _validationState = {};
    print('🔍 Category settings: ${widget.category.settings}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _quantityUnit = S.of(context).unit_kg;
    _pricePerUnit = S.of(context).unit_kg;
  }

  @override
  void dispose() {
    titleController.dispose();
    phoneController.dispose();
    priceController.dispose();
    maxPriceController.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    maxQuantityController.dispose();
    settingsControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _validateFields() {
    final newValidationState = <String, bool>{};
    _showValidation = true;

    print('🔧 Validating fields for category: ${widget.category.id}');

    // Required fields for all categories
    newValidationState['title'] = titleController.text.trim().isNotEmpty;
    newValidationState['region'] = _region.isNotEmpty;
    newValidationState['district'] = _district.isNotEmpty;
    newValidationState['description'] =
        descriptionController.text.trim().isNotEmpty;
    newValidationState['phoneNumber'] = phoneController.text.trim().isNotEmpty;

    // Price validation (always required unless negotiable)
    print('🔍 Validating price fields');
    if (_isPriceFixed) {
      newValidationState['price'] = priceController.text.trim().isNotEmpty;
      if (widget.category.settings['maxPrice'] == true) {
        newValidationState['maxPrice'] =
            maxPriceController.text.trim().isNotEmpty;
      } else {
        newValidationState['maxPrice'] =
            true; // Not required if maxPrice is not enabled
      }
    } else {
      newValidationState['price'] = true; // No validation for negotiable
      newValidationState['maxPrice'] = true;
    }

    // Quantity validation (only if explicitly enabled)
    if (widget.category.settings['quantity'] == true) {
      print('🔍 Validating quantity fields');
      if (_isQuantityFixed) {
        newValidationState['quantity'] =
            quantityController.text.trim().isNotEmpty;
        if (widget.category.settings['maxQuantity'] == true) {
          newValidationState['maxQuantity'] =
              maxQuantityController.text.trim().isNotEmpty;
        } else {
          newValidationState['maxQuantity'] =
              true; // Not required if maxQuantity is not enabled
        }
      } else {
        newValidationState['quantity'] = true; // No validation for negotiable
        newValidationState['maxQuantity'] = true;
      }
    } else {
      print('ℹ️ Quantity fields not applicable for this category');
      newValidationState['quantity'] =
          true; // Ensure quantity is valid if not required
      newValidationState['maxQuantity'] = true;
    }

    // Additional fields validation
    if (widget.category.settings['companyName'] == true) {
      newValidationState['companyName'] =
          settingsControllers['companyName']?.text.trim().isNotEmpty ?? false;
    }
    if (widget.category.settings['contactPerson'] == true) {
      newValidationState['contactPerson'] =
          settingsControllers['contactPerson']?.text.trim().isNotEmpty ?? false;
    }
    if (widget.category.settings['year'] == true) {
      newValidationState['year'] = _year > 1900;
    }

    print('✅ Validation state: $newValidationState');
    setState(() => _validationState = newValidationState);
  }

  bool get _isFormValid {
    return _validationState.values.every((isValid) => isValid);
  }

  void _handleCreateAdvert() async {
    final now = Timestamp.now();
    _validateFields();

    if (!_isFormValid) {
      print('❌ Form validation failed: $_validationState');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).fill_all_fields),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      print('🔄 Creating advert...');
      int price = 0;
      int maxPrice = 0;
      String priceUnit = _pricePerUnit;
      bool tradeable = !_isPriceFixed;

      if (_isPriceFixed) {
        price =
            int.tryParse(
              priceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
            ) ??
            0;
        if (widget.category.settings['maxPrice'] == true) {
          maxPrice =
              int.tryParse(
                maxPriceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
              ) ??
              0;
        }
      }

      int quantity = 0;
      int maxQuantity = 0;
      String quantityUnit = _quantityUnit;

      if (widget.category.settings['quantity'] == true && _isQuantityFixed) {
        quantity =
            int.tryParse(
              quantityController.text.replaceAll(RegExp(r'[^0-9]'), ''),
            ) ??
            0;
        if (widget.category.settings['maxQuantity'] == true) {
          maxQuantity =
              int.tryParse(
                maxQuantityController.text.replaceAll(RegExp(r'[^0-9]'), ''),
              ) ??
              0;
        }
      }

      final advert = AdvertModel(
        uid: '',
        ownerUid: _uid,
        active: true,
        views: 0,
        likes: 0,
        createdAt: now,
        updatedAt: now,
        title: titleController.text,
        phoneNumber: phoneController.text,
        category: widget.category.id,
        images: _images.map((e) => e?.path ?? '').toList(),
        description: descriptionController.text,
        region: getRegionID(_region),
        district: getDistrictID(_district, getRegionID(_region)),
        price: price,
        maxPrice: maxPrice,
        unitPer: priceUnit,
        quantity: quantity,
        maxQuantity: maxQuantity,
        unit: quantityUnit,
        tradeable: tradeable,
        companyName:
            widget.category.settings['companyName'] == true
                ? settingsControllers['companyName']?.text ?? ''
                : '',
        contactPerson:
            widget.category.settings['contactPerson'] == true
                ? settingsControllers['contactPerson']?.text ?? ''
                : '',
        year: widget.category.settings['year'] == true ? _year : 0,
        condition:
            widget.category.settings['condition'] == true
                ? (_isNew ? 0 : 1)
                : 0,
      );

      final success = await ref
          .read(advertNotifierProvider.notifier)
          .createAdvert(advert);

      if (!mounted) return;

      if (success) {
        print('✅ Advert created successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Advertisement created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        final error = ref.read(advertNotifierProvider).error;
        print('❌ Failed to create advert: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to create advertisement'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, st) {
      print('💥 Error creating advert: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating advert: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    if (_images.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 10 images allowed'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        final file = File(image.path);
        if (!await file.exists()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selected image file not found'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image size should be less than 5MB'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        setState(() => _images.add(image));
      }
    } catch (e, st) {
      print('💥 Error selecting image: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final advertState = ref.watch(advertNotifierProvider);
    final List<String> units = [S.of(context).unit_kg, S.of(context).unit_ton];

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(
                  S.of(context).create_advert,
                  style: contrastL(context),
                ),
                iconTheme: IconThemeData(color: colorScheme.inversePrimary),
                backgroundColor: colorScheme.surface,
                expandedHeight: screenSize.height * 0.1,
                toolbarHeight: screenSize.height * 0.1,
              ),
              SliverToBoxAdapter(
                child: FormSection(
                  title: S.of(context).title_of_ad,
                  titleStyle: contrastBoldM(context),
                  child: CustomTextField(
                    controller: titleController,
                    theme: colorScheme,
                    style: greenM(context),
                    hintText: S.of(context).title_of_ad_hint,
                    border: true,
                    error:
                        _showValidation && !(_validationState['title'] ?? true),
                    errorText: S.of(context).title_of_ad_required,
                  ),
                ),
              ),
              if (widget.category.settings['condition'] == true)
                SliverToBoxAdapter(
                  child: FormSection(
                    title: S.of(context).condition,
                    titleStyle: contrastBoldM(context),
                    child: CustomToggleButtons(
                      options: [
                        S.of(context).condition_new,
                        S.of(context).condition_used,
                      ],
                      selectedIndex: _isNew ? 0 : 1,
                      onChanged: (index) => setState(() => _isNew = index == 0),
                    ),
                  ),
                ),
              if (widget.category.settings['year'] == true)
                SliverToBoxAdapter(
                  child: FormSection(
                    title: S.of(context).year_of_release,
                    titleStyle: contrastBoldM(context),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(
                          screenSize.width,
                          screenSize.height * 0.05,
                        ),
                        backgroundColor: colorScheme.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: ResponsiveRadius.screenBased(context),
                        ),
                      ),
                      child: Text(_year.toString(), style: contrastM(context)),
                      onPressed: () {
                        final currentYear = DateTime.now().year;
                        showBottomPicker<int>(
                          context: context,
                          items:
                              List.generate(
                                currentYear - 1900 + 1,
                                (index) => 1900 + index,
                              ).reversed.toList(),
                          itemBuilder: (context, item) => Text(item.toString()),
                          itemAlignment: TextAlign.center,
                          onItemSelected:
                              (item) => setState(() => _year = item),
                        );
                      },
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: FormSection(
                  titleStyle: contrastBoldM(context),
                  child: PriceSection(
                    isPriceFixed: _isPriceFixed,
                    hasMaxPrice: widget.category.settings['maxPrice'] == true,
                    hasPricePer: widget.category.settings['pricePer'] == true,
                    isSalary: widget.category.settings['salary'] == true,
                    pricePerUnit: _pricePerUnit,
                    units: units,
                    priceController: priceController,
                    maxPriceController: maxPriceController,
                    onPriceTypeChanged:
                        (value) => setState(() => _isPriceFixed = value),
                    onUnitChanged:
                        (value) => setState(() => _pricePerUnit = value),
                    priceError:
                        _showValidation && !(_validationState['price'] ?? true),
                    maxPriceError:
                        _showValidation &&
                        !(_validationState['maxPrice'] ?? true),
                    showPricePerSelector:
                        widget.category.settings['pricePer'] == true,
                  ),
                ),
              ),
              if (widget.category.settings['quantity'] == true)
                SliverToBoxAdapter(
                  child: FormSection(
                    titleStyle: contrastBoldM(context),
                    child: QuantitySection(
                      isQuantityFixed: _isQuantityFixed,
                      hasMaxQuantity:
                          widget.category.settings['maxQuantity'] == true,
                      quantityUnit: _quantityUnit,
                      units: units,
                      quantityController: quantityController,
                      maxQuantityController: maxQuantityController,
                      onQuantityTypeChanged:
                          (value) => setState(() => _isQuantityFixed = value),
                      onUnitChanged:
                          (value) => setState(() => _quantityUnit = value),
                      quantityError:
                          _showValidation &&
                          !(_validationState['quantity'] ?? true),
                      maxQuantityError:
                          _showValidation &&
                          !(_validationState['maxQuantity'] ?? true),
                      maxQuantityErrorText: S.of(context).max_quantity_required,
                      showUnitSelector:
                          widget.category.settings['unitPer'] == true,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: FormSection(
                  title: S.of(context).location,
                  titleStyle: contrastBoldM(context),
                  child: LocationSection(
                    region: _region,
                    district: _district,
                    onRegionChanged:
                        (value) => setState(() {
                          _region = value;
                          _district = '';
                        }),
                    onDistrictChanged:
                        (value) => setState(() => _district = value),
                    regionError:
                        _showValidation &&
                        !(_validationState['region'] ?? true),
                    districtError:
                        _showValidation &&
                        !(_validationState['district'] ?? true),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: FormSection(
                  title: S.of(context).description,
                  titleStyle: contrastBoldM(context),
                  child: CustomTextField(
                    controller: descriptionController,
                    theme: colorScheme,
                    style: contrastM(context),
                    minLines: 3,
                    maxLines: 10,
                    hintText: S.of(context).description_hint,
                    border: true,
                    error:
                        _showValidation &&
                        !(_validationState['description'] ?? true),
                    errorText: S.of(context).description_required,
                  ),
                ),
              ),
              if (widget.category.settings['companyName'] == true)
                SliverToBoxAdapter(
                  child: FormSection(
                    title: S.of(context).company,
                    titleStyle: contrastBoldM(context),
                    child: CustomTextField(
                      controller: settingsControllers['companyName']!,
                      theme: colorScheme,
                      style: contrastM(context),
                      hintText: S.of(context).company_hint,
                      border: true,
                      error:
                          _showValidation &&
                          !(_validationState['companyName'] ?? true),
                      errorText: S.of(context).company_required,
                    ),
                  ),
                ),
              if (widget.category.settings['contactPerson'] == true)
                SliverToBoxAdapter(
                  child: FormSection(
                    title: S.of(context).contact_person,
                    titleStyle: contrastBoldM(context),
                    child: CustomTextField(
                      controller: settingsControllers['contactPerson']!,
                      theme: colorScheme,
                      style: contrastM(context),
                      hintText: S.of(context).contact_person_hint,
                      border: true,
                      error:
                          _showValidation &&
                          !(_validationState['contactPerson'] ?? true),
                      errorText: S.of(context).contact_person_required,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: FormSection(
                  title: S.of(context).phone_number,
                  titleStyle: contrastBoldM(context),
                  child: CustomTextField(
                    controller: phoneController,
                    theme: colorScheme,
                    style: contrastM(context),
                    hintText: S.of(context).phone_number_hint,
                    border: true,
                    formatters: [PhoneNumberFormatter()],
                    keyboardType: TextInputType.phone,
                    error:
                        _showValidation &&
                        !(_validationState['phoneNumber'] ?? true),
                    errorText: S.of(context).phone_number_required,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: FormSection(
                  child: ImageSection(
                    images: _images,
                    onPickImage: _pickImage,
                    onRemoveImage: _removeImage,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: FormSection(
                  child: GestureDetector(
                    onTap: _handleCreateAdvert,
                    child: Container(
                      width: screenSize.width,
                      height: screenSize.height * 0.07,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: ResponsiveRadius.screenBased(context),
                      ),
                      child: Center(
                        child: Text(
                          S.of(context).create_advert,
                          style: overGreenBoldM(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (advertState.isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
