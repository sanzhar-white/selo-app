import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/providers/locale_provider.dart';
import 'package:selo/core/providers/theme_provider.dart';
import 'package:selo/features/authentication/presentation/provider/index.dart';
import 'package:go_router/go_router.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:selo/core/services/local_storage_service.dart';
import 'package:selo/shared/widgets/popup_window.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:selo/core/constants/images.dart';

// Константы для размеров и отступов
const _headerHeightFactor = 0.07;
const _profileSectionHeightFactor = 0.35;
const _avatarRadius = 60.0;
const _buttonWidthFactor = 0.9;
const _buttonHeightFactor = 0.07;
const _paddingFactor = 0.02;
const _marginFactor = 0.005;

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Загружаем данные пользователя при входе на страницу
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userNotifierProvider).user;
      if (user != null && user.uid.isNotEmpty) {
        ref.read(userNotifierProvider.notifier).checkUser(user.phoneNumber);
      }
    });
  }

  // Проверка, является ли пользователь анонимным
  bool _isAnonymous(UserState userState) {
    return userState.user?.uid == null ||
        userState.user?.uid == '' ||
        userState.user?.phoneNumber == null ||
        userState.user?.phoneNumber == '';
  }

  // Обработчик нажатия на "Мои объявления" или "Редактировать профиль"
  void _navigateIfAuthenticated(
    BuildContext context,
    String route,
    UserState userState,
  ) {
    if (_isAnonymous(userState)) {
      PopupWindow(
        message: S.of(context).edit_anonymous_window,
        buttonText: S.of(context).login,
        onButtonPressed: () {
          ref.read(userNotifierProvider.notifier).logOut();
          context.push(Routes.authenticationPage);
        },
      ).show(context);
    } else {
      context.push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            expandedHeight: screenSize.height * _headerHeightFactor,
            actions: [
              GestureDetector(
                onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
                child: Container(
                  width: screenSize.width * 0.3,
                  height: screenSize.height * _headerHeightFactor,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * _paddingFactor,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface,
                    borderRadius: ResponsiveRadius.screenBased(context),
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
                        color:
                            theme.brightness == Brightness.light
                                ? Colors.orangeAccent
                                : Colors.deepPurpleAccent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          theme.brightness == Brightness.light
                              ? S.of(context).theme_light
                              : S.of(context).theme_dark,
                          overflow: TextOverflow.ellipsis,
                          style: contrastM(context),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
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
                    horizontal: screenSize.width * 0.04,
                  ),
                  width: screenSize.width * 0.25,
                  height: screenSize.height * _headerHeightFactor,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface,
                    borderRadius: ResponsiveRadius.screenBased(context),
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
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              height: screenSize.height * _profileSectionHeightFactor,
              color: colorScheme.surface,
              child: Center(
                child:
                    userState.isLoading
                        ? const CircularProgressIndicator()
                        : userState.user == null
                        ? Text(
                          S.of(context).my_ads_empty,
                          style: contrastL(context),
                        )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ProfileAvatar(
                              imageUrl: userState.user?.profileImage,
                              radius: _avatarRadius,
                              backgroundColor: colorScheme.inversePrimary,
                              iconColor: colorScheme.onPrimary,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  userState.user!.name.isNotEmpty
                                      ? userState.user!.name
                                      : S.of(context).anonymous_user,
                                  style: contrastL(context),
                                ),
                                if (userState.user!.lastName.isNotEmpty) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    userState.user!.lastName,
                                    style: contrastL(context),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              userState.user!.phoneNumber.isNotEmpty
                                  ? userState.user!.phoneNumber
                                  : S.of(context).no_phone_number,
                              style: contrastM(context),
                            ),
                            if (userState.error != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                userState.error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                            SizedBox(height: screenSize.height * 0.01),
                            GestureDetector(
                              onTap:
                                  () => _navigateIfAuthenticated(
                                    context,
                                    Routes.nestededitProfilePage,
                                    userState,
                                  ),
                              child: Text(
                                S.of(context).edit_profile,
                                style: contrastBoldM(context),
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                GestureDetector(
                  onTap:
                      () => _navigateIfAuthenticated(
                        context,
                        Routes.nestedMyAdsPage,
                        userState,
                      ),
                  child: ProfileButton(
                    icon: Images.myAdvertSvg,
                    label: S.of(context).my_ads,
                    screenSize: screenSize,
                    colorScheme: colorScheme,
                  ),
                ),
                GestureDetector(
                  onTap:
                      () => launchUrl(
                        Uri.parse(
                          'https://sites.google.com/view/privacypolicyselo/%D0%B3%D0%BB%D0%B0%D0%B2%D0%BD%D0%B0%D1%8F-%D1%81%D1%82%D1%80%D0%B0%D0%BD%D0%B8%D1%86%D0%B0',
                        ),
                      ),
                  child: ProfileButton(
                    icon: Images.publicSvg,
                    label: S.of(context).terms_and_conditions,
                    screenSize: screenSize,
                    colorScheme: colorScheme,
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(S.of(context).logged_out)),
                      );
                    }
                  },
                  child: ProfileButton(
                    icon: Images.leaveSvg,
                    label: S.of(context).logout,
                    screenSize: screenSize,
                    colorScheme: colorScheme,
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

// Виджет для кнопок профиля
class ProfileButton extends StatelessWidget {
  final String icon;
  final String label;
  final Size screenSize;
  final ColorScheme colorScheme;

  const ProfileButton({
    super.key,
    required this.icon,
    required this.label,
    required this.screenSize,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenSize.width * _buttonWidthFactor,
      height: screenSize.height * _buttonHeightFactor,
      margin: EdgeInsets.symmetric(vertical: screenSize.height * _marginFactor),
      decoration: BoxDecoration(
        color: colorScheme.onSurface,
        borderRadius: ResponsiveRadius.screenBased(context),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * _paddingFactor,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            icon,
            width: screenSize.width * 0.05,
            height: screenSize.height * 0.05,
          ),
          SizedBox(width: screenSize.width * _paddingFactor),
          Text(label, style: contrastBoldM(context)),
        ],
      ),
    );
  }
}

// Виджет для аватара (перенесён из EditProfilePage)
class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Color backgroundColor;
  final Color iconColor;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    required this.radius,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage:
          imageUrl != null && imageUrl!.isNotEmpty
              ? NetworkImage(imageUrl!)
              : null,
      child:
          imageUrl == null || imageUrl!.isEmpty
              ? Icon(Icons.person, size: radius, color: iconColor)
              : null,
    );
  }
}
