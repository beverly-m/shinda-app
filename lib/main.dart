import 'package:flutter/material.dart';
import 'package:shinda_app/constants/routes.dart';
import 'package:shinda_app/services/auth/auth_service.dart';
import 'package:shinda_app/views/home_view.dart';
import 'package:shinda_app/views/login_view.dart';
import 'package:shinda_app/views/register_view.dart';
import 'package:shinda_app/views/verify_email_view.dart';

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
      debugShowCheckedModeBanner: false,
    ),
  );
}

class InitApp extends StatelessWidget {
  const InitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.supabase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:

            final session = AuthService.supabase().currentSession;

            if (session == null) {
              return const LoginView();
            } else {
              return const HomeView();
            } 
            
          default:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
        }
      },
    );
  }
}
