import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/core/theme/thousands_separator_input_formatter.dart';
import 'package:selo/shared/widgets/custom_text_field.dart';
import 'package:selo/shared/widgets/show_bottom_picker.dart';

class QuantitySection extends StatelessWidget {
  final bool isQuantityFixed;
  final bool hasMaxQuantity;
  final String quantityUnit;
  final List<String> units;
  final TextEditingController quantityController;
  final TextEditingController maxQuantityController;
  final ValueChanged<bool> onQuantityTypeChanged;
  final ValueChanged<String> onUnitChanged;
  final bool quantityError;
  final bool maxQuantityError;
  final String quantityErrorText;
  final String maxQuantityErrorText;

  const QuantitySection({
    super.key,
    required this.isQuantityFixed,
    required this.hasMaxQuantity,
    required this.quantityUnit,
    required this.units,
    required this.quantityController,
    required this.maxQuantityController,
    required this.onQuantityTypeChanged,
    required this.onUnitChanged,
    this.quantityError = false,
    this.maxQuantityError = false,
    this.quantityErrorText = 'Quantity is required',
    this.maxQuantityErrorText = 'Max quantity is required',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Volume / Quantity', style: contrastBoldM(context)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.onSurface,
            borderRadius: ResponsiveRadius.screenBased(context),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final buttonWidth = (constraints.maxWidth - 12) / 2;

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
                isSelected: [isQuantityFixed, !isQuantityFixed],
                onPressed: (index) => onQuantityTypeChanged(index == 0),
                children: const [Text('Fixed'), Text('Negotiable')],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        if (isQuantityFixed)
          hasMaxQuantity
              ? _buildQuantityRange(context, colorScheme, screenSize)
              : _buildSingleQuantity(context, colorScheme, screenSize),
      ],
    );
  }

  Widget _buildQuantityRange(
    BuildContext context,
    ColorScheme colorScheme,
    Size screenSize,
  ) {
    return SizedBox(
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
              error: quantityError,
              errorText: quantityErrorText,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
              keyboardType: TextInputType.number,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: CustomTextField(
              controller: maxQuantityController,
              theme: colorScheme,
              style: contrastM(context),
              hintText: 'To',
              textAlign: TextAlign.center,
              error: maxQuantityError,
              errorText: maxQuantityErrorText,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
              keyboardType: TextInputType.number,
            ),
          ),
          SizedBox(width: 16),
          _buildUnitSelector(context, colorScheme, screenSize),
        ],
      ),
    );
  }

  Widget _buildSingleQuantity(
    BuildContext context,
    ColorScheme colorScheme,
    Size screenSize,
  ) {
    return SizedBox(
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
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              error: quantityError,
              errorText: quantityErrorText,
            ),
          ),
          SizedBox(width: 16),
          _buildUnitSelector(context, colorScheme, screenSize),
        ],
      ),
    );
  }

  Widget _buildUnitSelector(
    BuildContext context,
    ColorScheme colorScheme,
    Size screenSize,
  ) {
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
          child: Text(quantityUnit, style: overGreenBoldM(context)),
        ),
      ),
    );
  }
}
