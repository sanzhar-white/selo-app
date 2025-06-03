import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:selo/features/authentication/data/models/user_model.dart';
import 'package:selo/features/authentication/presentation/provider/authentication_provider.dart';

class AuthenticationPage extends ConsumerStatefulWidget {
  const AuthenticationPage({super.key});

  @override
  ConsumerState<AuthenticationPage> createState() => _AuthenticatioPageState();
}

class _AuthenticatioPageState extends ConsumerState<AuthenticationPage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 📷 Задний фон
          Positioned.fill(
            child: Image.asset(
              'assets/images/authentication_page.png',
              fit: BoxFit.contain,
            ),
          ),
          // 📦 Контент
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: screenSize.height * 0.05,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🔼 Верхний текст
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.05,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome to Selo!', style: contrastBoldL(context)),
                        SizedBox(height: screenSize.height * 0.01),
                        Text(
                          'Complete a quick registration\nand find clients today',
                          style: contrastM(context),
                        ),
                      ],
                    ),
                  ),

                  // 🔽 Кнопки
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.push(Routes.phonePage);
                        },
                        child: Container(
                          width: double.infinity,
                          height: screenSize.height * 0.07,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: ResponsiveRadius.screenBased(context),
                          ),
                          child: Center(
                            child: Text(
                              'Sign in',
                              style: overGreenBoldM(context),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.01),
                      GestureDetector(
                        onTap: () {
                          ref.read(anonymousLogInUseCaseProvider).call();
                          context.push(Routes.homePage);
                        },
                        child: Container(
                          width: double.infinity,
                          height: screenSize.height * 0.07,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface,
                            borderRadius: ResponsiveRadius.screenBased(context),
                          ),
                          child: Center(
                            child: Text(
                              'Continue without registration',
                              style: greenBoldM(context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
