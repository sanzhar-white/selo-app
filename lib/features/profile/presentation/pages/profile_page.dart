import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/providers/locale_provider.dart';
import 'package:selo/core/providers/theme_provider.dart';
import 'package:selo/features/authentication/presentation/provider/authentication_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:selo/core/services/local_storage_service.dart';
import 'package:selo/shared/widgets/popup_window.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final userState = ref.watch(userNotifierProvider);
    final locale = ref.watch(localeProvider);
    final theme = ref.watch(themeProvider);
    final supportedLocales = const [Locale('en'), Locale('ru'), Locale('kk')];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(S.of(context).profile_title, style: contrastL(context)),
            centerTitle: false,
            expandedHeight: screenSize.height * 0.07,
            actions: [
              GestureDetector(
                onTap: () {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
                child: Container(
                  width: screenSize.width * 0.25,
                  height: screenSize.height * 0.07,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface,
                    borderRadius: ResponsiveRadius.screenBased(context),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (theme.brightness != Brightness.light) ...[
                          SvgPicture.asset(
                            'assets/images/profile/moon.svg',
                            width: screenSize.width * 0.035,
                            height: screenSize.height * 0.035,
                            colorFilter: const ColorFilter.mode(
                              Colors.deepPurpleAccent,
                              BlendMode.srcIn,
                            ),
                          ),
                        ] else ...[
                          SvgPicture.asset(
                            'assets/images/profile/sun.svg',
                            width: screenSize.width * 0.04,
                            height: screenSize.height * 0.04,
                            colorFilter: const ColorFilter.mode(
                              Colors.orange,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        Text(
                          theme.brightness != Brightness.light
                              ? S.of(context).theme_dark
                              : S.of(context).theme_light,
                          style: contrastBoldM(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final currentIndex = supportedLocales.indexOf(locale);
                  final nextIndex =
                      (currentIndex + 1) % supportedLocales.length;
                  ref
                      .read(localeProvider.notifier)
                      .setLocale(supportedLocales[nextIndex]);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.05,
                  ),
                  width: screenSize.width * 0.25,
                  height: screenSize.height * 0.07,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface,
                    borderRadius: ResponsiveRadius.screenBased(context),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/images/profile/language.svg',
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
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              height: screenSize.height * 0.35,
              color: colorScheme.surface,
              child: Center(
                child:
                    userState.isLoading
                        ? const CircularProgressIndicator()
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (userState.user != null) ...[
                              if (userState.user?.profileImage?.isNotEmpty ??
                                  false) ...[
                                CircleAvatar(
                                  radius: screenSize.height * 0.1,
                                  backgroundImage: NetworkImage(
                                    userState.user!.profileImage,
                                  ),
                                ),
                              ] else ...[
                                CircleAvatar(
                                  radius: screenSize.height * 0.1,
                                  backgroundColor: colorScheme.inversePrimary,
                                  child: Icon(
                                    Icons.person,
                                    size: screenSize.height * 0.1,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    userState.user!.name,
                                    style: contrastL(context),
                                  ),
                                  const SizedBox(width: 4),
                                  if (userState.user?.lastName?.isNotEmpty ??
                                      false) ...[
                                    Text(
                                      userState.user!.lastName,
                                      style: contrastL(context),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (userState.user?.phoneNumber != null &&
                                  userState.user?.phoneNumber != '') ...[
                                Text(
                                  userState.user?.phoneNumber ?? '+7XXXXXXXXXX',
                                  style: contrastM(context),
                                ),
                              ] else ...[
                                Text('+7XXXXXXXXXX', style: contrastM(context)),
                              ],
                              if (userState.error != null)
                                Text(
                                  userState.error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              SizedBox(height: screenSize.height * 0.01),
                              GestureDetector(
                                onTap: () {
                                  if (userState.user?.phoneNumber == null ||
                                      userState.user?.phoneNumber == '') {
                                    PopupWindow(
                                      message:
                                          S.of(context).edit_anonymous_window,
                                      buttonText: S.of(context).login,
                                      onButtonPressed: () {
                                        ref
                                            .read(userNotifierProvider.notifier)
                                            .logOut();
                                        context.push(Routes.authenticationPage);
                                      },
                                    ).show(context);
                                  } else {
                                    context.push(Routes.nestedMyAdsPage);
                                  }
                                },
                                child: Text(
                                  S.of(context).edit_profile,
                                  style: contrastBoldM(context),
                                ),
                              ),
                            ] else ...[
                              Text(
                                S.of(context).my_ads_empty,
                                style: contrastL(context),
                              ),
                            ],
                          ],
                        ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    if (userState.user?.uid == null ||
                        userState.user?.uid == '' ||
                        userState.user?.phoneNumber == null ||
                        userState.user?.phoneNumber == '') {
                      PopupWindow(
                        message: S.of(context).edit_anonymous_window,
                        buttonText: S.of(context).login,
                        onButtonPressed: () {
                          ref.read(userNotifierProvider.notifier).logOut();
                          context.push(Routes.authenticationPage);
                        },
                      ).show(context);
                    } else {
                      context.push(Routes.nestedMyAdsPage);
                    }
                  },
                  child: Container(
                    width: screenSize.width * 0.9,
                    height: screenSize.height * 0.07,
                    margin: EdgeInsets.symmetric(
                      vertical: screenSize.height * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface,
                      borderRadius: ResponsiveRadius.screenBased(context),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.02,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/profile/my_advert.svg',
                          width: screenSize.width * 0.05,
                          height: screenSize.height * 0.05,
                        ),
                        SizedBox(width: screenSize.width * 0.02),
                        Text(
                          S.of(context).my_ads,
                          style: contrastBoldM(context),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    launchUrl(
                      Uri.parse(
                        'https://sites.google.com/view/privacypolicyselo/%D0%B3%D0%BB%D0%B0%D0%B2%D0%BD%D0%B0%D1%8F-%D1%81%D1%82%D1%80%D0%B0%D0%BD%D0%B8%D1%86%D0%B0',
                      ),
                    );
                  },
                  child: Container(
                    width: screenSize.width * 0.9,
                    height: screenSize.height * 0.07,
                    margin: EdgeInsets.symmetric(
                      vertical: screenSize.height * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface,
                      borderRadius: ResponsiveRadius.screenBased(context),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.02,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/profile/public.svg',
                          width: screenSize.width * 0.05,
                          height: screenSize.height * 0.05,
                        ),
                        SizedBox(width: screenSize.width * 0.02),
                        Text(
                          S.of(context).terms_and_conditions,
                          style: contrastBoldM(context),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await ref.read(logOutUseCaseProvider).call();
                    await LocalStorageService.deleteUser();
                    ref.read(userNotifierProvider.notifier).state =
                        const UserState();
                    if (context.mounted) {
                      context.go(Routes.authenticationPage);
                    }
                  },
                  child: Container(
                    width: screenSize.width * 0.9,
                    height: screenSize.height * 0.07,
                    margin: EdgeInsets.symmetric(
                      vertical: screenSize.height * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface,
                      borderRadius: ResponsiveRadius.screenBased(context),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.02,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/profile/leave.svg',
                          width: screenSize.width * 0.05,
                          height: screenSize.height * 0.05,
                        ),
                        SizedBox(width: screenSize.width * 0.02),
                        Text(
                          S.of(context).logout,
                          style: contrastBoldM(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
