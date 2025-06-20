import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/shared/models/user_model.dart';
import 'package:selo/features/authentication/presentation/provider/index.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/shared/widgets/custom_text_field.dart';
import 'package:flutter/services.dart';
import 'package:selo/core/di/di.dart';
import 'package:talker_flutter/talker_flutter.dart';

class PhonePage extends ConsumerStatefulWidget {
  const PhonePage({super.key});

  @override
  ConsumerState<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends ConsumerState<PhonePage> {
  final phoneController = TextEditingController();
  bool isPhoneValid = false;
  bool? isLogin;
  String completePhoneNumber = '';
  final nameController = TextEditingController();

  Talker get _talker => di<Talker>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final radius = ResponsiveRadius.screenBased(context);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: colorScheme.surface,
            iconTheme: IconThemeData(color: colorScheme.inversePrimary),
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: screenSize.height * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).your_phone_number,
                        style: contrastBoldL(context),
                      ),
                      SizedBox(height: screenSize.height * 0.015),
                      IntlPhoneField(
                        keyboardType: const TextInputType.numberWithOptions(),
                        dropdownTextStyle: contrastM(context),
                        cursorColor: colorScheme.primary,
                        style: contrastM(context),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1,
                              color: colorScheme.primary,
                            ),
                            borderRadius: radius,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1,
                              color: colorScheme.primary,
                            ),
                            borderRadius: radius,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1,
                              color: colorScheme.primary,
                            ),
                            borderRadius: radius,
                          ),
                          filled: true,
                          fillColor: colorScheme.onSurface,
                        ),
                        invalidNumberMessage:
                            S.of(context).phone_number_invalid,
                        initialCountryCode: 'KZ',
                        controller: phoneController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) async {
                          setState(() {
                            // Format phone number to E.164
                            completePhoneNumber = value.completeNumber
                                .replaceAll(RegExp(r'\s+|\(|\)|-'), '');
                            final number = completePhoneNumber.replaceAll(
                              RegExp(r'\D'),
                              '',
                            );
                            isPhoneValid = number.length >= 11;
                            _talker.debug(
                              '📞 Formatted phone number: $completePhoneNumber',
                            );

                            if (isPhoneValid) {
                              checkUserStatus();
                            }
                          });
                        },
                      ),
                      if (isLogin == false)
                        CustomTextField(
                          controller: nameController,
                          theme: colorScheme,
                          style: contrastM(context),
                          hintText: S.of(context).name_hint,
                        ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      if (isLogin == true) {
                        _talker.info('👆 Login button tapped');
                        loginUser();
                      } else if (isLogin == false &&
                          nameController.text.isNotEmpty) {
                        _talker.info('👆 Signup button tapped');
                        signupUser();
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: screenSize.height * 0.07,
                      decoration: BoxDecoration(
                        color:
                            isLogin != null
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                        borderRadius: radius,
                      ),
                      child: Center(
                        child: Text(
                          S.of(context).continue_,
                          style: overGreenBoldM(context).copyWith(
                            color:
                                isLogin != null
                                    ? colorScheme.onPrimary
                                    : colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> checkUserStatus() async {
    try {
      final formattedNumber = completePhoneNumber.trim();
      _talker.info('📞 Checking user with formatted number: $formattedNumber');

      final result = await ref
          .read(checkUserUseCaseProvider)
          .call(params: PhoneNumberModel(phoneNumber: formattedNumber));
      _talker.debug('📱 CheckUser result: $result');

      if (result is DataSuccess<bool>) {
        _talker.info('✅ DataSuccess: ${result.data}');
        setState(() {
          if (result.data == true) {
            _talker.info('👤 User exists');
            isLogin = true;
          } else {
            _talker.info('❌ User does not exist');
            isLogin = false;
          }
        });
      } else {
        _talker.error('❌ Error in checkUser: $result');
      }
    } catch (e, stack) {
      _talker.error('💥 Exception in checkUser', e, stack);
    }
  }

  Future<void> loginUser() async {
    try {
      _talker.info(
        '🔐 Starting login process with number: $completePhoneNumber',
      );
      final formattedNumber = completePhoneNumber.trim();
      _talker.debug('📞 Login with formatted number: $formattedNumber');

      final result = await ref
          .read(logInUseCaseProvider)
          .call(params: PhoneNumberModel(phoneNumber: formattedNumber));

      _talker.debug('🔑 Login result: $result');
      if (result is DataSuccess<AuthStatusModel>) {
        _talker.info('✅ Login successful: ${result.data}');
        if (mounted) {
          context.push(Routes.otpPage, extra: result.data);
        }
      } else {
        _talker.error('❌ Login failed: $result');
      }
    } catch (e, stack) {
      _talker.error('💥 Exception in login', e, stack);
    }
  }

  Future<void> signupUser() async {
    try {
      _talker.info('📝 Starting signup process');
      _talker.debug('📞 Phone: $completePhoneNumber');
      _talker.debug('👤 Name: ${nameController.text}');

      if (nameController.text.trim().isEmpty) {
        _talker.error('❌ Name is empty');
        // TODO: Show error to user
        return;
      }

      final formattedNumber = completePhoneNumber.trim();
      if (!formattedNumber.startsWith('+')) {
        _talker.error('❌ Invalid phone number format');
        // TODO: Show error to user
        return;
      }

      final result = await ref
          .read(signUpUseCaseProvider)
          .call(
            params: SignUpModel(
              phoneNumber: formattedNumber,
              name: nameController.text.trim(),
            ),
          );

      _talker.debug('📋 Signup result: $result');
      if (result is DataSuccess<AuthStatusModel>) {
        _talker.info('✅ Signup successful: ${result.data}');
        if (mounted) {
          context.push(Routes.otpPage, extra: result.data);
        }
      } else if (result is DataFailed) {
        _talker.error('❌ Signup failed: ${result.error}');
        // TODO: Show error to user
      }
    } catch (e, stack) {
      _talker.error('💥 Exception in signup', e, stack);
      // TODO: Show error to user
    }
  }
}
