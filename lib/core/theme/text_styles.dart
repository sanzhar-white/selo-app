import 'package:flutter/material.dart';

TextStyle titleStyle1(BuildContext context) {
  final color = Theme.of(context).colorScheme.onPrimary;
  return TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color);
}

TextStyle titleStyle2(BuildContext context) {
  final color = Theme.of(context).colorScheme.onPrimary;
  return TextStyle(fontSize: 16, color: color);
}

TextStyle titleStyle3(BuildContext context) {
  final color = Theme.of(context).colorScheme.primary;
  return TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color);
}

TextStyle titleStyle4(BuildContext context) {
  final color = Theme.of(context).colorScheme.primary;
  return TextStyle(fontSize: 16, color: color);
}
