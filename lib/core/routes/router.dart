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

// Ключ для root-навигации
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.initPage,
  debugLogDiagnostics: true,
  redirectLimit: 5,
  redirect: (context, state) {
    // Handle Firebase Auth deep links
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
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              final fadeAnimation = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutExpo,
              );

              return FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: const Interval(0.0, 0.65, curve: Curves.easeInOut),
                  ),
                ),
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.85,
                    end: 1.0,
                  ).animate(fadeAnimation),
                  child: child,
                ),
              );
            },
          ),
    ),
    GoRoute(
      path: Routes.authenticationPage,
      pageBuilder:
          (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const AuthenticationFeature(),
            transitionsBuilder:
                (context, animation, _, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
    ),
    GoRoute(
      path: Routes.phonePage,
      pageBuilder:
          (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const PhonePage(),
            transitionsBuilder:
                (context, animation, _, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
    ),
    GoRoute(
      path: Routes.otpPage,
      pageBuilder:
          (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: OTPPage(authStatus: state.extra as AuthStatusModel?),
            transitionsBuilder:
                (context, animation, _, child) =>
                    FadeTransition(opacity: animation, child: child),
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
                    transitionsBuilder:
                        (context, animation, _, child) =>
                            FadeTransition(opacity: animation, child: child),
                  ),
              routes: [
                GoRoute(
                  path: Routes.advertDetailsPage,
                  pageBuilder:
                      (context, state) => CustomTransitionPage(
                        key: state.pageKey,
                        child: AdvertDetailsPage(
                          advert: state.extra as AdvertModel,
                        ),
                        transitionsBuilder:
                            (context, animation, _, child) => FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                      ),
                ),
                GoRoute(
                  path: Routes.filterPage,
                  pageBuilder:
                      (context, state) => CustomTransitionPage(
                        key: state.pageKey,
                        child: FilterPage(
                          searchQueryText:
                              (state.extra
                                      as Map<String, dynamic>)['searchQuery']
                                  as String,
                          initialCategoryId:
                              (state.extra
                                      as Map<
                                        String,
                                        dynamic
                                      >)['initialCategoryId']
                                  as int?,
                        ),

                        transitionsBuilder:
                            (context, animation, _, child) => FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
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
                    transitionsBuilder:
                        (context, animation, _, child) =>
                            FadeTransition(opacity: animation, child: child),
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
                    transitionsBuilder:
                        (context, animation, _, child) =>
                            FadeTransition(opacity: animation, child: child),
                  ),
              routes: [
                GoRoute(
                  path: Routes.createAdvertPage,
                  pageBuilder:
                      (context, state) => CustomTransitionPage(
                        key: state.pageKey,
                        child: CreateAdvertPage(
                          category: state.extra as AdCategory,
                        ),
                        transitionsBuilder:
                            (context, animation, _, child) => FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
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
                    transitionsBuilder:
                        (context, animation, _, child) =>
                            FadeTransition(opacity: animation, child: child),
                  ),
              routes: [
                GoRoute(
                  path: Routes.editProfilePage,
                  pageBuilder:
                      (context, state) => CustomTransitionPage(
                        key: state.pageKey,
                        child: const EditProfilePage(),
                        transitionsBuilder:
                            (context, animation, _, child) => FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                      ),
                ),
                GoRoute(
                  path: Routes.myAdsPage,
                  pageBuilder:
                      (context, state) => CustomTransitionPage(
                        key: state.pageKey,
                        child: const MyAdsPage(),
                        transitionsBuilder:
                            (context, animation, _, child) => FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
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
