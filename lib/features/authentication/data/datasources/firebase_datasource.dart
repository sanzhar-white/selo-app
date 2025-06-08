import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:selo/core/constants/firebase.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/core/services/local_storage_service.dart';
import '../models/user_model.dart';
import '../models/local_user_model.dart';
import 'user_interface.dart';

class FirebaseDatasource implements UserInterface {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseDatasource(this._firestore, this._auth);

  @override
  Future<DataState<AuthStatusModel>> signUp(SignUpModel signUp) async {
    final completer = Completer<DataState<AuthStatusModel>>();
    final now = Timestamp.now();

    try {
      print('🔥 Firebase: Starting signUp for ${signUp.phoneNumber}');
      // Check if user exists in Firestore
      final userSnapshot =
          await _firestore
              .collection(FirebaseCollections.users)
              .where('phoneNumber', isEqualTo: signUp.phoneNumber)
              .get();

      if (userSnapshot.docs.isNotEmpty) {
        print('❌ Firebase: Phone number already registered');
        return DataFailed(
          Exception('Phone number already registered'),
          StackTrace.current,
        );
      }

      print('✅ Firebase: Phone number available, starting verification');
      // Start phone verification
      await _auth.verifyPhoneNumber(
        phoneNumber: signUp.phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            print('✅ Firebase: Auto-verification completed');
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
            print('💾 Firebase: User data saved to Firestore');

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
            print('❌ Firebase: Auto-verification sign-in error: $e');
            completer.complete(DataFailed(Exception(e), st));
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print('❌ Firebase: Verification failed: ${e.message}');
          completer.complete(DataFailed(e, StackTrace.current));
        },
        codeSent: (String verificationId, int? resendToken) {
          print('📤 Firebase: SMS code sent, verification ID: $verificationId');
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
          print('⌛ Firebase: Auto-verification timeout');
          if (!completer.isCompleted) {
            completer.complete(
              DataFailed(
                Exception('Auto-verification timeout'),
                StackTrace.current,
              ),
            );
          }
        },
      );

      return await completer.future;
    } catch (e, st) {
      print('❌ Firebase: SignUp error: $e');
      return DataFailed(Exception(e), st);
    }
  }

  @override
  Future<DataState<bool>> checkUser(PhoneNumberModel phoneNumber) async {
    print(
      '🔥 Firebase: checkUser started with number: ${phoneNumber.phoneNumber}',
    );
    final completer = Completer<DataState<bool>>();

    try {
      // Validate phone number format
      final cleanNumber = phoneNumber.phoneNumber.replaceAll(
        RegExp(r'\s+|\(|\)|-'),
        '',
      );
      if (!cleanNumber.startsWith('+')) {
        print('❌ Firebase: Invalid phone number format');
        throw Exception('Phone number must start with +');
      }

      print(
        '🔥 Firebase: Querying Firestore with cleaned number: $cleanNumber',
      );
      final userSnapshot =
          await _firestore
              .collection(FirebaseCollections.users)
              .where('phoneNumber', isEqualTo: cleanNumber)
              .get();

      print(
        '🔥 Firebase: Query completed, docs found: ${userSnapshot.docs.length}',
      );
      completer.complete(DataSuccess(userSnapshot.docs.isNotEmpty));
      return await completer.future;
    } catch (e, st) {
      print('❌ Firebase: checkUser error: $e');
      completer.complete(DataFailed(Exception(e), st));
      return await completer.future;
    }
  }

  @override
  Future<DataState<AuthStatusModel>> logIn(PhoneNumberModel phoneNumber) async {
    final completer = Completer<DataState<AuthStatusModel>>();

    try {
      print('🔐 Firebase: Starting login process');
      final cleanNumber = phoneNumber.phoneNumber.replaceAll(
        RegExp(r'\s+|\(|\)|-'),
        '',
      );
      print('📱 Firebase: Cleaned phone number: $cleanNumber');

      // Check user in Firestore
      print('🔍 Firebase: Checking user in Firestore');
      final userSnapshot =
          await _firestore
              .collection(FirebaseCollections.users)
              .where('phoneNumber', isEqualTo: cleanNumber)
              .get();

      if (userSnapshot.docs.isEmpty) {
        print('❌ Firebase: User not found in Firestore');
        return DataFailed(
          Exception('Phone number is not registered'),
          StackTrace.current,
        );
      }

      print('✅ Firebase: User found in Firestore');
      late UserModel userModel;
      try {
        final userData = userSnapshot.docs.first.data();
        print('🔍 Firebase: User data: $userData');
        userModel = UserModel.fromFirestoreMap(userData);
        print('👤 Firebase: User data parsed: ${userModel.phoneNumber}');
      } catch (e, st) {
        print('❌ Firebase: Failed to parse user data: $e');
        return DataFailed(Exception('Failed to parse user data: $e'), st);
      }

      try {
        // Start phone verification
        print('📲 Firebase: Starting phone verification');
        await _auth.verifyPhoneNumber(
          phoneNumber: cleanNumber,
          timeout: const Duration(seconds: 120),
          forceResendingToken: null,
          verificationCompleted: (PhoneAuthCredential credential) async {
            print('✅ Firebase: Auto-verification completed');
            try {
              final userCredential = await _auth.signInWithCredential(
                credential,
              );
              if (userCredential.user != null) {
                print('🔓 Firebase: Auto-sign in successful');
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
                print('❌ Firebase: Auto-sign in failed - no user returned');
                completer.complete(
                  DataFailed(
                    Exception('Authentication failed'),
                    StackTrace.current,
                  ),
                );
              }
            } catch (e, st) {
              print('❌ Firebase: Auto-sign in error: $e');
              completer.complete(DataFailed(Exception(e), st));
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            print(
              '❌ Firebase: Verification failed: ${e.message}, Code: ${e.code}',
            );
            completer.complete(DataFailed(e, StackTrace.current));
          },
          codeSent: (String verificationId, int? resendToken) {
            print(
              '📤 Firebase: SMS code sent, verification ID: $verificationId',
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
            print('⌛ Firebase: Auto-retrieval timeout');
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
        print('❌ Firebase: Phone verification error: $e');
        return DataFailed(Exception(e), st);
      }
    } catch (e, st) {
      print('❌ Firebase: Login process error: $e');
      return DataFailed(Exception(e), st);
    }
  }

  @override
  Future<DataState<bool>> anonymousLogIn() async {
    final now = Timestamp.now();
    try {
      print('🔥 Firebase: Starting anonymous login');
      final savedUser = LocalStorageService.getUser();
      if (savedUser != null) {
        try {
          await _auth.signInAnonymously();
          print('✅ Firebase: Reused anonymous account');
          return const DataSuccess(true);
        } catch (e) {
          print('❌ Firebase: Failed to reuse anonymous account: $e');
        }
      }

      print('🔥 Firebase: Creating new anonymous account');
      final userCredential = await _auth.signInAnonymously();
      if (userCredential.user == null) {
        print('❌ Firebase: Failed to create anonymous user');
        return DataFailed(
          Exception('Failed to create anonymous user'),
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
        print(
          '💾 Firebase: Anonymous user saved to Firestore and local storage',
        );
      }

      return const DataSuccess(true);
    } catch (e, st) {
      print('❌ Firebase: anonymousLogIn error: $e');
      return DataFailed(Exception(e), st);
    }
  }

  @override
  Future<DataState<bool>> signInWithCredential(
    SignInWithCredentialModel signInWithCredential,
  ) async {
    try {
      print('🔐 Firebase: Starting credential verification');
      if (signInWithCredential.verificationId.isEmpty) {
        print('❌ Firebase: Empty verification ID');
        return DataFailed(
          Exception('Invalid verification ID'),
          StackTrace.current,
        );
      }

      if (signInWithCredential.smsCode.isEmpty ||
          signInWithCredential.smsCode.length != 6) {
        print(
          '❌ Firebase: Invalid SMS code length: ${signInWithCredential.smsCode.length}',
        );
        return DataFailed(
          Exception('Invalid SMS code format'),
          StackTrace.current,
        );
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: signInWithCredential.verificationId,
        smsCode: signInWithCredential.smsCode,
      );

      print('🔑 Firebase: Created phone auth credential');
      final userCredential = await _auth.signInWithCredential(credential);
      print('👤 Firebase: Sign in attempt completed');

      if (userCredential.user == null) {
        print('❌ Firebase: No user returned after sign in');
        return DataFailed(
          Exception('Authentication failed - no user returned'),
          StackTrace.current,
        );
      }

      final userModel = signInWithCredential.user.copyWith(
        uid: userCredential.user!.uid,
        deletedAt: null,
      );

      print(
        '📝 Firebase: Updating Firestore document for user: ${userModel.uid}',
      );
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(userModel.uid)
          .set(userModel.toFirestoreMap());

      print('💾 Firebase: Saving to local storage');
      await LocalStorageService.saveUser(
        LocalUserModel.fromUserModel(userModel),
      );

      print('✅ Firebase: Authentication process completed successfully');
      return const DataSuccess(true);
    } catch (e, st) {
      print('❌ Firebase: signInWithCredential error: $e');
      return DataFailed(Exception(e), st);
    }
  }

  @override
  Future<DataState<bool>> logOut() async {
    try {
      print('🔥 Firebase: Starting logout');
      await _auth.signOut();
      await LocalStorageService.clearAll();
      print('✅ Firebase: Logout successful');
      return const DataSuccess(true);
    } catch (e, st) {
      print('❌ Firebase: logOut error: $e');
      return DataFailed(Exception(e), st);
    }
  }
}
