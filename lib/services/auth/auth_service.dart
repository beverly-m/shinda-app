import 'package:shinda_app/services/auth/auth_provider.dart' as auth_provider;
import 'package:shinda_app/services/auth/auth_user.dart';
import 'package:shinda_app/services/auth/firebase_auth_provider.dart';
import 'package:shinda_app/services/auth/supabase_auth_provider.dart';

class AuthService implements auth_provider.AuthProvider {
  final auth_provider.AuthProvider provider;

  AuthService({required this.provider});

  factory AuthService.firebase() =>
      AuthService(provider: FirebaseAuthProvider());

  factory AuthService.supabase() =>
      AuthService(provider: SupabaseAuthProvider());

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  }) =>
      provider.createUser(
        email: email,
        password: password,
        data: data,
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

  @override
  Future<void> refreshUserCredentials() => provider.refreshUserCredentials();
}
