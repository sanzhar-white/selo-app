import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/core/theme/thousands_separator_input_formatter.dart';
import 'package:selo/shared/widgets/custom_text_field.dart';
import 'package:selo/shared/widgets/show_bottom_picker.dart';
import 'package:selo/features/add/presentation/widgets/custom_toggle_buttons.dart';

class PriceSection extends StatelessWidget {
  final bool isPriceFixed;
  final bool hasMaxPrice;
  final bool hasPricePer;
  final bool isSalary;
  final String pricePerUnit;
  final List<String> units;
  final TextEditingController priceController;
  final TextEditingController maxPriceController;
  final ValueChanged<bool> onPriceTypeChanged;
  final ValueChanged<String> onUnitChanged;
  final bool priceError;
  final bool maxPriceError;

  const PriceSection({
    super.key,
    required this.isPriceFixed,
    required this.hasMaxPrice,
    required this.hasPricePer,
    required this.isSalary,
    required this.pricePerUnit,
    required this.units,
    required this.priceController,
    required this.maxPriceController,
    required this.onPriceTypeChanged,
    required this.onUnitChanged,
    this.priceError = false,
    this.maxPriceError = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isSalary ? 'Salary' : (hasPricePer ? 'Price per unit' : 'Price'),
          style: contrastBoldM(context),
        ),
        SizedBox(height: screenSize.height * 0.015),
        CustomToggleButtons(
          options: const ['Fixed', 'Negotiable'],
          selectedIndex: isPriceFixed ? 0 : 1,
          onChanged: (index) => onPriceTypeChanged(index == 0),
        ),
        if (isPriceFixed) ...[
          SizedBox(height: screenSize.height * 0.02),
          if (hasMaxPrice && hasPricePer)
            _buildPriceRangeWithUnit(context)
          else if (hasMaxPrice)
            _buildPriceRange(context)
          else if (hasPricePer)
            _buildSinglePriceWithUnit(context)
          else
            CustomTextField(
              controller: priceController,
              theme: colorScheme,
              style: contrastM(context),
              hintText: isSalary ? 'Enter salary' : 'Enter price of advert',
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
              keyboardType: TextInputType.number,
              border: true,
              error: priceError,
              errorText: 'Price is required',
            ),
        ],
      ],
    );
  }

  Widget _buildPriceRangeWithUnit(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return SizedBox(
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
              error: priceError,
              errorText: 'Price is required',
              borderRadius: BorderRadius.only(
                topLeft: ResponsiveRadius.screenBased(context).topLeft,
                bottomLeft: ResponsiveRadius.screenBased(context).bottomLeft,
                topRight: Radius.zero,
                bottomRight: Radius.zero,
              ),
            ),
          ),
          _buildCurrencyContainer(context, priceError),
          SizedBox(width: screenSize.width * 0.04),
          Expanded(
            child: CustomTextField(
              controller: maxPriceController,
              theme: colorScheme,
              style: contrastM(context),
              hintText: 'To',
              error: maxPriceError,
              errorText: 'Max price is required',
              textAlign: TextAlign.center,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
              keyboardType: TextInputType.number,
              borderRadius: BorderRadius.only(
                topLeft: ResponsiveRadius.screenBased(context).topLeft,
                bottomLeft: ResponsiveRadius.screenBased(context).bottomLeft,
                topRight: Radius.zero,
                bottomRight: Radius.zero,
              ),
            ),
          ),
          _buildCurrencyContainer(context, maxPriceError),
          SizedBox(width: screenSize.width * 0.04),
          _buildUnitSelector(context),
        ],
      ),
    );
  }

  Widget _buildPriceRange(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return SizedBox(
      height: screenSize.height * 0.06,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPriceField(context, priceController, 'From', priceError),
          SizedBox(width: screenSize.width * 0.04),
          _buildPriceField(context, maxPriceController, 'To', maxPriceError),
        ],
      ),
    );
  }

  Widget _buildSinglePriceWithUnit(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return SizedBox(
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
              error: priceError,
              errorText: 'Price is required',
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
              keyboardType: TextInputType.number,
            ),
          ),
          _buildCurrencyContainer(context, priceError),
          SizedBox(width: screenSize.width * 0.04),
          _buildUnitSelector(context),
        ],
      ),
    );
  }

  Widget _buildPriceField(
    BuildContext context,
    TextEditingController controller,
    String hint,
    bool error,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width * 0.5,
      decoration: BoxDecoration(
        color: colorScheme.onSurface,
        borderRadius: ResponsiveRadius.screenBased(context),
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              controller: controller,
              theme: colorScheme,
              style: contrastM(context),
              hintText: hint,
              error: error,
              errorText: 'Price is required',
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
              keyboardType: TextInputType.number,
            ),
          ),
          _buildCurrencyContainer(context, error),
        ],
      ),
    );
  }

  Widget _buildCurrencyContainer(BuildContext context, bool error) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width * 0.15,
      decoration: BoxDecoration(
        color: colorScheme.onSurface,
        borderRadius: BorderRadius.only(
          topRight: ResponsiveRadius.screenBased(context).topRight,
          bottomRight: ResponsiveRadius.screenBased(context).bottomRight,
        ),
        border: Border(
          left: BorderSide(color: error ? Colors.red : colorScheme.secondary),
        ),
      ),
      child: Center(child: Text('₸', style: contrastM(context))),
    );
  }

  Widget _buildUnitSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        showBottomPicker<String>(
          context: context,
          items: units,
          itemAlignment: TextAlign.center,
          itemBuilder: (context, item) => Text(item),
          onItemSelected: onUnitChanged,
        );
      },
      child: Container(
        width: screenSize.width * 0.15,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(pricePerUnit, style: overGreenBoldM(context)),
        ),
      ),
    );
  }
}
