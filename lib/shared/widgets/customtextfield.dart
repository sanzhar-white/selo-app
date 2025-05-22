import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.theme,
    required this.style,
    required this.hintText,
    this.border = true,
  });

  final TextEditingController controller;
  final ColorScheme theme;
  final TextStyle style;
  final String hintText;
  final bool border;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: style,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        isDense: true,
        fillColor: theme.onSurface,
        filled: true,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: border == true ? theme.primary : Colors.transparent,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
