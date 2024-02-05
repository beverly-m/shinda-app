import 'dart:developer' as devtools show log;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your email',
              labelText: 'Email',
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Enter your password',
              labelText: 'Password',
            ),
          ),
          TextButton(
            child: const Text('Login'),
            onPressed: () async {
              final email = _email.text.trim();
              final password = _password.text;

              try {
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );

                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home/',
                    (route) => false,
                  );
                }
              } on FirebaseAuthException catch (e) {
                if (e.code == "invalid-credential") {
                  devtools.log("Wrong email or password.");
                } else {
                  devtools.log(e.code);
                }
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("New to Shinda?"),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/register/',
                    (route) => false,
                  );
                },
                child: const Text("Register"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
