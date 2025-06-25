import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/theme/text_styles.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    required this.controller, required this.theme, required this.style, required this.hintText, super.key,
    this.borderRadius,
    this.border = true,
    this.minLines,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
    this.error = false,
    this.errorText,
    this.formatters,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final ColorScheme theme;
  final TextStyle style;
  final String hintText;
  final BorderRadius? borderRadius;
  final bool border;
  final int? minLines;
  final int maxLines;
  final TextAlign textAlign;
  final bool error;
  final String? errorText;
  final List<TextInputFormatter>? formatters;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          style: style,
          minLines: minLines,
          maxLines: maxLines,
          textAlign: textAlign,
          textAlignVertical: TextAlignVertical.top,
          inputFormatters: formatters,
          keyboardType: keyboardType,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            isDense: true,
            fillColor: theme.onSurface,
            filled: true,
            hintText: hintText,
            hintStyle: grayM(context),
            border: OutlineInputBorder(
              borderRadius:
                  borderRadius ?? ResponsiveRadius.screenBased(context),
              borderSide: BorderSide(
                color:
                    error
                        ? Theme.of(context).colorScheme.error
                        : Colors.transparent,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color:
                    error
                        ? Theme.of(context).colorScheme.error
                        : Colors.transparent,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color:
                    error
                        ? Theme.of(context).colorScheme.error
                        : (border ? theme.primary : Colors.transparent),
                width: 2,
              ),
            ),
            errorText: error ? errorText : null,
            errorStyle: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
