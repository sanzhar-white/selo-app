import 'package:selo/core/resources/data_state.dart';
import '../../../../shared/models/user_model.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_interface.dart';

class UserRepositoryImpl extends UserRepository implements UserInterface {
  final UserInterface _userInteface;

  UserRepositoryImpl(this._userInteface);

  @override
  Future<DataState<AuthStatusModel>> signUp(SignUpModel signUp) {
    return _userInteface.signUp(signUp);
  }

  @override
  Future<DataState<bool>> anonymousLogIn() {
    return _userInteface.anonymousLogIn();
  }

  @override
  Future<DataState<bool>> checkUser(PhoneNumberModel phoneNumber) {
    final result = _userInteface.checkUser(phoneNumber as PhoneNumberModel);
    return result;
  }

  @override
  Future<DataState<AuthStatusModel>> logIn(PhoneNumberModel phoneNumber) {
    final result = _userInteface.logIn(phoneNumber as PhoneNumberModel);
    return result;
  }

  @override
  Future<DataState<bool>> signInWithCredential(
    SignInWithCredentialModel signInWithCredential,
  ) {
    return _userInteface.signInWithCredential(
      signInWithCredential as SignInWithCredentialModel,
    );
  }

  @override
  Future<DataState<bool>> logOut() {
    return _userInteface.logOut();
  }
}
