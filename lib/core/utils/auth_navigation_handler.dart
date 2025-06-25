import 'package:flutter/material.dart';
import 'package:selo/features/authentication/presentation/provider/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/shared/widgets/popup_window.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:go_router/go_router.dart';

class AuthNavigationHandler {
  bool isAnonymous(UserState userState) {
    return userState.user == null ||
        userState.user!.uid.isEmpty ||
        userState.user!.phoneNumber.isEmpty;
  }

  void navigateIfAuthenticated(
    BuildContext context,
    String route,
    UserState userState,
    WidgetRef ref,
  ) {
    if (isAnonymous(userState)) {
      PopupWindow(
        message: S.of(context).edit_anonymous_window,
        buttonText: S.of(context).login,
        onButtonPressed: () {
          ref.read(userNotifierProvider.notifier).logOut();
          context.push(Routes.authenticationPage);
        },
      ).show(context);
    } else {
      context.go(route);
    }
  }
}
