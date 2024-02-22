import 'package:shinda_app/services/auth/auth_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase show Session;

abstract class AuthProvider {
  Future<void> initialize();

  AuthUser? get currentUser;

  supabase.Session? get currentSession;

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
