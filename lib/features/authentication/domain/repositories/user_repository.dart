import '../entities/user_entity.dart';
import 'package:selo/core/resources/data_state.dart';

abstract class UserRepository {
  Future<DataState<AuthStatusEntity>> signUp(SignUpEntity signUp);

  Future<DataState<bool>> anonymousLogIn();

  Future<DataState<bool>> checkUser(PhoneNumberEntity phoneNumber);

  Future<DataState<AuthStatusEntity>> logIn(PhoneNumberEntity phoneNumber);

  Future<DataState<bool>> signInWithCredential(
      SignInWithCredentialEntity signInWithCredential);

  Future<DataState<bool>> logOut();
}
