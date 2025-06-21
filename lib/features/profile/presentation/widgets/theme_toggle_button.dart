import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:selo/core/constants/images.dart';
import 'package:selo/core/providers/theme_provider.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/generated/l10n.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final radius = ResponsiveRadius.screenBased(context);
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
      child: Container(
        width: screenSize.width * 0.3,
        height: screenSize.height * 0.07, // _headerHeightFactor
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.02, // _paddingFactor
        ),
        decoration: BoxDecoration(
          color: colorScheme.onSurface,
          borderRadius: radius,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              theme.brightness == Brightness.light
                  ? Images.sunSvg
                  : Images.moonSvg,
              width: screenSize.width * 0.035,
              height: screenSize.height * 0.035,
              colorFilter: ColorFilter.mode(
                theme.brightness == Brightness.light
                    ? Colors.orangeAccent
                    : Colors.deepPurpleAccent,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                theme.brightness == Brightness.light
                    ? S.of(context)!.theme_light
                    : S.of(context)!.theme_dark,
                overflow: TextOverflow.ellipsis,
                style: contrastM(context),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
