import 'package:selo/core/resources/data_state.dart';

import '../../../../shared/models/user_model.dart';

abstract class UserInterface {
  Future<DataState<AuthStatusModel>> signUp(SignUpModel signUp);

  Future<DataState<bool>> anonymousLogIn();

  Future<DataState<bool>> checkUser(PhoneNumberModel phoneNumber);

  Future<DataState<AuthStatusModel>> logIn(PhoneNumberModel phoneNumber);

  Future<DataState<bool>> signInWithCredential(
    SignInWithCredentialModel signInWithCredential,
  );

  Future<DataState<bool>> logOut();
}
