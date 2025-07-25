import 'package:flutter/material.dart';

class ResponsiveRadius {
  static BorderRadius screenBased(
    BuildContext context, {
    double factor = 0.03,
    bool all = true,
  }) {
    final width = MediaQuery.of(context).size.width;
    final radius = width * factor;
    return all
        ? BorderRadius.circular(radius)
        : BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
        );
  }

  static BorderRadius widgetBased(
    double widgetWidth, {
    double factor = 0.1,
    bool all = true,
  }) {
    final radius = widgetWidth * factor;
    return all
        ? BorderRadius.circular(radius)
        : BorderRadius.only(
          topLeft: Radius.circular(radius),
          bottomRight: Radius.circular(radius),
        );
  }

  static BorderRadius circular(double size) {
    return BorderRadius.circular(size / 2);
  }

  static const BorderRadius small = BorderRadius.all(Radius.circular(8));
  static const BorderRadius medium = BorderRadius.all(Radius.circular(16));
  static const BorderRadius large = BorderRadius.all(Radius.circular(24));
}
