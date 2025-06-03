import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/features/authentication/presentation/provider/authentication_provider.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:selo/features/authentication/domain/entities/user_entity.dart';
import 'package:selo/features/authentication/data/models/user_model.dart';
import 'package:selo/core/resources/data_state.dart';

class OTPPage extends ConsumerStatefulWidget {
  final AuthStatusModel? authStatus;

  const OTPPage({super.key, this.authStatus});

  @override
  ConsumerState<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends ConsumerState<OTPPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();

  late Timer timer;
  int _start = 45;

  bool isActive = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _start = 45;
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_start == 0) {
        timer.cancel();
        if (mounted) {
          setState(() {});
        }
      } else {
        if (mounted) {
          setState(() {
            _start--;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    if (timer.isActive) {
      timer.cancel();
    }
    controller.dispose();
    super.dispose();
  }

  Future<void> verifyOTP() async {
    if (!isActive || widget.authStatus == null) return;

    setState(() => isLoading = true);

    try {
      final result = await ref
          .read(signInWithCredentialUseCaseProvider)
          .call(
            params: SignInWithCredentialModel(
              verificationId: widget.authStatus!.value,
              smsCode: controller.text,
              user: widget.authStatus!.user,
            ),
          );

      if (result is DataSuccess<bool>) {
        final success = result.data ?? false;
        if (success && mounted) {
          context.go(Routes.homePage);
        }
      } else {
        // TODO: Show error to user
        print('❌ OTP verification failed');
      }
    } catch (e) {
      print('💥 Exception in OTP verification: $e');
      // TODO: Show error to user
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('Enter verification code', style: contrastL(context)),
            backgroundColor: colorScheme.surface,
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: screenSize.height * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter the 6-digit code sent to your phone',
                    style: contrastM(context),
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                  Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 30,
                      ),
                      child: PinCodeTextField(
                        appContext: context,
                        length: 6,
                        obscureText: false,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: ResponsiveRadius.screenBased(context),
                          fieldHeight: 50,
                          fieldWidth: 40,
                          activeFillColor: colorScheme.onSurface,
                          inactiveFillColor: colorScheme.onSurface,
                          selectedFillColor: colorScheme.onSurface,
                          activeColor: colorScheme.primary,
                          inactiveColor: colorScheme.primary,
                          selectedColor: colorScheme.primary,
                        ),
                        animationDuration: const Duration(milliseconds: 300),
                        backgroundColor: Colors.transparent,
                        enableActiveFill: true,
                        controller: controller,
                        onCompleted: (v) {
                          setState(() => isActive = true);
                        },
                        onChanged: (value) {
                          setState(() => isActive = value.length == 6);
                        },
                        beforeTextPaste: (text) {
                          return true;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap:
                            _start == 0
                                ? () {
                                  // Handle resend code
                                  setState(() {
                                    isLoading = true;
                                    _start = 45;
                                  });
                                  startTimer();
                                  // TODO: Implement resend code logic
                                  setState(() => isLoading = false);
                                }
                                : null,
                        child: Text(
                          'Resend Code',
                          style: TextStyle(
                            color:
                                _start == 0
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                            decoration:
                                _start == 0 ? TextDecoration.underline : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$_start',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(
                  screenSize.width * 0.9,
                  screenSize.height * 0.07,
                ),
                backgroundColor:
                    isActive ? colorScheme.primary : colorScheme.onSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: ResponsiveRadius.screenBased(context),
                ),
              ),
              onPressed: isActive ? verifyOTP : null,
              child: Text(
                'Verify',
                style: overGreenBoldM(context).copyWith(
                  color: isActive ? colorScheme.onPrimary : colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black54,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
