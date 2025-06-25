import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/core/utils/utils.dart';
import 'package:selo/generated/l10n.dart';
import 'package:url_launcher/url_launcher_string.dart';

void showPhoneBottomSheet(BuildContext context, String phoneNumber) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      final screenSize = MediaQuery.of(context).size;

      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.inversePrimary,
                blurRadius: 30,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.inversePrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(S.of(context).phone_number, style: contrastBoldM(context)),
              const SizedBox(height: 8),
              Text(
                formatPhoneNumber(phoneNumber),
                style: contrastBoldL(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Divider(color: colorScheme.outlineVariant),
              const SizedBox(height: 16),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  String formatted = phoneNumber.replaceAll(
                    RegExp(r'[^\d+]'),
                    '',
                  );
                  if (!formatted.startsWith('+')) {
                    formatted = '+$formatted';
                  }
                  final url = "tel:$formatted";
                  if (await canLaunchUrlString(url)) {
                    await launchUrlString(url);
                    context.pop();
                    ;
                  }
                },
                child: GestureDetector(
                  onTap: () {
                    String formattedNumber = phoneNumber.replaceAll(
                      RegExp(r'[^\d+]'),
                      '',
                    );
                    if (!formattedNumber.startsWith('+')) {
                      formattedNumber = '+$formattedNumber';
                    }
                    launchUrlString("tel:$formattedNumber");
                    context.pop();
                    ;
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: colorScheme.primaryContainer,
                    ),
                    child: Text(
                      S.of(context).call,
                      style: overGreenBoldM(context),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),
            ],
          ),
        ),
      );
    },
  );
}
