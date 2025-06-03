import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:selo/core/constants/firebase.dart';
import 'package:selo/core/resources/data_state.dart';
import '../models/user_model.dart';
import 'user_interface.dart';

class FirebaseDatasource implements UserInterface {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseDatasource(this._firestore, this._auth);

  @override
  Future<DataState<AuthStatusModel>> signUp(SignUpModel signUp) async {
    final completer = Completer<DataState<AuthStatusModel>>();

    try {
      // Проверка: есть ли пользователь в Firestore
      final userSnapshot =
          await _firestore
              .collection(FirebaseCollections.users)
              .where('phoneNumber', isEqualTo: signUp.phoneNumber)
              .get();

      if (userSnapshot.docs.isNotEmpty) {
        return DataFailed(
          Exception('Номер уже зарегистрирован'),
          StackTrace.current,
        );
      }
      // Запускаем верификацию номера
      await _auth.verifyPhoneNumber(
        phoneNumber: signUp.phoneNumber,
        timeout: const Duration(seconds: 60),

        // ✅ Автоматическое завершение входа (Android / Instant verification)
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
            final userModel = UserModel(
              uid: _auth.currentUser?.uid ?? '',
              phoneNumber: signUp.phoneNumber,
              name: signUp.name,
              likes: [],
              region: 0,
              district: 0,
              profileImage: '',
              createdAt: Timestamp.now(),
              updatedAt: Timestamp.now(),
            );
            await _firestore
                .collection(FirebaseCollections.users)
                .doc(userModel.uid)
                .set(userModel.toMap());

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
            completer.complete(DataFailed(Exception(e), st));
          }
        },

        // ❌ Ошибка авторизации (например, неверный формат номера)
        verificationFailed: (FirebaseAuthException e) {
          completer.complete(DataFailed(e, StackTrace.current));
        },

        // 📩 Код успешно отправлен — пользователь должен ввести вручную
        codeSent: (String verificationId, int? resendToken) {
          final userModel = UserModel(
            uid: _auth.currentUser?.uid ?? '',
            phoneNumber: signUp.phoneNumber,
            name: signUp.name,
            likes: [],
            region: 0,
            district: 0,
            profileImage: '',
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
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

        // ⌛ Время ожидания истекло (если автоматическая верификация не сработала)
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!completer.isCompleted) {
            completer.complete(
              DataFailed(
                Exception('Тайм-аут автоматической верификации'),
                StackTrace.current,
              ),
            );
          }
        },
      );

      return await completer.future;
    } catch (e, st) {
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
        throw Exception('Phone number must start with +');
      }

      print(
        '🔥 Firebase: querying Firestore with cleaned number: $cleanNumber',
      );
      final userSnapshot =
          await _firestore
              .collection(FirebaseCollections.users)
              .where('phoneNumber', isEqualTo: cleanNumber)
              .get();

      print(
        '🔥 Firebase: query completed, docs found: ${userSnapshot.docs.length}',
      );
      if (userSnapshot.docs.isNotEmpty) {
        print('🔥 Firebase: user exists');
        completer.complete(const DataSuccess(true));
      } else {
        print('🔥 Firebase: user does not exist');
        completer.complete(const DataSuccess(false));
      }
      return await completer.future;
    } catch (e, st) {
      print('🔥 Firebase: error occurred: $e');
      completer.complete(DataFailed(Exception(e), st));
      return await completer.future;
    }
  }

  @override
  Future<DataState<AuthStatusModel>> logIn(PhoneNumberModel phoneNumber) async {
    final completer = Completer<DataState<AuthStatusModel>>();

    try {
      // Проверка: есть ли пользователь в Firestore
      final userSnapshot =
          await _firestore
              .collection(FirebaseCollections.users)
              .where('phoneNumber', isEqualTo: phoneNumber.phoneNumber)
              .get();

      if (userSnapshot.docs.isEmpty) {
        return DataFailed(
          Exception('Номер не зарегистрирован'),
          StackTrace.current,
        );
      }

      final userModel = userSnapshot.docs.first.data() as UserModel;
      // Запускаем верификацию номера
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.phoneNumber,
        timeout: const Duration(seconds: 60),

        // ✅ Автоматическое завершение входа (Android / Instant verification)
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
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
            completer.complete(DataFailed(Exception(e), st));
          }
        },

        // ❌ Ошибка авторизации (например, неверный формат номера)
        verificationFailed: (FirebaseAuthException e) {
          completer.complete(DataFailed(e, StackTrace.current));
        },

        // 📩 Код успешно отправлен — пользователь должен ввести вручную
        codeSent: (String verificationId, int? resendToken) {
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

        // ⌛ Время ожидания истекло (если автоматическая верификация не сработала)
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!completer.isCompleted) {
            completer.complete(
              DataFailed(
                Exception('Тайм-аут автоматической верификации'),
                StackTrace.current,
              ),
            );
          }
        },
      );

      return await completer.future;
    } catch (e, st) {
      return DataFailed(Exception(e), st);
    }
  }

  @override
  Future<DataState<bool>> anonymousLogIn() async {
    final completer = Completer<DataState<bool>>();

    try {
      final userCredential = await _auth.signInAnonymously();
      final userModel = UserModel(
        uid: userCredential.user?.uid ?? '',
        phoneNumber: '',
        name: '',
        likes: [],
        region: 0,
        district: 0,
        profileImage: '',
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(userModel.uid)
          .set(userModel.toMap());
      completer.complete(const DataSuccess(true));
      return await completer.future;
    } catch (e, st) {
      return DataFailed(Exception(e), st);
    }
  }

  @override
  Future<DataState<bool>> signInWithCredential(
    SignInWithCredentialModel signInWithCredential,
  ) async {
    try {
      await _auth.signInWithCredential(
        PhoneAuthProvider.credential(
          verificationId: signInWithCredential.verificationId,
          smsCode: signInWithCredential.smsCode,
        ),
      );
      final userModel = signInWithCredential.user;
      final userSnapshot =
          await _firestore
              .collection(FirebaseCollections.users)
              .where('uid', isEqualTo: userModel.uid)
              .get();
      if (userSnapshot.docs.isEmpty) {
        await _firestore
            .collection(FirebaseCollections.users)
            .doc(userModel.uid)
            .set(userModel.toMap());
      }
      return const DataSuccess(true);
    } catch (e, st) {
      return DataFailed(Exception(e), st);
    }
  }

  @override
  Future<DataState<bool>> logOut() async {
    try {
      await _auth.signOut();
      return const DataSuccess(true);
    } catch (e, st) {
      return DataFailed(Exception(e), st);
    }
  }
}
