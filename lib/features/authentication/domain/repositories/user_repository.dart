import '../../../../shared/models/user_model.dart';
import 'package:selo/core/resources/data_state.dart';

abstract class UserRepository {
  Future<DataState<AuthStatusModel>> signUp(SignUpModel signUp);

  Future<DataState<bool>> anonymousLogIn();

  Future<DataState<bool>> checkUser(PhoneNumberModel phoneNumber);

  Future<DataState<AuthStatusModel>> logIn(PhoneNumberModel phoneNumber);

  Future<DataState<bool>> signInWithCredential(
    SignInWithCredentialModel signInWithCredential,
  );

  Future<DataState<bool>> logOut();
}
