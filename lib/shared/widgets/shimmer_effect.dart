import 'package:flutter/material.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerEffect extends StatelessWidget {

  const ShimmerEffect({
    required this.width, required this.height, super.key,
    this.borderRadius = 8.0,
    this.baseColor,
    this.highlightColor,
    this.child,
  });
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBaseColor = baseColor ?? theme.colorScheme.onSurface;
    final defaultHighlightColor = highlightColor ?? theme.colorScheme.surface;

    return SizedBox(
      width: width,
      height: height,
      child: Shimmer.fromColors(
        baseColor: defaultBaseColor,
        highlightColor: defaultHighlightColor,
        child:
            child ??
            Container(
              decoration: BoxDecoration(
                color: defaultBaseColor,
                borderRadius: ResponsiveRadius.screenBased(context),
              ),
            ),
      ),
    );
  }
}
