// import 'package:firebase_auth/firebase_auth.dart' as firebase_auth show User;
import 'package:flutter/material.dart' show immutable;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase show User;

@immutable
class AuthUser {
  final bool isEmailVerified;
  final String id;

  const AuthUser({required this.id, required this.isEmailVerified,});

  // factory AuthUser.fromFirebase(firebase_auth.User user) => AuthUser(
  //       isEmailVerified: user.emailVerified,
  //     );

  factory AuthUser.fromSupabase(supabase.User user) => AuthUser(
        isEmailVerified: user.emailConfirmedAt != null,
        id: user.id,
      );
}
