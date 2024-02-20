import 'package:shinda_app/services/auth/auth_user.dart';

abstract class AuthProvider {
  Future<void> initialize();

  AuthUser? get currentUser;

  Future<AuthUser> logInEmailPassword({
    required email,
    required password,
  });

  Future<AuthUser> createUser({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  });

  Future<void> logOut();

  Future<void> sendEmailVerification();

  Future<void> refreshUserCredentials();
}
