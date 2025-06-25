import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:selo/features/bottom_navigation/components/layout_scaffold.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:selo/features/add/presentation/features.dart';
import 'package:selo/features/authentication/presentation/features.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/features/favourites/presentation/features.dart';
import 'package:selo/features/home/presentation/features.dart';
import 'package:selo/features/home/presentation/pages/advert_detail_page.dart';
import 'package:selo/features/home/presentation/pages/filter_page.dart';
import 'package:selo/features/profile/presentation/features.dart';
import 'package:selo/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:selo/features/profile/presentation/pages/my_ads_page.dart';
import 'package:selo/features/add/presentation/pages/create_advert_page.dart';
import 'package:selo/features/authentication/presentation/pages/phone_page.dart';
import 'package:selo/features/authentication/presentation/pages/otp_page.dart';
import 'package:selo/shared/models/user_model.dart';
import 'package:selo/features/init/presentation/pages/init_page.dart';
import 'package:selo/shared/models/advert_model.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

Widget defaultTransitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final fadeAnimation = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutExpo,
  );
  return FadeTransition(
    opacity: Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0, 0.65, curve: Curves.easeInOut),
      ),
    ),
    child: ScaleTransition(
      scale: Tween<double>(begin: 0.96, end: 1).animate(fadeAnimation),
      child: child,
    ),
  );
}

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.initPage,
  debugLogDiagnostics: true,
  redirect: (context, state) {
    if (state.uri.toString().contains('firebaseauth')) {
      return Routes.authenticationPage;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: Routes.initPage,
      pageBuilder:
          (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const InitPage(),
            transitionDuration: const Duration(milliseconds: 1000),
            reverseTransitionDuration: const Duration(milliseconds: 1000),
            transitionsBuilder: defaultTransitionBuilder,
          ),
    ),
    GoRoute(
      path: Routes.authenticationPage,
      pageBuilder:
          (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const AuthenticationFeature(),
            transitionsBuilder: defaultTransitionBuilder,
          ),
    ),
    GoRoute(
      path: Routes.phonePage,
      pageBuilder:
          (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const PhonePage(),
            transitionsBuilder: defaultTransitionBuilder,
          ),
    ),
    GoRoute(
      path: Routes.otpPage,
      pageBuilder:
          (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: OTPPage(authStatus: state.extra as AuthStatusModel?),
            transitionsBuilder: defaultTransitionBuilder,
          ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return LayoutScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.homePage,
              pageBuilder:
                  (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const HomeFeature(),
                    transitionsBuilder: defaultTransitionBuilder,
                  ),
              routes: [
                GoRoute(
                  path: Routes.advertDetailsPage,
                  pageBuilder:
                      (context, state) => CustomTransitionPage(
                        key: state.pageKey,
                        child: AdvertDetailsPage(
                          advert: state.extra! as AdvertModel,
                        ),
                        transitionsBuilder: defaultTransitionBuilder,
                      ),
                ),
                GoRoute(
                  path: Routes.filterPage,
                  pageBuilder:
                      (context, state) => CustomTransitionPage(
                        key: state.pageKey,
                        child: FilterPage(
                          searchQueryText:
                              (state.extra!
                                      as Map<String, dynamic>)['searchQuery']
                                  as String,
                          initialCategoryId:
                              (state.extra!
                                      as Map<
                                        String,
                                        dynamic
                                      >)['initialCategoryId']
                                  as int?,
                        ),
                        transitionsBuilder: defaultTransitionBuilder,
                      ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.favouritesPage,
              pageBuilder:
                  (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const FavouritesFeature(),
                    transitionsBuilder: defaultTransitionBuilder,
                  ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.addPage,
              pageBuilder:
                  (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const AddFeature(),
                    transitionsBuilder: defaultTransitionBuilder,
                  ),
              routes: [
                GoRoute(
                  path: Routes.createAdvertPage,
                  pageBuilder:
                      (context, state) => CustomTransitionPage(
                        key: state.pageKey,
                        child: CreateAdvertPage(
                          category: state.extra! as AdCategory,
                        ),
                        transitionsBuilder: defaultTransitionBuilder,
                      ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.profilePage,
              pageBuilder:
                  (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const ProfileFeature(),
                    transitionsBuilder: defaultTransitionBuilder,
                  ),
              routes: [
                GoRoute(
                  path: Routes.editProfilePage,
                  pageBuilder:
                      (context, state) => CustomTransitionPage(
                        key: state.pageKey,
                        child: const EditProfilePage(),
                        transitionsBuilder: defaultTransitionBuilder,
                      ),
                ),
                GoRoute(
                  path: Routes.myAdsPage,
                  pageBuilder:
                      (context, state) => CustomTransitionPage(
                        key: state.pageKey,
                        child: const MyAdsPage(),
                        transitionsBuilder: defaultTransitionBuilder,
                      ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
