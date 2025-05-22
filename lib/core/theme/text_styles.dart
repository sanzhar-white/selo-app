import 'package:flutter/material.dart';

TextStyle GreenL(BuildContext context) {
  final color = Theme.of(context).colorScheme.primary;
  return TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color);
}

TextStyle GreenM(BuildContext context) {
  final color = Theme.of(context).colorScheme.primary;
  return TextStyle(fontSize: 16, color: color);
}

TextStyle GreenS(BuildContext context) {
  final color = Theme.of(context).colorScheme.primary;
  return TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color);
}

TextStyle GreenXS(BuildContext context) {
  final color = Theme.of(context).colorScheme.primary;
  return TextStyle(fontSize: 10, color: color);
}

TextStyle OverGreenL(BuildContext context) {
  final color = Theme.of(context).colorScheme.onPrimary;
  return TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color);
}

TextStyle OverGreenM(BuildContext context) {
  final color = Theme.of(context).colorScheme.onPrimary;
  return TextStyle(fontSize: 16, color: color);
}

TextStyle OverGreenS(BuildContext context) {
  final color = Theme.of(context).colorScheme.onPrimary;
  return TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color);
}

TextStyle OverGreenXS(BuildContext context) {
  final color = Theme.of(context).colorScheme.onPrimary;
  return TextStyle(fontSize: 10, color: color);
}
