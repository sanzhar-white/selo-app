import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/features/authentication/presentation/provider/index.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:selo/shared/models/user_model.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:flutter/services.dart';
import 'package:selo/core/di/di.dart';
import 'package:talker_flutter/talker_flutter.dart';

class OTPPage extends ConsumerStatefulWidget {
  final AuthStatusModel? authStatus;

  const OTPPage({super.key, this.authStatus});

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
  bool _mounted = true;

  Talker get _talker => di<Talker>();

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
        if (_mounted) {
          setState(() {});
        }
      } else {
        if (_mounted) {
          setState(() {
            _start--;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _mounted = false;

    if (timer.isActive) {
      timer.cancel();
    }

    codeController.dispose();
    super.dispose();
  }

  Future<void> verifyOTP() async {
    if (!_mounted || !isActive || widget.authStatus == null) {
      _talker.error(
        '❌ Cannot verify OTP: ${!isActive
            ? 'inactive'
            : !_mounted
            ? 'disposed'
            : 'no auth status'}',
      );
      return;
    }

    _capturedCode = codeController.text;
    if (_capturedCode == null || _capturedCode!.isEmpty) {
      _talker.error('❌ No verification code entered');
      return;
    }

    if (!_mounted) return;
    setState(() => isLoading = true);

    try {
      _talker.info('🔐 Starting OTP verification');
      _talker.debug('📝 Verification ID: ${widget.authStatus!.value}');
      _talker.debug('📱 SMS Code: $_capturedCode');

      if (!_mounted) return;
      final result = await ref
          .read(signInWithCredentialUseCaseProvider)
          .call(
            params: SignInWithCredentialModel(
              verificationId: widget.authStatus!.value,
              smsCode: _capturedCode!,
              user: widget.authStatus!.user,
            ),
          );

      if (!_mounted) return;

      if (result is DataSuccess<bool>) {
        final success = result.data;
        _talker.info('✅ OTP verification result: $success');
        if (success! && _mounted) {
          context.go(Routes.homePage);
        } else {
          if (_mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Verification failed - please check the code and try again',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          _talker.error('❌ OTP verification failed: success was false');
        }
      } else if (result is DataFailed<bool>) {
        final error = result.error.toString();
        _talker.error('❌ OTP verification failed with error: $error');
        if (_mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Verification error: ${error.contains('invalid-verification-code') ? 'Invalid code entered' : error}',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e, stack) {
      _talker.error('💥 Exception in OTP verification', e, stack);
      if (_mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during verification: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      _capturedCode = null;
      if (_mounted) {
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
                shape: RoundedRectangleBorder(borderRadius: radius),
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
