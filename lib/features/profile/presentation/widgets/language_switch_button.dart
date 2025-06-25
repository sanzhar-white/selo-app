import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:selo/core/constants/images.dart';
import 'package:selo/core/providers/locale_provider.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/generated/l10n.dart';

class LanguageSwitchButton extends ConsumerWidget {
  const LanguageSwitchButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final radius = ResponsiveRadius.screenBased(context);
    final screenSize = MediaQuery.of(context).size;
    final supportedLocales = const [Locale('en'), Locale('ru'), Locale('kk')];

    return GestureDetector(
      onTap: () {
        final currentIndex = supportedLocales.indexOf(locale);
        final nextIndex = (currentIndex + 1) % supportedLocales.length;
        ref
            .read(localeProvider.notifier)
            .setLocale(supportedLocales[nextIndex]);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
        width: screenSize.width * 0.25,
        height: screenSize.height * 0.07,
        decoration: BoxDecoration(
          color: colorScheme.onSurface,
          borderRadius: radius,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                Images.languageSvg,
                width: screenSize.width * 0.05,
                height: screenSize.height * 0.05,
              ),
              const SizedBox(width: 8),
              Text(
                S.of(context).language_display_code,
                style: contrastBoldM(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
