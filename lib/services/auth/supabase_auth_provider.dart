import 'dart:async';
import 'dart:developer' as devtools;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shinda_app/constants/supabase.dart';
import 'package:shinda_app/services/auth/auth_exceptions.dart';
import 'package:shinda_app/services/auth/auth_provider.dart' as auth_provider;
import 'package:shinda_app/services/auth/auth_user.dart' as user;
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase, Session, AuthException;

class SupabaseAuthProvider implements auth_provider.AuthProvider {
  @override
  Future<void> initialize() async {
    await Supabase.initialize(
      url: "https://hdbygttixkijaqnefgij.supabase.co",
      anonKey:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhkYnlndHRpeGtpamFxbmVmZ2lqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDgyODY2MjcsImV4cCI6MjAyMzg2MjYyN30.k30IsfVyU49RJySCVm6Ajuz4OcltTM2ZbbK6RU_ZSm0",
    );
    await Future.delayed(const Duration(seconds: 5));
  }

  @override
  Future<user.AuthUser> createUser({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  }) async {
    try {
      final isEmailExist = await supabase
          .from('users')
          .select('email')
          .eq('email', email)
          .limit(1)
          .maybeSingle();

      if (isEmailExist != null && isEmailExist['email'].toString().isNotEmpty) {
        throw EmailAlreadyInUseAuthException();
      }

      await supabase.auth.signUp(
        email: email,
        password: password,
        data: data,
      );

      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on AuthException catch (e) {
      if (e.statusCode == "422") {
        throw InvalidEmailAuthException();
      } else if (e.statusCode == "429" || e.statusCode == "500") {
        throw GenericAuthException();
      } else {
        devtools.log(e.statusCode ?? "None");
        devtools.log(e.message);
        throw GenericAuthException();
      }
    } on UserNotLoggedInAuthException {
      throw UserNotLoggedInAuthException();
    } on EmailAlreadyInUseAuthException {
      throw EmailAlreadyInUseAuthException();
    } catch (e) {
      devtools.log(e.toString());
      throw GenericAuthException();
    }
  }

  @override
  user.AuthUser? get currentUser {
    
    final currentUser = supabase.auth.currentUser;
    if (currentUser != null) {
      return user.AuthUser.fromSupabase(currentUser);
    } else {
      return null;
    }
  }

  @override
  Session? get currentSession {
    final currentSess = supabase.auth.currentSession;
    if (currentSess != null) {
      return currentSess;
    } else {
      return null;
    }
  }

  @override
  Future<user.AuthUser> logInEmailPassword({
    required email,
    required password,
  }) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = currentUser;

      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on AuthException catch (e) {
      if (e.statusCode == "400") {
        devtools.log(e.message);
        if (e.message == "Email not confirmed") {
          throw UnverifiedUserAuthException();
        }
        throw InvalidCredentialAuthException();
      } else {
        devtools.log(e.statusCode ?? "None");
        devtools.log(e.message);
        throw GenericAuthException();
      }
    } on UserNotLoggedInAuthException {
      throw UserNotLoggedInAuthException();
    } on UnverifiedUserAuthException {
      throw UnverifiedUserAuthException();
    } catch (_) {
      devtools.log(_.toString());
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = supabase.auth.currentUser;

    try {
      if (user != null) {
        await supabase.auth.signOut();
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on AuthException catch (e) {
      devtools.log(e.statusCode ?? "None");
      devtools.log(e.message);
      throw GenericAuthException();
    } on UserNotLoggedInAuthException {
      throw UserNotLoggedInAuthException();
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    try {
      if (user != null) {
        await user.sendEmailVerification();
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "network-request-failed") {
        throw NetworkRequestedFailedAuthException();
      } else {
        throw GenericAuthException();
      }
    } on UserNotLoggedInAuthException {
      throw UserNotLoggedInAuthException();
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> refreshUserCredentials() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.reload();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }
  
}
