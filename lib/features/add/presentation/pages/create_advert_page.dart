// lib/features/add/presentation/pages/choose_page.dart

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
import 'package:selo/features/add/domain/entities/advert_entity.dart';
import 'package:selo/features/add/data/models/advert_model.dart';
import 'package:selo/core/utils/utils.dart';
import 'package:selo/core/constants/regions_districts.dart';
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

  Map<String, bool> _validationState = {
    'title': true,
    'price': true,
    'region': true,
    'district': true,
    'description': true,
    'phoneNumber': true,
    'images': true,
  };

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

    settingsControllers = {
      for (final key in widget.category.settings.keys)
        key: TextEditingController(),
    };

    // Initialize validation state based on category settings
    _validationState = {
      'title': true,
      'price': true,
      'region': true,
      'district': true,
      'description': true,
      'phoneNumber': true,
      'images': true,
    };

    // Only add validation for fields that are required by the category
    for (final entry in widget.category.settings.entries) {
      _validationState[entry.key] =
          !entry.value; // Initialize as false only if the setting is true
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _quantityUnit = S.of(context).label_kg;
    _pricePerUnit = S.of(context).label_kg;
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
        imageQuality: 80, // Compress image to reduce size
      );

      if (image != null) {
        // Check if file exists
        final file = File(image.path);
        if (!await file.exists()) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selected image file not found'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Check file size (max 5MB)
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image size should be less than 5MB'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          _images.add(image);
          // Update validation state for images if needed
          if (_validationState.containsKey('images')) {
            _validationState['images'] = true;
          }
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      // Update validation state for images if needed
      if (_validationState.containsKey('images') && _images.isEmpty) {
        _validationState['images'] = false;
      }
    });
  }

  void _validateFields() {
    setState(() {
      // Always validate required fields
      _validationState['title'] = titleController.text.trim().isNotEmpty;
      _validationState['price'] =
          _isPriceFixed ? priceController.text.trim().isNotEmpty : true;
      _validationState['region'] = _region.isNotEmpty;
      _validationState['district'] = _district.isNotEmpty;
      _validationState['description'] =
          descriptionController.text.trim().isNotEmpty;
      _validationState['phoneNumber'] = phoneController.text.trim().isNotEmpty;
      _validationState['images'] = _images.isNotEmpty;

      // Only validate fields that are required by the category
      for (final entry in widget.category.settings.entries) {
        if (!entry.value) continue; // Skip if the setting is false

        switch (entry.key) {
          case 'maxPrice':
            _validationState['maxPrice'] =
                !_isPriceFixed || maxPriceController.text.trim().isNotEmpty;
            break;
          case 'maxQuantity':
            _validationState['maxQuantity'] =
                !_isQuantityFixed ||
                maxQuantityController.text.trim().isNotEmpty;
            break;
          case 'quantity':
            _validationState['quantity'] =
                !_isQuantityFixed || quantityController.text.trim().isNotEmpty;
            break;
          case 'condition':
            _validationState['condition'] =
                true; // Always valid as it's a toggle
            break;
          case 'year':
            _validationState['year'] = _year > 1900;
            break;
          case 'companyName':
            _validationState['companyName'] =
                settingsControllers['companyName']?.text.trim().isNotEmpty ??
                false;
            break;
          case 'contactPerson':
            _validationState['contactPerson'] =
                settingsControllers['contactPerson']?.text.trim().isNotEmpty ??
                false;
            break;
          default:
            // For any other settings, if they exist in the validation state, mark them as valid
            if (_validationState.containsKey(entry.key)) {
              _validationState[entry.key] = true;
            }
        }
      }

      print('Validation state: $_validationState');
    });
  }

  bool get _isFormValid {
    // Check if all required fields are valid
    bool isValid =
        _validationState['title'] == true &&
        _validationState['price'] == true &&
        _validationState['region'] == true &&
        _validationState['district'] == true &&
        _validationState['description'] == true &&
        _validationState['phoneNumber'] == true &&
        _validationState['images'] == true;

    // Check category-specific fields
    for (final entry in widget.category.settings.entries) {
      if (entry.value && _validationState.containsKey(entry.key)) {
        isValid = isValid && _validationState[entry.key]!;
      }
    }

    return isValid;
  }

  void _handleCreateAdvert() async {
    _validateFields();
    print('Validation state: $_validationState');

    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Clean up the price string by removing spaces and other non-digit characters
      final cleanPrice = priceController.text.replaceAll(RegExp(r'[^0-9]'), '');

      final success = await ref
          .read(advertNotifierProvider.notifier)
          .createAdvert(
            AdvertModel(
              uid: '',
              ownerUid: '',
              active: true,
              views: 0,
              likes: 0,
              createdDate: Timestamp.now(),
              updatedDate: Timestamp.now(),
              title: titleController.text,
              price: int.parse(cleanPrice),
              region: getRegionID(_region),
              district: getDistrictID(_district, getRegionID(_region), regions),
              description: descriptionController.text,
              phoneNumber: phoneController.text,
              category: widget.category.id,
              images: _images.map((e) => e?.path ?? '').toList(),
              tradeable:
                  _isPriceFixed ? priceController.text.trim().isNotEmpty : true,
              condition: _isNew ? 0 : 1,
              year: _year,
            ),
          );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Advertisement created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back or to the advert details page
        Navigator.of(context).pop();
      } else {
        final error = ref.read(advertNotifierProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to create advertisement'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error creating advert: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating advert: Invalid price format'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final advertState = ref.watch(advertNotifierProvider);
    final List<String> units = [
      S.of(context).label_kg,
      S.of(context).label_ton,
    ];

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text('Creating a new advert', style: contrastL(context)),
                iconTheme: IconThemeData(color: colorScheme.inversePrimary),
                backgroundColor: colorScheme.surface,
                expandedHeight: screenSize.height * 0.1,
                toolbarHeight: screenSize.height * 0.1,
              ),
              SliverToBoxAdapter(
                child: FormSection(
                  title: 'Title of advert',
                  titleStyle: contrastBoldM(context),
                  child: CustomTextField(
                    controller: titleController,
                    theme: colorScheme,
                    style: greenM(context),
                    hintText: 'Enter title of advert',
                    border: true,
                    error: !_validationState['title']!,
                    errorText: 'Title is required',
                  ),
                ),
              ),
              if (widget.category.settings['condition'] == true)
                SliverToBoxAdapter(
                  child: FormSection(
                    title: 'Condition',
                    titleStyle: contrastBoldM(context),
                    child: CustomToggleButtons(
                      options: const ['New', 'Used'],
                      selectedIndex: _isNew ? 0 : 1,
                      onChanged: (index) => setState(() => _isNew = index == 0),
                    ),
                  ),
                ),
              if (widget.category.settings['year'] == true)
                SliverToBoxAdapter(
                  child: FormSection(
                    title: 'Year of release',
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
                          onItemSelected: (item) {
                            setState(() {
                              _year = item;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: FormSection(
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
                    priceError: !_validationState['price']!,
                    maxPriceError:
                        !_validationState['maxPrice']! &&
                        _isPriceFixed &&
                        widget.category.settings['maxPrice'] == true,
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
                      quantityError: !_validationState['quantity']!,
                      quantityErrorText: 'Quantity is required',
                      maxQuantityError:
                          !_validationState['maxQuantity']! &&
                          _isQuantityFixed &&
                          widget.category.settings['maxQuantity'] == true,
                      maxQuantityErrorText: 'Max quantity is required',
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: FormSection(
                  title: 'Location',
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
                    regionError: !_validationState['region']!,
                    districtError: !_validationState['district']!,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: FormSection(
                  title: 'Description',
                  titleStyle: contrastBoldM(context),
                  child: CustomTextField(
                    controller: descriptionController,
                    theme: colorScheme,
                    style: contrastM(context),
                    minLines: 3,
                    maxLines: 10,
                    hintText: 'Describe your advert',
                    border: true,
                    error: !_validationState['description']!,
                    errorText: 'Description is required',
                  ),
                ),
              ),
              if (widget.category.settings['companyName'] == true)
                SliverToBoxAdapter(
                  child: FormSection(
                    title: 'Company',
                    titleStyle: contrastBoldM(context),
                    child: CustomTextField(
                      controller: settingsControllers['companyName']!,
                      theme: colorScheme,
                      style: contrastM(context),
                      hintText: 'Example: Apple',
                      border: true,
                      error: !_validationState['companyName']!,
                      errorText: 'Company name is required',
                    ),
                  ),
                ),
              if (widget.category.settings['contactPerson'] == true)
                SliverToBoxAdapter(
                  child: FormSection(
                    title: 'Contact person',
                    titleStyle: contrastBoldM(context),
                    child: CustomTextField(
                      controller: settingsControllers['contactPerson']!,
                      theme: colorScheme,
                      style: contrastM(context),
                      hintText: 'Example: John Doe',
                      border: true,
                      error: !_validationState['contactPerson']!,
                      errorText: 'Contact person is required',
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: FormSection(
                  title: 'Phone number',
                  titleStyle: contrastBoldM(context),
                  child: CustomTextField(
                    controller: phoneController,
                    theme: colorScheme,
                    style: contrastM(context),
                    hintText: 'Enter phone number',
                    border: true,
                    formatters: [PhoneNumberFormatter()],
                    keyboardType: TextInputType.phone,
                    error: !_validationState['phoneNumber']!,
                    errorText: 'Phone number is required',
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
                          'Create advert',
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
