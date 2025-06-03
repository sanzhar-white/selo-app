import 'package:flutter/material.dart';
import 'package:selo/core/theme/responsive_radius.dart';

class FormSection extends StatelessWidget {
  final String? title;
  final Widget child;
  final TextStyle? titleStyle;

  const FormSection({
    super.key,
    this.title,
    required this.child,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.05,
        vertical: screenSize.height * 0.015,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: titleStyle),
            SizedBox(height: screenSize.height * 0.015),
          ],
          child,
        ],
      ),
    );
  }
}
