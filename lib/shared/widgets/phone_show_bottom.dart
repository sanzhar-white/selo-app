import 'package:flutter/material.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/core/utils/utils.dart';
import 'package:selo/generated/l10n.dart';
import 'package:url_launcher/url_launcher_string.dart';

// Function to show the bottom sheet
void showPhoneBottomSheet(BuildContext context, String phoneNumber) {
  showBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      final colorScheme = Theme.of(context).colorScheme;
      final screenSize = MediaQuery.of(context).size;
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.05,
          vertical: screenSize.height * 0.04,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: ResponsiveRadius.screenBased(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 30,
              offset: const Offset(
                0,
                -2,
              ), // Shadow slightly above the container
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: screenSize.width * 0.15,
              height: 4,
              margin: EdgeInsets.only(bottom: screenSize.width * 0.05),
              decoration: BoxDecoration(
                color: colorScheme.inversePrimary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(S.of(context).phone_number, style: contrastBoldM(context)),
            SizedBox(height: screenSize.width * 0.01),
            Text(formatPhoneNumber(phoneNumber), style: contrastBoldL(context)),
            SizedBox(height: screenSize.width * 0.04),
            Divider(height: 1.0),
            SizedBox(height: screenSize.width * 0.04),
            ListTile(
              title: Center(
                child: Text(S.of(context).call, style: greenBoldM(context)),
              ),
              onTap: () {
                String formattedNumber = phoneNumber.replaceAll(
                  RegExp(r'[^\d+]'),
                  '',
                );
                if (!formattedNumber.startsWith('+')) {
                  formattedNumber = '+$formattedNumber';
                }
                launchUrlString("tel:$formattedNumber");
                Navigator.pop(context); // Close the bottom sheet after action
              },
            ),
            SizedBox(height: screenSize.height * 0.02),
          ],
        ),
      );
    },
  );
}
