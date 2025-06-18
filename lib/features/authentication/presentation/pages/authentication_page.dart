import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:selo/features/authentication/presentation/provider/index.dart';
import 'package:selo/generated/l10n.dart';

class AuthenticationPage extends ConsumerStatefulWidget {
  const AuthenticationPage({super.key});

  @override
  ConsumerState<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends ConsumerState<AuthenticationPage> {
  bool _isLoading = false;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isVisible = true);
    });
  }

  Future<void> _anonymousLogin() async {
    setState(() => _isLoading = true);
    final result =
        await ref.read(userNotifierProvider.notifier).anonymousLogIn();
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result) {
      context.push(Routes.homePage);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to log in anonymously')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final radius = ResponsiveRadius.screenBased(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/authentication_page.png',
              fit: BoxFit.contain,
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    colorScheme.background.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          // Content
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
                  // Header
                  AnimatedOpacity(
                    opacity: _isVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).welcome,
                          style: contrastBoldL(context),
                        ),
                        SizedBox(height: screenSize.height * 0.01),
                        Text(S.of(context).greeting, style: contrastM(context)),
                      ],
                    ),
                  ),
                  // Buttons
                  AnimatedOpacity(
                    opacity: _isVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Column(
                      children: [
                        Semantics(
                          label: S.of(context).signin,
                          child: ElevatedButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : () => context.push(Routes.phonePage),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              minimumSize: Size(
                                double.infinity,
                                screenSize.height * 0.07,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: radius,
                              ),
                            ),
                            child: Text(
                              S.of(context).signin,
                              style: overGreenBoldM(
                                context,
                              ).copyWith(height: 1.2),
                            ),
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        Semantics(
                          label: S.of(context).withoutregistor,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _anonymousLogin,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: colorScheme.surface,
                              foregroundColor: colorScheme.primary,
                              minimumSize: Size(
                                double.infinity,
                                screenSize.height * 0.07,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: radius,
                              ),
                              side: BorderSide(color: colorScheme.primary),
                            ),
                            child:
                                _isLoading
                                    ? CircularProgressIndicator(
                                      color: colorScheme.primary,
                                      strokeWidth: 2,
                                    )
                                    : Text(
                                      S.of(context).withoutregistor,
                                      style: greenBoldM(
                                        context,
                                      ).copyWith(height: 1.2),
                                    ),
                          ),
                        ),
                      ],
                    ),
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
