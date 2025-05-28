// lib/features/add/presentation/pages/choose_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/shared/widgets/custom_text_field.dart';
import 'package:selo/core/utils/utils.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/features/add/presentation/providers/categories_provider.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:selo/core/constants/regions_districts.dart';
import 'package:selo/shared/widgets/show_bottom_picker.dart';
import 'package:image_picker/image_picker.dart';
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

  final TextEditingController titleController = TextEditingController();
  final TextEditingController phoneController = TextEditingController(
    text: '+77010122670',
  );
  final TextEditingController priceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController maxQuantityController = TextEditingController();
  late final List<TextEditingController> settingsControllers;

  final ImagePicker _picker = ImagePicker();
  List<XFile?> _images = [];

  @override
  void initState() {
    super.initState();
    settingsControllers =
        widget.category.settings.keys
            .map((e) => TextEditingController())
            .toList();
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
    settingsControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_images.length >= 10) return;
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(image);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final List<String> units = [
      S.of(context).label_kg,
      S.of(context).label_ton,
    ];

    final crossAxisCount = 1;
    final crossAxisSpacing = screenSize.width * 0.03;
    final mainAxisSpacing = screenSize.height * 0.03;
    final childAspectRatio = 4.0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('Creating a new advert', style: contrastL(context)),
            iconTheme: IconThemeData(color: colorScheme.inversePrimary),
            backgroundColor: colorScheme.surface,
            expandedHeight: screenSize.height * 0.1,
            toolbarHeight: screenSize.height * 0.1,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: screenSize.height * 0.015,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Title of advert', style: contrastBoldM(context)),
                  SizedBox(height: screenSize.height * 0.015),
                  CustomTextField(
                    controller: titleController,
                    theme: colorScheme,
                    style: greenM(context),
                    hintText: 'Enter title of advert',
                    border: true,
                  ),
                ],
              ),
            ),
          ),
          if (widget.category.settings['condition'] == true) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.05,
                  vertical: screenSize.height * 0.015,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Condition', style: contrastBoldM(context)),
                    SizedBox(height: screenSize.height * 0.015),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface,
                        borderRadius: ResponsiveRadius.screenBased(context),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final buttonWidth =
                              (constraints.maxWidth -
                                  screenSize.width * 0.015) /
                              2;

                          return ToggleButtons(
                            borderRadius: ResponsiveRadius.screenBased(context),
                            fillColor: colorScheme.primary,
                            selectedColor: colorScheme.onPrimary,
                            color: colorScheme.primary,
                            textStyle: contrastM(context),
                            constraints: BoxConstraints(
                              minHeight: screenSize.height * 0.05,
                              minWidth: buttonWidth,
                            ),
                            isSelected: [_isNew, !_isNew],
                            onPressed: (index) {
                              setState(() {
                                _isNew = index == 0;
                              });
                            },
                            children: const [Text('New'), Text('Used')],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (widget.category.settings['year'] == true) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.05,
                  vertical: screenSize.height * 0.015,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Year of release', style: contrastBoldM(context)),
                    SizedBox(height: screenSize.height * 0.015),
                    ElevatedButton(
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
                                    currentYear -
                                        1900 +
                                        1, // включая текущий год
                                    (index) => 1900 + index,
                                  ).reversed
                                  .toList(), // чтобы сверху был самый новый
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
                  ],
                ),
              ),
            ),
          ],

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: screenSize.height * 0.015,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.category.settings['salary'] == true) ...[
                    Text('Salary', style: contrastBoldM(context)),
                  ] else if (widget.category.settings['pricePer'] == true) ...[
                    Text('Price per unit', style: contrastBoldM(context)),
                  ] else ...[
                    Text('Price', style: contrastBoldM(context)),
                  ],
                  SizedBox(height: screenSize.height * 0.015),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface,
                      borderRadius: ResponsiveRadius.screenBased(context),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final buttonWidth =
                            (constraints.maxWidth - screenSize.width * 0.015) /
                            2;

                        return ToggleButtons(
                          borderRadius: ResponsiveRadius.screenBased(context),
                          fillColor: colorScheme.primary,
                          selectedColor: colorScheme.onPrimary,
                          color: colorScheme.primary,
                          textStyle: contrastM(context),
                          constraints: BoxConstraints(
                            minHeight: screenSize.height * 0.05,
                            minWidth: buttonWidth,
                          ),
                          isSelected: [_isPriceFixed, !_isPriceFixed],
                          onPressed: (index) {
                            setState(() {
                              _isPriceFixed = index == 0;
                            });
                          },
                          children: const [Text('Fixed'), Text('Negotiable')],
                        );
                      },
                    ),
                  ),
                  if (_isPriceFixed) ...[
                    SizedBox(height: screenSize.height * 0.02),
                    if (widget.category.settings['maxPrice'] == true) ...[
                      if (widget.category.settings['pricePer'] == true) ...[
                        SizedBox(
                          height: screenSize.height * 0.06,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: priceController,
                                  theme: colorScheme,
                                  style: contrastM(context),
                                  hintText: 'From',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                width: screenSize.width * 0.15,
                                decoration: BoxDecoration(
                                  color: colorScheme.onSurface,
                                  borderRadius: BorderRadius.only(
                                    topRight:
                                        ResponsiveRadius.screenBased(
                                          context,
                                        ).topRight,
                                    bottomRight:
                                        ResponsiveRadius.screenBased(
                                          context,
                                        ).bottomRight,
                                  ),
                                  border: Border(
                                    left: BorderSide(
                                      color: colorScheme.secondary,
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: Text('₸', style: contrastM(context)),
                                ),
                              ),
                              SizedBox(width: screenSize.width * 0.04),
                              Expanded(
                                child: CustomTextField(
                                  controller: maxPriceController,
                                  theme: colorScheme,
                                  style: contrastM(context),
                                  hintText: 'To',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                width: screenSize.width * 0.15,
                                decoration: BoxDecoration(
                                  color: colorScheme.onSurface,
                                  borderRadius: BorderRadius.only(
                                    topRight:
                                        ResponsiveRadius.screenBased(
                                          context,
                                        ).topRight,
                                    bottomRight:
                                        ResponsiveRadius.screenBased(
                                          context,
                                        ).bottomRight,
                                  ),
                                  border: Border(
                                    left: BorderSide(
                                      color: colorScheme.secondary,
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: Text('₸', style: contrastM(context)),
                                ),
                              ),
                              SizedBox(width: screenSize.width * 0.04),
                              GestureDetector(
                                onTap: () {
                                  showBottomPicker<String>(
                                    context: context,
                                    items: units,
                                    itemAlignment: TextAlign.center,
                                    itemBuilder: (context, item) => Text(item),
                                    onItemSelected: (item) {
                                      setState(() {
                                        _pricePerUnit = item;
                                      });
                                    },
                                  );
                                },
                                child: Container(
                                  width: screenSize.width * 0.15,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _pricePerUnit,
                                      style: overGreenBoldM(context),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        SizedBox(
                          height: screenSize.height * 0.06,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                width:
                                    screenSize.width *
                                    0.42, // немного уменьшено
                                decoration: BoxDecoration(
                                  color: colorScheme.onSurface,
                                  borderRadius: ResponsiveRadius.screenBased(
                                    context,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        controller: priceController,
                                        theme: colorScheme,
                                        style: contrastM(context),
                                        hintText: 'From',
                                      ),
                                    ),
                                    Container(
                                      width: screenSize.width * 0.15,
                                      decoration: BoxDecoration(
                                        color: colorScheme.onSurface,
                                        borderRadius: BorderRadius.only(
                                          topRight:
                                              ResponsiveRadius.screenBased(
                                                context,
                                              ).topRight,
                                          bottomRight:
                                              ResponsiveRadius.screenBased(
                                                context,
                                              ).bottomRight,
                                        ),
                                        border: Border(
                                          left: BorderSide(
                                            color: colorScheme.secondary,
                                          ),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '₸',
                                          style: contrastM(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // <--- Разделитель
                              SizedBox(width: screenSize.width * 0.04),

                              Container(
                                width:
                                    screenSize.width *
                                    0.42, // немного уменьшено
                                decoration: BoxDecoration(
                                  color: colorScheme.onSurface,
                                  borderRadius: ResponsiveRadius.screenBased(
                                    context,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        controller: maxPriceController,
                                        theme: colorScheme,
                                        style: contrastM(context),
                                        hintText: 'To',
                                      ),
                                    ),
                                    Container(
                                      width:
                                          screenSize.width *
                                          0.15, // немного уменьшено
                                      decoration: BoxDecoration(
                                        color: colorScheme.onSurface,
                                        borderRadius: BorderRadius.only(
                                          topRight:
                                              ResponsiveRadius.screenBased(
                                                context,
                                              ).topRight,
                                          bottomRight:
                                              ResponsiveRadius.screenBased(
                                                context,
                                              ).bottomRight,
                                        ),
                                        border: Border(
                                          left: BorderSide(
                                            color: colorScheme.secondary,
                                          ),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '₸',
                                          style: contrastM(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ] else ...[
                      if (widget.category.settings['pricePer'] == true) ...[
                        SizedBox(
                          height: screenSize.height * 0.06,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: priceController,
                                  theme: colorScheme,
                                  style: contrastM(context),
                                  hintText: 'Enter price per unit',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                width: screenSize.width * 0.15,
                                decoration: BoxDecoration(
                                  color: colorScheme.onSurface,
                                  borderRadius: BorderRadius.only(
                                    topRight:
                                        ResponsiveRadius.screenBased(
                                          context,
                                        ).topRight,
                                    bottomRight:
                                        ResponsiveRadius.screenBased(
                                          context,
                                        ).bottomRight,
                                  ),
                                  border: Border(
                                    left: BorderSide(
                                      color: colorScheme.secondary,
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: Text('₸', style: contrastM(context)),
                                ),
                              ),
                              SizedBox(width: screenSize.width * 0.04),
                              GestureDetector(
                                onTap: () {
                                  showBottomPicker<String>(
                                    context: context,
                                    items: units,
                                    itemAlignment: TextAlign.center,
                                    itemBuilder: (context, item) => Text(item),
                                    onItemSelected: (item) {
                                      setState(() {
                                        _pricePerUnit = item;
                                      });
                                    },
                                  );
                                },
                                child: Container(
                                  width: screenSize.width * 0.15,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _pricePerUnit,
                                      style: overGreenBoldM(context),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      CustomTextField(
                        controller: priceController,
                        theme: colorScheme,
                        style: contrastM(context),
                        hintText:
                            widget.category.settings['salary'] == false
                                ? 'Enter price of advert'
                                : 'Enter salary',
                        border: true,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          if (widget.category.settings['quantity'] == true) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.05,
                  vertical: screenSize.height * 0.015,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Volume / Quantity', style: contrastBoldM(context)),
                    SizedBox(height: screenSize.height * 0.015),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface,
                        borderRadius: ResponsiveRadius.screenBased(context),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final buttonWidth =
                              (constraints.maxWidth -
                                  screenSize.width * 0.015) /
                              2;

                          return ToggleButtons(
                            borderRadius: ResponsiveRadius.screenBased(context),
                            fillColor: colorScheme.primary,
                            selectedColor: colorScheme.onPrimary,
                            color: colorScheme.primary,
                            textStyle: contrastM(context),
                            constraints: BoxConstraints(
                              minHeight: screenSize.height * 0.05,
                              minWidth: buttonWidth,
                            ),
                            isSelected: [_isQuantityFixed, !_isQuantityFixed],
                            onPressed: (index) {
                              setState(() {
                                _isQuantityFixed = index == 0;
                              });
                            },
                            children: const [Text('Fixed'), Text('Negotiable')],
                          );
                        },
                      ),
                    ),
                    if (_isQuantityFixed) ...[
                      SizedBox(height: screenSize.height * 0.02),
                      if (widget.category.settings['maxQuantity'] == true) ...[
                        SizedBox(
                          height: screenSize.height * 0.06,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: quantityController,
                                  theme: colorScheme,
                                  style: contrastM(context),
                                  hintText: 'From',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(width: screenSize.width * 0.04),
                              Expanded(
                                child: CustomTextField(
                                  controller: maxQuantityController,
                                  theme: colorScheme,
                                  style: contrastM(context),
                                  hintText: 'To',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(width: screenSize.width * 0.04),
                              GestureDetector(
                                onTap: () {
                                  showBottomPicker<String>(
                                    context: context,
                                    items: units,
                                    itemAlignment: TextAlign.center,
                                    itemBuilder: (context, item) => Text(item),
                                    onItemSelected: (item) {
                                      setState(() {
                                        _quantityUnit = item;
                                      });
                                    },
                                  );
                                },
                                child: Container(
                                  width: screenSize.width * 0.15,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _quantityUnit,
                                      style: overGreenBoldM(context),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        SizedBox(
                          height: screenSize.height * 0.06,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: quantityController,
                                  theme: colorScheme,
                                  style: contrastM(context),
                                  hintText: 'Enter volume / quantity',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(width: screenSize.width * 0.04),
                              GestureDetector(
                                onTap: () {
                                  showBottomPicker<String>(
                                    context: context,
                                    items: units,
                                    itemAlignment: TextAlign.center,
                                    itemBuilder: (context, item) => Text(item),
                                    onItemSelected: (item) {
                                      setState(() {
                                        _quantityUnit = item;
                                      });
                                    },
                                  );
                                },
                                child: Container(
                                  width: screenSize.width * 0.15,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _quantityUnit,
                                      style: overGreenBoldM(context),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: screenSize.height * 0.015,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Region', style: contrastBoldM(context)),
                  SizedBox(height: screenSize.height * 0.015),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(
                        screenSize.width,
                        screenSize.height * 0.06,
                      ),
                      backgroundColor: colorScheme.onSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: ResponsiveRadius.screenBased(context),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _region.isEmpty ? 'Select region' : _region,
                          style: contrastM(context),
                        ),
                        Icon(
                          CupertinoIcons.chevron_down,
                          color: colorScheme.inversePrimary,
                        ),
                      ],
                    ),
                    onPressed: () {
                      showBottomPicker<String>(
                        context: context,
                        items: regions.map((e) => e.name).toList(),
                        itemBuilder: (context, item) => Text(item),
                        itemAlignment: TextAlign.center,
                        onItemSelected: (item) {
                          setState(() {
                            _region = item;
                            _district =
                                ''; // Reset district when region changes
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: screenSize.height * 0.015,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('District', style: contrastBoldM(context)),
                  SizedBox(height: screenSize.height * 0.015),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(
                        screenSize.width,
                        screenSize.height * 0.06,
                      ),
                      backgroundColor: colorScheme.onSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: ResponsiveRadius.screenBased(context),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _district.isEmpty ? 'Select district' : _district,
                          style: contrastM(context),
                        ),
                        Icon(
                          CupertinoIcons.chevron_down,
                          color: colorScheme.inversePrimary,
                        ),
                      ],
                    ),
                    onPressed: () {
                      if (_region.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please select region first')),
                        );
                        return;
                      }

                      final selectedRegion = regions.firstWhere(
                        (e) => e.name == _region,
                      );
                      if (selectedRegion.subcategories == null ||
                          selectedRegion.subcategories!.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'No districts available for this region',
                            ),
                          ),
                        );
                        return;
                      }

                      showBottomPicker<String>(
                        context: context,
                        items:
                            selectedRegion.subcategories!
                                .map((e) => e.name)
                                .toList(),
                        itemBuilder: (context, item) => Text(item),
                        itemAlignment: TextAlign.center,
                        onItemSelected: (item) {
                          setState(() {
                            _district = item;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: screenSize.height * 0.015,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description', style: contrastBoldM(context)),
                  SizedBox(height: screenSize.height * 0.015),
                  CustomTextField(
                    controller: descriptionController,
                    theme: colorScheme,
                    style: contrastM(context),
                    minLines: 3,
                    maxLines: 10,
                    hintText: 'Describe your advert',
                    border: true,
                  ),
                ],
              ),
            ),
          ),
          // SliverGrid(
          //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //     crossAxisCount: crossAxisCount,
          //     crossAxisSpacing: crossAxisSpacing,
          //     mainAxisSpacing: mainAxisSpacing,
          //     childAspectRatio: childAspectRatio,
          //   ),
          //   delegate: SliverChildBuilderDelegate((context, index) {
          //     if (index >= widget.category.settings.length) {
          //       return null;
          //     }
          //     final setting = widget.category.settings.keys.toList()[index];
          //     return Padding(
          //       padding: EdgeInsets.symmetric(
          //         horizontal: screenSize.width * 0.05,
          //         vertical: screenSize.height * 0.01,
          //       ),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text(setting, style: contrastBoldM(context)),
          //           SizedBox(height: screenSize.height * 0.01),
          //           CustomTextField(
          //             controller: settingsControllers[index],
          //             theme: colorScheme,
          //             style: greenM(context),
          //             hintText: setting,
          //             border: true,
          //           ),
          //         ],
          //       ),
          //     );
          //   }, childCount: widget.category.settings.length),
          // ),
          if (widget.category.settings['companyName'] == true) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.05,
                  vertical: screenSize.height * 0.015,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Company', style: contrastBoldM(context)),
                    SizedBox(height: screenSize.height * 0.015),
                    CustomTextField(
                      controller: descriptionController,
                      theme: colorScheme,
                      style: contrastM(context),
                      hintText: 'Example: Apple',
                      border: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (widget.category.settings['contactPerson'] == true) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.05,
                  vertical: screenSize.height * 0.015,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Contact person', style: contrastBoldM(context)),
                    SizedBox(height: screenSize.height * 0.015),
                    CustomTextField(
                      controller: descriptionController,
                      theme: colorScheme,
                      style: contrastM(context),
                      hintText: 'Example: John Doe',
                      border: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: screenSize.height * 0.015,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phone number', style: contrastBoldM(context)),
                  SizedBox(height: screenSize.height * 0.015),
                  CustomTextField(
                    controller: phoneController,
                    theme: colorScheme,
                    style: contrastM(context),
                    hintText: 'Enter phone number',
                    border: true,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: screenSize.height * 0.015,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Images', style: contrastBoldM(context)),
                  SizedBox(height: screenSize.height * 0.015),
                  // Главная фотография
                  GestureDetector(
                    onTap: () => _pickImage(),
                    child: Container(
                      width: double.infinity,
                      height: screenSize.height * 0.2,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface,
                        borderRadius: ResponsiveRadius.screenBased(context),
                      ),
                      child:
                          _images.isEmpty
                              ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.plus_square_fill,
                                    size: 32,
                                    color: colorScheme.primary,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Добавить Главное Фото',
                                    style: greenM(context),
                                  ),
                                ],
                              )
                              : ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  File(_images.first!.path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                    ),
                  ),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    crossAxisSpacing: screenSize.width * 0.01,
                    mainAxisSpacing: screenSize.height * 0.01,
                    physics: NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.3,
                    children: List.generate(
                      _images.length < 10 ? _images.length + 1 : 10,
                      (index) {
                        if (index < _images.length) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  File(_images[index]!.path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.onSurface,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Icon(
                                  CupertinoIcons.plus_square_fill,
                                  size: 32,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
