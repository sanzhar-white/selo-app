import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:selo/core/constants/error_message.dart';
import 'package:selo/core/constants/firebase.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/core/services/local_storage_service.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/local_user_model.dart';
import 'user_interface.dart';

class FirebaseDatasource implements UserInterface {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Talker _talker;

  FirebaseDatasource(this._firestore, this._auth, this._talker);

  @override
  Future<DataState<AuthStatusModel>> signUp(SignUpModel signUp) async {
    final completer = Completer<DataState<AuthStatusModel>>();
    final now = Timestamp.now();

    try {
      _talker.info('🔄 Starting signUp for ${signUp.phoneNumber}');

      final userSnapshot =
          await _firestore
              .collection(FirebaseCollections.users)
              .where('phoneNumber', isEqualTo: signUp.phoneNumber)
              .get();

      if (userSnapshot.docs.isNotEmpty) {
        _talker.error(ErrorMessages.phoneNumberAlreadyRegistered);
        return DataFailed(
          Exception(ErrorMessages.phoneNumberAlreadyRegistered),
          StackTrace.current,
        );
      }

      _talker.info('✅ Phone number available, starting verification');

      await _auth.verifyPhoneNumber(
        phoneNumber: signUp.phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            _talker.info('✅ Auto-verification completed');
            await _auth.signInWithCredential(credential);
            final userModel = UserModel(
              uid: _auth.currentUser?.uid ?? '',
              phoneNumber: signUp.phoneNumber,
              name: signUp.name,
              lastName: signUp.lastName,
              likes: [],
              region: 0,
              district: 0,
              profileImage: '',
              createdAt: now,
              updatedAt: now,
              deletedAt: null,
            );
            await _firestore
                .collection(FirebaseCollections.users)
                .doc(userModel.uid)
                .set(userModel.toFirestoreMap());
            _talker.info('💾 User data saved to Firestore');

            completer.complete(
              DataSuccess(
                AuthStatusModel(
                  status: true,
                  value: credential.verificationId ?? '',
                  user: userModel,
                ),
              ),
            );
          } catch (e, st) {
            _talker.error(ErrorMessages.autoVerificationSignInError, e, st);
            completer.complete(DataFailed(Exception(e), st));
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          _talker.error(ErrorMessages.verificationFailed, e);
          completer.complete(DataFailed(e, StackTrace.current));
        },
        codeSent: (String verificationId, int? resendToken) {
          _talker.info('📤 SMS code sent, verification ID: $verificationId');
          final userModel = UserModel(
            uid: _auth.currentUser?.uid ?? '',
            phoneNumber: signUp.phoneNumber,
            name: signUp.name,
            lastName: signUp.lastName,
            likes: [],
            region: 0,
            district: 0,
            profileImage: '',
            createdAt: now,
            updatedAt: now,
            deletedAt: null,
          );
          completer.complete(
            DataSuccess(
              AuthStatusModel(
                status: true,
                value: verificationId,
                user: userModel,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _talker.warning('⌛ Auto-verification timeout');
          if (!completer.isCompleted) {
            completer.complete(
              DataFailed(
                Exception(ErrorMessages.autoVerificationTimeout),
                StackTrace.current,
              ),
            );
          }
        },
      );

      return await completer.future;
    } catch (e, st) {
      _talker.error(ErrorMessages.signUpError, e, st);
      return DataFailed(Exception(e), st);
    }
  }

  @override
  Future<DataState<bool>> checkUser(PhoneNumberModel phoneNumber) async {
    _talker.info('🔄 Checking user with number: ${phoneNumber.phoneNumber}');
    final completer = Completer<DataState<bool>>();

    try {
      if (phoneNumber.phoneNumber.isEmpty) {
        _talker.info('📱 No phone number provided, treating as guest user');
        completer.complete(DataSuccess(true));
        return await completer.future;
      }

      final cleanNumber = phoneNumber.phoneNumber.replaceAll(
        RegExp(r'\s+|\(|\)|-'),
        '',
      );
      if (!cleanNumber.startsWith('+')) {
        _talker.error(ErrorMessages.invalidPhoneNumberFormat);
        throw Exception(ErrorMessages.phoneNumberMustStartWithPlus);
      }

      _talker.debug('🔍 Querying Firestore with cleaned number: $cleanNumber');
      final userSnapshot =
          await _firestore
              .collection(FirebaseCollections.users)
              .where('phoneNumber', isEqualTo: cleanNumber)
              .get();

      _talker.debug(
        '📋 Query completed, docs found: ${userSnapshot.docs.length}',
      );
      completer.complete(DataSuccess(userSnapshot.docs.isNotEmpty));
      return await completer.future;
    } catch (e, st) {
      _talker.error(ErrorMessages.checkUserError, e, st);
      completer.complete(DataFailed(Exception(e), st));
      return await completer.future;
    }
  }

  @override
  Future<DataState<AuthStatusModel>> logIn(PhoneNumberModel phoneNumber) async {
    final completer = Completer<DataState<AuthStatusModel>>();

    try {
      _talker.info('🔐 Starting login process');
      final cleanNumber = phoneNumber.phoneNumber.replaceAll(
        RegExp(r'\s+|\(|\)|-'),
        '',
      );
      _talker.debug('📱 Cleaned phone number: $cleanNumber');

      _talker.debug('🔍 Checking user in Firestore');
      final userSnapshot =
          await _firestore
              .collection(FirebaseCollections.users)
              .where('phoneNumber', isEqualTo: cleanNumber)
              .get();

      if (userSnapshot.docs.isEmpty) {
        _talker.error(ErrorMessages.userNotFoundInFirestore);
        return DataFailed(
          Exception(ErrorMessages.phoneNumberNotRegistered),
          StackTrace.current,
        );
      }

      _talker.info('✅ User found in Firestore');
      late UserModel userModel;
      try {
        final userData = userSnapshot.docs.first.data();
        _talker.debug('📋 User data retrieved');
        userModel = UserModel.fromFirestoreMap(userData);
        _talker.debug('👤 User data parsed: ${userModel.phoneNumber}');
      } catch (e, st) {
        _talker.error(ErrorMessages.failedToParseUserData, e, st);
        return DataFailed(
          Exception('${ErrorMessages.failedToParseUserData}: $e'),
          st,
        );
      }

      try {
        _talker.info('📲 Starting phone verification');
        await _auth.verifyPhoneNumber(
          phoneNumber: cleanNumber,
          timeout: const Duration(seconds: 120),
          forceResendingToken: null,
          verificationCompleted: (PhoneAuthCredential credential) async {
            _talker.info('✅ Auto-verification completed');
            try {
              final userCredential = await _auth.signInWithCredential(
                credential,
              );
              if (userCredential.user != null) {
                _talker.info('🔓 Auto-sign in successful');
                completer.complete(
                  DataSuccess(
                    AuthStatusModel(
                      status: true,
                      value: credential.verificationId ?? '',
                      user: userModel,
                    ),
                  ),
                );
              } else {
                _talker.error(ErrorMessages.autoSignInFailedNoUserReturned);
                completer.complete(
                  DataFailed(
                    Exception(ErrorMessages.authenticationFailed),
                    StackTrace.current,
                  ),
                );
              }
            } catch (e, st) {
              _talker.error(ErrorMessages.autoSignInError, e, st);
              completer.complete(DataFailed(Exception(e), st));
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            _talker.error('${ErrorMessages.verificationFailed}: ${e.code}', e);
            completer.complete(DataFailed(e, StackTrace.current));
          },
          codeSent: (String verificationId, int? resendToken) {
            _talker.info('📤 SMS code sent, verification ID: $verificationId');
            completer.complete(
              DataSuccess(
                AuthStatusModel(
                  status: true,
                  value: verificationId,
                  user: userModel,
                ),
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _talker.warning('⌛ Auto-retrieval timeout');
            if (!completer.isCompleted) {
              completer.complete(
                DataSuccess(
                  AuthStatusModel(
                    status: true,
                    value: verificationId,
                    user: userModel,
                  ),
                ),
              );
            }
          },
        );

        return await completer.future;
      } catch (e, st) {
        _talker.error(ErrorMessages.phoneVerificationError, e, st);
        return DataFailed(Exception(e), st);
      }
    } catch (e, st) {
      _talker.error(ErrorMessages.loginProcessError, e, st);
      return DataFailed(Exception(e), st);
    }
  }

  @override
  Future<DataState<bool>> anonymousLogIn() async {
    final now = Timestamp.now();
    try {
      _talker.info('🔄 Starting anonymous login');
      final savedUser = LocalStorageService.getUser();
      if (savedUser != null) {
        try {
          await _auth.signInAnonymously();
          _talker.info('✅ Reused anonymous account');
          return const DataSuccess(true);
        } catch (e, st) {
          _talker.error(ErrorMessages.failedToReuseAnonymousAccount, e, st);
        }
      }

      _talker.debug('🔄 Creating new anonymous account');
      final userCredential = await _auth.signInAnonymously();
      if (userCredential.user == null) {
        _talker.error(ErrorMessages.failedToCreateAnonymousUser);
        return DataFailed(
          Exception(ErrorMessages.failedToCreateAnonymousUser),
          StackTrace.current,
        );
      }

      final userModel = UserModel(
        uid: userCredential.user!.uid,
        phoneNumber: '',
        name: 'Anonymous',
        lastName: '',
        likes: [],
        region: 0,
        district: 0,
        profileImage: '',
        createdAt: now,
        updatedAt: now,
        deletedAt: null,
      );

      if (savedUser == null) {
        await _firestore
            .collection(FirebaseCollections.users)
            .doc(userModel.uid)
            .set(userModel.toFirestoreMap());
        await LocalStorageService.saveUser(
          LocalUserModel.fromUserModel(userModel),
        );
        _talker.info('💾 Anonymous user saved to Firestore and local storage');
      }

      return const DataSuccess(true);
    } catch (e, st) {
      _talker.error(ErrorMessages.anonymousLoginError, e, st);
      return DataFailed(Exception(e), st);
    }
  }

  @override
  Future<DataState<bool>> signInWithCredential(
    SignInWithCredentialModel signInWithCredential,
  ) async {
    try {
      _talker.info('🔐 Starting credential verification');
      if (signInWithCredential.verificationId.isEmpty) {
        _talker.error(ErrorMessages.emptyVerificationId);
        return DataFailed(
          Exception(ErrorMessages.invalidVerificationId),
          StackTrace.current,
        );
      }

      if (signInWithCredential.smsCode.isEmpty ||
          signInWithCredential.smsCode.length != 6) {
        _talker.error(
          '${ErrorMessages.invalidSmsCodeLength}: ${signInWithCredential.smsCode.length}',
        );
        return DataFailed(
          Exception(ErrorMessages.invalidSmsCodeFormat),
          StackTrace.current,
        );
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: signInWithCredential.verificationId,
        smsCode: signInWithCredential.smsCode,
      );

      _talker.debug('🔑 Created phone auth credential');
      final userCredential = await _auth.signInWithCredential(credential);
      _talker.debug('👤 Sign in attempt completed');

      if (userCredential.user == null) {
        _talker.error(ErrorMessages.noUserReturnedAfterSignIn);
        return DataFailed(
          Exception(ErrorMessages.authenticationFailedNoUser),
          StackTrace.current,
        );
      }

      final userModel = signInWithCredential.user.copyWith(
        uid: userCredential.user!.uid,
        deletedAt: null,
      );

      _talker.debug(
        '📝 Updating Firestore document for user: ${userModel.uid}',
      );
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(userModel.uid)
          .set(userModel.toFirestoreMap());

      _talker.debug('💾 Saving to local storage');
      await LocalStorageService.saveUser(
        LocalUserModel.fromUserModel(userModel),
      );

      _talker.info('✅ Authentication process completed successfully');
      return const DataSuccess(true);
    } catch (e, st) {
      _talker.error(ErrorMessages.signInWithCredentialError, e, st);
      return DataFailed(Exception(e), st);
    }
  }

  @override
  Future<DataState<bool>> logOut() async {
    try {
      _talker.info('🔄 Starting logout');
      await _auth.signOut();
      await LocalStorageService.clearAll();
      _talker.info('✅ Logout successful');
      return const DataSuccess(true);
    } catch (e, st) {
      _talker.error(ErrorMessages.logoutError, e, st);
      return DataFailed(Exception(e), st);
    }
  }
}
