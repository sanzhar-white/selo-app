import 'package:flutter/material.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/theme/text_styles.dart';

class CustomToggleButtons extends StatelessWidget {
  const CustomToggleButtons({
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
    this.height,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.textStyle,
  }) : assert(selectedIndex >= 0 && selectedIndex < options.length);
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double? height;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final radius = ResponsiveRadius.screenBased(context);
    final defaultHeight =
        screenSize.height > 800
            ? screenSize.height * 0.05
            : screenSize.height * 0.06;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: unselectedColor ?? colorScheme.onSurface,
        borderRadius: radius,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final buttonWidth =
              (constraints.maxWidth - screenSize.width * 0.015) /
              options.length;

          return ToggleButtons(
            borderRadius: radius,
            fillColor: selectedColor ?? colorScheme.primary,
            selectedColor: selectedTextColor ?? colorScheme.onPrimary,
            color: unselectedTextColor ?? colorScheme.primary,
            textStyle: textStyle ?? contrastM(context),
            constraints: BoxConstraints(
              minHeight: height ?? defaultHeight,
              minWidth: buttonWidth,
            ),
            isSelected: List.generate(
              options.length,
              (index) => index == selectedIndex,
            ),
            onPressed: onChanged,
            children: options.map(Text.new).toList(),
          );
        },
      ),
    );
  }
}
