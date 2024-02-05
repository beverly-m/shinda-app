import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shinda_app/firebase_options.dart';
import 'package:shinda_app/views/home_view.dart';
import 'package:shinda_app/views/login_view.dart';
import 'package:shinda_app/views/register_view.dart';
import 'package:shinda_app/views/verify_email_view.dart';
import 'dart:developer' as devtools show log;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const InitApp(),
      routes: {
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView(),
        '/home/': (context) => const HomeView(),
      },
    ),
  );
}

class InitApp extends StatelessWidget {
  const InitApp({super.key});

  void refreshUser(User? user) async {
    await user?.reload();
    return;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            User? user = FirebaseAuth.instance.currentUser;
            refreshUser(user);
            user = FirebaseAuth.instance.currentUser;
            devtools.log(user.toString());
            if (user == null) {
              return const LoginView();
            } else if (user.emailVerified) {
              devtools.log('You are a verified user.');
            } else {
              devtools.log('You need to verify your email.');
              return const VerifyEmailView();
            }
            return const HomeView();

          default:
            return const Center(
              child: CircularProgressIndicator(),
            );
        }
      },
    );
  }
}
