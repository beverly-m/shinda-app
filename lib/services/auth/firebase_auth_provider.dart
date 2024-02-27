// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:shinda_app/firebase_options.dart';
// import 'package:shinda_app/services/auth/auth_exceptions.dart';
// import 'package:shinda_app/services/auth/auth_provider.dart' as auth_provider;
// import 'package:shinda_app/services/auth/auth_user.dart';
// import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// class FirebaseAuthProvider implements auth_provider.AuthProvider {
//   @override
//   Future<void> initialize() async {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//   }

//   @override
//   Future<AuthUser> createUser({
//     required String email,
//     required String password,
//     required Map<String, dynamic> data,
//   }) async {
//     try {
//       await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       final user = currentUser;

//       if (user != null) {
//         return user;
//       } else {
//         throw UserNotLoggedInAuthException();
//       }
//     } on FirebaseAuthException catch (e) {
//       if (e.code == "invalid-email") {
//         throw InvalidEmailAuthException();
//       } else if (e.code == "weak-password") {
//         throw WeakPasswordAuthException();
//       } else if (e.code == "email-already-in-use") {
//         throw EmailAlreadyInUseAuthException();
//       } else if (e.code == "network-request-failed") {
//         throw NetworkRequestedFailedAuthException();
//       } else {
//         throw GenericAuthException();
//       }
//     } catch (_) {
//       throw GenericAuthException();
//     }
//   }

//   @override
//   AuthUser? get currentUser {
//     final user = FirebaseAuth.instance.currentUser;

//     if (user != null) {
//       return AuthUser.fromFirebase(user);
//     } else {
//       return null;
//     }
//   }

//   @override
//   Future<AuthUser> logInEmailPassword({
//     required email,
//     required password,
//   }) async {
//     try {
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       final user = currentUser;

//       if (user != null) {
//         return user;
//       } else {
//         throw UserNotLoggedInAuthException();
//       }
//     } on FirebaseAuthException catch (e) {
//       if (e.code == "invalid-credential") {
//         throw InvalidCredentialAuthException();
//       } else if (e.code == "invalid-email") {
//         throw InvalidEmailAuthException();
//       } else if (e.code == "network-request-failed") {
//         throw NetworkRequestedFailedAuthException();
//       } else {
//         throw GenericAuthException();
//       }
//     } catch (_) {
//       throw GenericAuthException();
//     }
//   }

//   @override
//   Future<void> logOut() async {
//     final user = FirebaseAuth.instance.currentUser;
//     try {
//       if (user != null) {
//         await FirebaseAuth.instance.signOut();
//       } else {
//         throw UserNotLoggedInAuthException();
//       }
//     } on FirebaseAuthException catch (e) {
//       if (e.code == "network-request-failed") {
//         throw NetworkRequestedFailedAuthException();
//       } else {
//         throw GenericAuthException();
//       }
//     } on UserNotLoggedInAuthException {
//       throw UserNotLoggedInAuthException();
//     } catch (_) {
//       throw GenericAuthException();
//     }
//   }

//   @override
//   Future<void> sendEmailVerification() async {
//     final user = FirebaseAuth.instance.currentUser;
//     try {
//       if (user != null) {
//         await user.sendEmailVerification();
//       } else {
//         throw UserNotLoggedInAuthException();
//       }
//     } on FirebaseAuthException catch (e) {
//       if (e.code == "network-request-failed") {
//         throw NetworkRequestedFailedAuthException();
//       } else {
//         throw GenericAuthException();
//       }
//     } on UserNotLoggedInAuthException {
//       throw UserNotLoggedInAuthException();
//     } catch (_) {
//       throw GenericAuthException();
//     }
//   }

//   @override
//   Future<void> refreshUserCredentials() async {
//     final User? user = FirebaseAuth.instance.currentUser;

//     if (user != null) {
//       await user.reload();
//     } else {
//       throw UserNotLoggedInAuthException();
//     }
//   }

//   @override
//   // TODO: implement currentSession
//   supabase.Session? get currentSession => throw UnimplementedError();
// }
