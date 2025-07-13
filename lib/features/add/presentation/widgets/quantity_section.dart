import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/core/theme/thousands_separator_input_formatter.dart';
import 'package:selo/shared/widgets/custom_text_field.dart';
import 'package:selo/shared/widgets/show_bottom_picker.dart';
import 'package:selo/generated/l10n.dart';

class QuantitySection extends StatelessWidget {
  const QuantitySection({
    required this.isQuantityFixed,
    required this.hasMaxQuantity,
    required this.quantityUnit,
    required this.units,
    required this.quantityController,
    required this.maxQuantityController,
    required this.onQuantityTypeChanged,
    required this.onUnitChanged,
    required this.showUnitSelector,
    super.key,
    this.quantityError = false,
    this.maxQuantityError = false,
    this.quantityErrorText = 'Quantity is required',
    this.maxQuantityErrorText = 'Max quantity is required',
  });
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
  final bool showUnitSelector;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final radius = ResponsiveRadius.screenBased(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.of(context)!.volume_quantity, style: contrastBoldM(context)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.onSurface,
            borderRadius: radius,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final buttonWidth = (constraints.maxWidth - 12) / 2;
              return ToggleButtons(
                borderRadius: radius,
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
                children: [
                  Text(S.of(context)!.fixed),
                  Text(S.of(context)!.negotiable),
                ],
              );
            },
          ),
        ),
        SizedBox(height: screenSize.height * 0.015),
        if (isQuantityFixed) ...[
          if (hasMaxQuantity && showUnitSelector)
            _buildQuantityRange(context)
          else if (hasMaxQuantity)
            _buildQuantityRange(context)
          else if (showUnitSelector)
            _buildSingleQuantity(context)
          else
            _buildSimpleQuantityField(context),
        ],
      ],
    );
  }

  Widget _buildSimpleQuantityField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomTextField(
      controller: quantityController,
      theme: colorScheme,
      style: contrastM(context),
      hintText: S.of(context)!.volume_quantity,
      formatters: [
        FilteringTextInputFormatter.digitsOnly,
        ThousandsSeparatorInputFormatter(),
      ],
      keyboardType: TextInputType.number,
      error: quantityError,
      errorText: quantityErrorText,
    );
  }

  Widget _buildQuantityRange(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return SizedBox(
      height: screenSize.height * 0.08,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CustomTextField(
              controller: quantityController,
              theme: colorScheme,
              style: contrastM(context),
              hintText: S.of(context)!.from,
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
          const SizedBox(width: 16),
          Expanded(
            child: CustomTextField(
              controller: maxQuantityController,
              theme: colorScheme,
              style: contrastM(context),
              hintText: S.of(context)!.to,
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
          if (showUnitSelector) ...[
            const SizedBox(width: 16),
            _buildUnitSelector(context, colorScheme, screenSize),
          ],
        ],
      ),
    );
  }

  Widget _buildSingleQuantity(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return SizedBox(
      height: screenSize.height * 0.08,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CustomTextField(
              controller: quantityController,
              theme: colorScheme,
              style: contrastM(context),
              hintText: S.of(context)!.volume_quantity,
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
          const SizedBox(width: 16),
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
        height: screenSize.height * 0.06,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: radius,
        ),
        child: Center(
          child: Text(quantityUnit, style: overGreenBoldM(context)),
        ),
      ),
    );
  }
}
