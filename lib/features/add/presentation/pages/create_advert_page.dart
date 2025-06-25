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
import 'package:selo/features/authentication/presentation/provider/index.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:selo/core/utils/utils.dart';
import 'dart:io';
import 'package:selo/core/di/di.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:selo/core/constants/error_message.dart';

class CreateAdvertPage extends ConsumerStatefulWidget {
  const CreateAdvertPage({required this.category, super.key});
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
  bool _isTradeable = false;

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
  final List<XFile?> _images = [];

  Talker get _talker => di<Talker>();

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
    _talker.info('🔍 Category settings: ${widget.category.settings}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _quantityUnit = S.of(context)!.unit_kg;
    _pricePerUnit = S.of(context)!.unit_kg;
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

    _talker.info('🔧 Validating fields for category: ${widget.category.id}');
    _talker.debug(
      'Current field values: title=${titleController.text}, region=$_region, district=$_district, description=${descriptionController.text}, phone=${phoneController.text}',
    );

    newValidationState['title'] = titleController.text.trim().isNotEmpty;
    newValidationState['region'] = _region.isNotEmpty;
    newValidationState['district'] = _district.isNotEmpty;
    newValidationState['description'] =
        descriptionController.text.trim().isNotEmpty;
    newValidationState['phoneNumber'] = phoneController.text.trim().isNotEmpty;

    _talker.debug('🔍 Validating price fields');
    if (_isPriceFixed) {
      newValidationState['price'] = priceController.text.trim().isNotEmpty;
      if (widget.category.settings['maxPrice'] == true) {
        newValidationState['maxPrice'] =
            maxPriceController.text.trim().isNotEmpty;
      } else {
        newValidationState['maxPrice'] = true;
      }
    } else {
      newValidationState['price'] = true;
      newValidationState['maxPrice'] = true;
    }

    if (widget.category.settings['quantity'] == true) {
      _talker.debug('🔍 Validating quantity fields');
      if (_isQuantityFixed) {
        newValidationState['quantity'] =
            quantityController.text.trim().isNotEmpty;
        if (widget.category.settings['maxQuantity'] == true) {
          newValidationState['maxQuantity'] =
              maxQuantityController.text.trim().isNotEmpty;
        } else {
          newValidationState['maxQuantity'] = true;
        }
      } else {
        newValidationState['quantity'] = true;
        newValidationState['maxQuantity'] = true;
      }
    } else {
      _talker.debug('ℹ️ Quantity fields not applicable for this category');
      newValidationState['quantity'] = true;
      newValidationState['maxQuantity'] = true;
    }

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

    _talker.info('✅ Validation state: $newValidationState');
    setState(() => _validationState = newValidationState);
  }

  bool get _isFormValid {
    return _validationState.values.every((isValid) => isValid);
  }

