import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/core/theme/thousands_separator_input_formatter.dart';
import 'package:selo/shared/widgets/custom_text_field.dart';
import 'package:selo/shared/widgets/show_bottom_picker.dart';
import 'package:selo/features/add/presentation/widgets/custom_toggle_buttons.dart';
import 'package:selo/generated/l10n.dart';

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
  final bool showPricePerSelector;

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
    required this.showPricePerSelector,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isSalary
              ? S.of(context).salary
              : (hasPricePer
                  ? S.of(context).price_per_unit
                  : S.of(context).price),
          style: contrastBoldM(context),
        ),
        SizedBox(height: screenSize.height * 0.015),
        CustomToggleButtons(
          options: [S.of(context).fixed, S.of(context).negotiable],
          selectedIndex: isPriceFixed ? 0 : 1,
          onChanged: (index) => onPriceTypeChanged(index == 0),
        ),
        SizedBox(height: screenSize.height * 0.015),
        if (isPriceFixed) ...[
          if (hasMaxPrice && showPricePerSelector)
            _buildPriceRangeWithUnit(context)
          else if (hasMaxPrice)
            _buildPriceRange(context)
          else if (showPricePerSelector)
            _buildSinglePriceWithUnit(context)
          else
            _buildSimplePriceField(context),
        ],
      ],
    );
  }

  Widget _buildSimplePriceField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomTextField(
      controller: priceController,
      theme: colorScheme,
      style: contrastM(context),
      hintText: S.of(context).price_hint,
      formatters: [
        FilteringTextInputFormatter.digitsOnly,
        ThousandsSeparatorInputFormatter(),
      ],
      keyboardType: TextInputType.number,
      border: true,
      error: priceError,
      errorText: S.of(context).price_required,
    );
  }

  Widget _buildPriceRangeWithUnit(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final radius = ResponsiveRadius.screenBased(context);

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
              hintText: S.of(context).from,
              textAlign: TextAlign.center,
              error: priceError,
              errorText: S.of(context).price_required,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
              keyboardType: TextInputType.number,
              borderRadius: BorderRadius.only(
                topLeft: radius.topLeft,
                bottomLeft: radius.bottomLeft,
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
              hintText: S.of(context).to,
              error: maxPriceError,
              errorText: S.of(context).max_price_required,
              textAlign: TextAlign.center,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
              keyboardType: TextInputType.number,
              borderRadius: BorderRadius.only(
                topLeft: radius.topLeft,
                bottomLeft: radius.bottomLeft,
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
    final screenSize = MediaQuery.of(context).size;

    return SizedBox(
      height: screenSize.height * 0.06,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPriceField(
            context,
            priceController,
            S.of(context).from,
            priceError,
          ),
          SizedBox(width: screenSize.width * 0.04),
          _buildPriceField(
            context,
            maxPriceController,
            S.of(context).to,
            maxPriceError,
          ),
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
              hintText: S.of(context).price_hint,
              textAlign: TextAlign.center,
              error: priceError,
              errorText: S.of(context).price_required,
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
    final radius = ResponsiveRadius.screenBased(context);

    return Container(
      width: screenSize.width * 0.5,
      decoration: BoxDecoration(
        color: colorScheme.onSurface,
        borderRadius: radius,
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
              errorText: S.of(context).price_required,
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
    final radius = ResponsiveRadius.screenBased(context);

    return Container(
      width: screenSize.width * 0.15,
      decoration: BoxDecoration(
        color: colorScheme.onSurface,
        borderRadius: BorderRadius.only(
          topRight: radius.topRight,
          bottomRight: radius.bottomRight,
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
    final radius = ResponsiveRadius.screenBased(context);

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
          borderRadius: radius,
        ),
        child: Center(
          child: Text(pricePerUnit, style: overGreenBoldM(context)),
        ),
      ),
    );
  }
}
