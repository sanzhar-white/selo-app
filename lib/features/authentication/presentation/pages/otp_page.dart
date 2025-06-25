import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/features/authentication/presentation/provider/index.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/shared/models/user_model.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:flutter/services.dart';
import 'package:selo/core/di/di.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:selo/core/constants/error_message.dart';

class OTPPage extends ConsumerStatefulWidget {
  const OTPPage({super.key, this.authStatus});
  final AuthStatusModel? authStatus;

  @override
  ConsumerState<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends ConsumerState<OTPPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController codeController = TextEditingController();
  String? _capturedCode;

  late Timer timer;
  int _start = 45;

  bool isActive = false;
  bool isLoading = false;

  late AuthStatusModel? _authStatus;

  Talker get _talker => di<Talker>();

  @override
  void initState() {
    super.initState();
    _authStatus = widget.authStatus;
    startTimer();
  }

  void startTimer() {
    _start = 45;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    codeController.dispose();
    super.dispose();
  }

  Future<void> resendCode() async {
    if (isLoading || _authStatus == null) return;
    setState(() => isLoading = true);
    try {
      final phoneNumber = _authStatus!.user.phoneNumber;
      _talker.info('🔄 Resending code to $phoneNumber');
      final result = await ref
          .read(logInUseCaseProvider)
          .call(params: PhoneNumberModel(phoneNumber: phoneNumber));
      if (!mounted) return;
      if (result is DataSuccess<AuthStatusModel>) {
        _talker.info('✅ Resend code success: ${result.data}');
        setState(() {
          _authStatus = result.data;
          _start = 45;
        });
        startTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)!.code_resent_success,
              style: contrastBoldM(context),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (result is DataFailed<AuthStatusModel>) {
        _talker.error('❌ Resend code failed: ${result.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${S.of(context)!.resend_code_error}: ${result.error}',
              style: contrastBoldM(context),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e, st) {
      _talker.error('❌ Exception in resendCode', e, st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${S.of(context)!.resend_code_error}: $e',
              style: contrastBoldM(context),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> verifyOTP() async {
    if (!mounted || !isActive || _authStatus == null) {
      _talker.error(
        '${ErrorMessages.cannotVerifyOTP}: ${!isActive
            ? 'inactive'
            : !mounted
            ? 'disposed'
            : 'no auth status'}',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)!.otp_empty_error,
            style: contrastBoldM(context),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    _capturedCode = codeController.text;
    if (_capturedCode == null || _capturedCode!.isEmpty) {
      _talker.error(ErrorMessages.noVerificationCodeEntered);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)!.otp_empty_error,
            style: contrastBoldM(context),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      _talker.info('🔐 Starting OTP verification');
      _talker.debug('📝 Verification ID: ${_authStatus!.value}');
      _talker.debug('📱 SMS Code: $_capturedCode');

      if (!mounted) return;
      final result = await ref
          .read(signInWithCredentialUseCaseProvider)
          .call(
            params: SignInWithCredentialModel(
              verificationId: _authStatus!.value,
              smsCode: _capturedCode!,
              user: _authStatus!.user,
            ),
          );

      if (!mounted) return;

      if (result is DataSuccess<bool>) {
        final success = result.data;
        _talker.info('✅ OTP verification result: $success');
        if (success! && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S.of(context)!.otp_verification_success,
                style: contrastBoldM(context),
              ),
              backgroundColor: Colors.green,
            ),
          );
          context.go(Routes.homePage);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  S.of(context)!.otp_verification_failed,
                  style: contrastBoldM(context),
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          _talker.error(ErrorMessages.otpVerificationFailedSuccessFalse);
        }
      } else if (result is DataFailed<bool>) {
        final error = result.error.toString();
        _talker.error(
          '${ErrorMessages.otpVerificationFailedWithError}: $error',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${S.of(context)!.otp_verification_failed}: ${error.contains('invalid-verification-code') ? S.of(context)!.invalid_code_entered : error}',
                style: contrastBoldM(context),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e, stack) {
      _talker.error(ErrorMessages.exceptionInOtpVerification, e, stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${S.of(context)!.otp_verification_failed}: $e',
              style: contrastBoldM(context),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      _capturedCode = null;
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final radius = ResponsiveRadius.screenBased(context);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              S.of(context)!.enter_verification_code,
              style: contrastL(context),
            ),
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
                    S.of(context)!.enter_code_sent_to_your_phone,
                    style: contrastM(context),
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                  Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 30,
                      ),
                      child: PinCodeTextField(
                        appContext: context,
                        length: 6,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: radius,
                          fieldHeight: 50,
                          fieldWidth: 40,
                          activeFillColor: colorScheme.primary,
                          inactiveFillColor: colorScheme.onSurface,
                          selectedFillColor: colorScheme.onSurface,
                          activeColor: colorScheme.primary,
                          inactiveColor: colorScheme.primary,
                          selectedColor: colorScheme.primary,
                        ),
                        animationDuration: const Duration(milliseconds: 300),
                        backgroundColor: Colors.transparent,
                        enableActiveFill: true,
                        controller: codeController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
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
                        onTap: _start == 0 && !isLoading ? resendCode : null,
                        child: Text(
                          S.of(context)!.resend_code,
                          style: TextStyle(
                            color:
                                _start == 0 && !isLoading
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                            decoration:
                                _start == 0 && !isLoading
                                    ? TextDecoration.underline
                                    : null,
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
                shape: RoundedRectangleBorder(borderRadius: radius),
              ),
              onPressed: isActive ? verifyOTP : null,
              child: Text(
                S.of(context)!.verify,
                style: overGreenBoldM(context).copyWith(
                  color: isActive ? colorScheme.onPrimary : colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
        if (isLoading)
          const ColoredBox(
            color: Colors.black54,
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
