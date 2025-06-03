import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:selo/features/bottom_navigation/components/layout_scaffold.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:selo/features/add/presentation/features.dart';
import 'package:selo/features/authentication/presentation/features.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/features/favourites/presentation/features.dart';
import 'package:selo/features/home/presentation/features.dart';
import 'package:selo/features/profile/presentation/features.dart';
import 'package:selo/features/add/presentation/pages/create_advert_page.dart';
import 'package:selo/features/authentication/presentation/pages/phone_page.dart';
import 'package:selo/features/authentication/presentation/pages/otp_page.dart';
import 'package:selo/features/authentication/data/models/user_model.dart';

// Ключ для root-навигации
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.authenticationPage,
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
            ),
          ],
        ),
      ],
    ),
  ],
);
