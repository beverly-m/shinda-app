import 'package:flutter/material.dart';
import 'package:shinda_app/constants/routes.dart';
import 'package:shinda_app/services/auth/auth_service.dart';
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
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        homeRoute: (context) => const HomeView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
      },
    ),
  );
}

class InitApp extends StatelessWidget {
  const InitApp({super.key});

  Future<void> refreshUser() async {
    await AuthService.firebase().refreshUserCredentials();
    return;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            refreshUser();
            final user = AuthService.firebase().currentUser;
            if (user == null) {
              return const LoginView();
            } else if (user.isEmailVerified) {
              devtools.log('You are a verified user.');
              return const HomeView();
            } else {
              devtools.log('You need to verify your email.');
              return const VerifyEmailView();
            }
          default:
            return const Center(
              child: CircularProgressIndicator(),
            );
        }
      },
    );
  }
}
