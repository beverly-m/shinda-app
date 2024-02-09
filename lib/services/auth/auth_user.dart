import 'package:firebase_auth/firebase_auth.dart' as firebase_auth show User;
import 'package:flutter/material.dart' show immutable;

@immutable
class AuthUser {
  final bool isEmailVerified;

  const AuthUser({required this.isEmailVerified});

  factory AuthUser.fromFirebase(firebase_auth.User user) => AuthUser(
        isEmailVerified: user.emailVerified,
      );
}