  Future<void> _handleCreateAdvert() async {
    final now = Timestamp.now();
    _validateFields();

    _talker.info('🟢 User tapped create advert button');
    _talker.debug('Current validation state: $_validationState');

    if (!_isFormValid) {
      _talker.error('${ErrorMessages.formValidationFailed}: $_validationState');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)!.fill_all_fields,
            style: contrastBoldM(context),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    try {
      _talker.info('🟢 Creating advert...');
      var price = 0;
      var maxPrice = 0;
      final priceUnit = _pricePerUnit;
      var tradeable = false;
      if (widget.category.settings['tradeable'] == true) {
        tradeable = _isTradeable;
      }

      if (_isPriceFixed) {
        price =
            int.tryParse(
              priceController.text.replaceAll(RegExp('[^0-9]'), ''),
            ) ??
            0;
        if (widget.category.settings['maxPrice'] == true) {
          maxPrice =
              int.tryParse(
                maxPriceController.text.replaceAll(RegExp('[^0-9]'), ''),
              ) ??
              0;
        }
      } else {
        price = 0;
        if (widget.category.settings['maxPrice'] == true) {
          maxPrice = 0;
        }
      }

      var quantity = 0;
      var maxQuantity = 0;
      final quantityUnit = _quantityUnit;

      if (widget.category.settings['quantity'] == true && _isQuantityFixed) {
        quantity =
            int.tryParse(
              quantityController.text.replaceAll(RegExp('[^0-9]'), ''),
            ) ??
            0;
        if (widget.category.settings['maxQuantity'] == true) {
          maxQuantity =
              int.tryParse(
                maxQuantityController.text.replaceAll(RegExp('[^0-9]'), ''),
              ) ??
              0;
        }
      }

      final advert = AdvertModel(
        uid: '',
        ownerUid: _uid,
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

      _talker.debug('📦 Advert params: $advert');
      _talker.debug('📷 Images: ${_images.map((e) => e?.path).toList()}');

      final success = await ref
          .read(advertNotifierProvider.notifier)
          .createAdvert(advert);

      if (!mounted) return;

      if (success) {
        _talker.info('✅ Advert created successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)!.advertisement_created,
              style: contrastBoldM(context),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        final error = ref.read(advertNotifierProvider).error;
        _talker.error('${ErrorMessages.failedToCreateAdvert}: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error ?? S.of(context)!.failed_to_created_advertisement,
              style: contrastBoldM(context),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e, st) {
      _talker.error(ErrorMessages.errorCreatingAdvert, e, st);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${S.of(context)!.error_creating_advert}: $e',
            style: contrastBoldM(context),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    if (_images.length >= 10) {
      _talker.warning(ErrorMessages.tooManyImages);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)!.max_images,
            style: contrastBoldM(context),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        final file = File(image.path);
        if (!await file.exists()) {
          _talker.error(
            '${ErrorMessages.selectedImageNotFound}: ${image.path}',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S.of(context)!.selected_image_file_not_found,
                style: contrastBoldM(context),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          return;
        }
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          _talker.warning(
            '${ErrorMessages.imageSizeTooLarge}: $fileSize bytes',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S.of(context)!.image_less_size,
                style: contrastBoldM(context),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          return;
        }
        setState(() => _images.add(image));
        _talker.info('🖼️ Image added: ${image.path}');
      } else {
        _talker.info('ℹ️ Image picking cancelled by user');
      }
    } catch (e, st) {
      _talker.error(ErrorMessages.errorSelectingImage, e, st);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${S.of(context)!.error_selecting_image}: $e',
            style: contrastBoldM(context),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _removeImage(int index) {
    if (index >= 0 && index < _images.length) {
      _talker.info('🗑️ User removed image: ${_images[index]?.path}');
      setState(() => _images.removeAt(index));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final radius = ResponsiveRadius.screenBased(context);
    final advertState = ref.watch(advertNotifierProvider);
    final units = <String>[S.of(context)!.unit_kg, S.of(context)!.unit_ton];

    if (advertState.isLoading) {
      _talker.info('⏳ Advert creation/loading in progress...');
    }

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(
                  S.of(context)!.create_advert,
                  style: contrastL(context),
                ),
                iconTheme: IconThemeData(color: colorScheme.inversePrimary),
                backgroundColor: colorScheme.surface,
                expandedHeight: screenSize.height * 0.1,
                toolbarHeight: screenSize.height * 0.1,
              ),
              SliverToBoxAdapter(
                child: FormSection(
                  title: S.of(context)!.title_of_ad,
                  titleStyle: contrastBoldM(context),
                  child: CustomTextField(
                    controller: titleController,
                    theme: colorScheme,
                    style: greenM(context),
                    hintText: S.of(context)!.title_of_ad_hint,
                    error:
                        _showValidation && !(_validationState['title'] ?? true),
                    errorText: S.of(context)!.title_of_ad_required,
                  ),
                ),
              ),
              if (widget.category.settings['condition'] == true)
                SliverToBoxAdapter(
                  child: FormSection(
                    title: S.of(context)!.condition,
                    titleStyle: contrastBoldM(context),
                    child: CustomToggleButtons(
                      options: [
                        S.of(context)!.condition_new,
                        S.of(context)!.condition_used,
                      ],
                      selectedIndex: _isNew ? 0 : 1,
                      onChanged: (index) => setState(() => _isNew = index == 0),
                    ),
                  ),
                ),
              if (widget.category.settings['year'] == true)
                SliverToBoxAdapter(
                  child: FormSection(
                    title: S.of(context)!.year_of_release,
                    titleStyle: contrastBoldM(context),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(
                          screenSize.width,
                          screenSize.height * 0.05,
                        ),
                        backgroundColor: colorScheme.onSurface,
                        shape: RoundedRectangleBorder(borderRadius: radius),
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
                  child: Column(
                    children: [
                      if (widget.category.settings['tradeable'] == true)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              S.of(context)!.trade_possible,
                              style: contrastBoldM(context),
                            ),
                            Switch(
                              value: _isTradeable,
                              onChanged:
                                  (val) => setState(() => _isTradeable = val),
                            ),
                          ],
                        ),
                      PriceSection(
                        isPriceFixed: _isPriceFixed,
                        hasMaxPrice:
                            widget.category.settings['maxPrice'] == true,
                        hasPricePer:
                            widget.category.settings['pricePer'] == true,
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
                            _showValidation &&
                            !(_validationState['price'] ?? true),
                        maxPriceError:
                            _showValidation &&
                            !(_validationState['maxPrice'] ?? true),
                        showPricePerSelector:
                            widget.category.settings['pricePer'] == true,
                      ),
                    ],
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
                      maxQuantityErrorText:
                          S.of(context)!.max_quantity_required,
                      showUnitSelector:
                          widget.category.settings['unitPer'] == true,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: FormSection(
                  title: S.of(context)!.location,
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
                  title: S.of(context)!.description,
                  titleStyle: contrastBoldM(context),
                  child: CustomTextField(
                    controller: descriptionController,
                    theme: colorScheme,
                    style: contrastM(context),
                    minLines: 3,
                    maxLines: 10,
                    hintText: S.of(context)!.description_hint,
                    error:
                        _showValidation &&
                        !(_validationState['description'] ?? true),
                    errorText: S.of(context)!.description_required,
                  ),
                ),
              ),
              if (widget.category.settings['companyName'] == true)
                SliverToBoxAdapter(
                  child: FormSection(
                    title: S.of(context)!.company,
                    titleStyle: contrastBoldM(context),
                    child: CustomTextField(
                      controller: settingsControllers['companyName']!,
                      theme: colorScheme,
                      style: contrastM(context),
                      hintText: S.of(context)!.company_hint,
                      error:
                          _showValidation &&
                          !(_validationState['companyName'] ?? true),
                      errorText: S.of(context)!.company_required,
                    ),
                  ),
                ),
              if (widget.category.settings['contactPerson'] == true)
                SliverToBoxAdapter(
                  child: FormSection(
                    title: S.of(context)!.contact_person,
                    titleStyle: contrastBoldM(context),
                    child: CustomTextField(
                      controller: settingsControllers['contactPerson']!,
                      theme: colorScheme,
                      style: contrastM(context),
                      hintText: S.of(context)!.contact_person_hint,
                      error:
                          _showValidation &&
                          !(_validationState['contactPerson'] ?? true),
                      errorText: S.of(context)!.contact_person_required,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: FormSection(
                  title: S.of(context)!.phone_number,
                  titleStyle: contrastBoldM(context),
                  child: CustomTextField(
                    controller: phoneController,
                    theme: colorScheme,
                    style: contrastM(context),
                    hintText: S.of(context)!.phone_number_hint,
                    formatters: [PhoneNumberFormatter()],
                    keyboardType: TextInputType.phone,
                    error:
                        _showValidation &&
                        !(_validationState['phoneNumber'] ?? true),
                    errorText: S.of(context)!.phone_number_required,
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
                        borderRadius: radius,
                      ),
                      child: Center(
                        child: Text(
                          S.of(context)!.create_advert,
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
            const ColoredBox(
              color: Colors.black54,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
