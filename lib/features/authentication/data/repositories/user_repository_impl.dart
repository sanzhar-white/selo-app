import 'package:selo/core/resources/data_state.dart';
import '../models/user_model.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../datasources/user_interface.dart';

class UserRepositoryImpl extends UserRepository implements UserInterface {
  final UserInterface _userInteface;

  UserRepositoryImpl(this._userInteface);

  @override
  Future<DataState<AuthStatusModel>> signUp(SignUpEntity signUp) {
    return _userInteface.signUp(signUp as SignUpModel);
  }

  @override
  Future<DataState<bool>> anonymousLogIn() {
    return _userInteface.anonymousLogIn();
  }

  @override
  Future<DataState<bool>> checkUser(PhoneNumberEntity phoneNumber) {
    print(
      '📚 Repository: checkUser called with number: ${phoneNumber.phoneNumber}',
    );
    final result = _userInteface.checkUser(phoneNumber as PhoneNumberModel);
    print('📚 Repository: returning result');
    return result;
  }

  @override
  Future<DataState<AuthStatusModel>> logIn(PhoneNumberEntity phoneNumber) {
    print(
      '📚 Repository: login called with number: ${phoneNumber.phoneNumber}',
    );
    final result = _userInteface.logIn(phoneNumber as PhoneNumberModel);
    print('📚 Repository: forwarding login result');
    return result;
  }

  @override
  Future<DataState<bool>> signInWithCredential(
    SignInWithCredentialEntity signInWithCredential,
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
