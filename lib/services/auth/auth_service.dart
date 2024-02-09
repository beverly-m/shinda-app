import 'package:shinda_app/services/auth/auth_provider.dart' as auth_provider;
import 'package:shinda_app/services/auth/auth_user.dart';

class AuthService implements auth_provider.AuthProvider {
  final auth_provider.AuthProvider provider;

  AuthService({required this.provider});

  @override
  Future<AuthUser> createUser({
    required email,
    required password,
  }) =>
      provider.createUser(
        email: email,
        password: password,
      );

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logInEmailPassword({
    required email,
    required password,
  }) =>
      provider.logInEmailPassword(
        email: email,
        password: password,
      );

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();
}
