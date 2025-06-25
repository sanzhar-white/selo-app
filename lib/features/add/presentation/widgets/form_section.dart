import 'package:flutter/material.dart';
import 'package:selo/core/theme/responsive_radius.dart';

class FormSection extends StatelessWidget {

  const FormSection({
    required this.child, super.key,
    this.title,
    this.titleStyle,
  });
  final String? title;
  final Widget child;
  final TextStyle? titleStyle;

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
