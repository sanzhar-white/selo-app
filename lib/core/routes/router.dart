import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:selo/features/bottom_navigation/components/layout_scaffold.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:selo/features/add/presentation/features.dart';
import 'package:selo/features/authentication/presentation/features.dart';
import 'package:selo/features/favourites/presentation/features.dart';
import 'package:selo/features/home/presentation/features.dart';
import 'package:selo/features/profile/presentation/features.dart';

// Ключ для root-навигации
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

// GoRouter с StatefulShellRoute
final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.homePage,
  routes: [
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
                  (context, state) =>
                      const NoTransitionPage(child: const HomeFeature()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.favouritesPage,
              pageBuilder:
                  (context, state) =>
                      const NoTransitionPage(child: const FavouritesFeature()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.addPage,
              pageBuilder:
                  (context, state) =>
                      const NoTransitionPage(child: const AddFeature()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.profilePage,
              pageBuilder:
                  (context, state) =>
                      const NoTransitionPage(child: const ProfileFeature()),
            ),
          ],
        ),
      ],
    ),
  ],
);
