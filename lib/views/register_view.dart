import 'package:flutter/material.dart';
import 'package:shinda_app/constants/routes.dart';
import 'package:shinda_app/services/auth/auth_exceptions.dart';
import 'package:shinda_app/services/auth/auth_service.dart';
import 'package:shinda_app/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        title: const Text("Register"),
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
            child: const Text('Register'),
            onPressed: () async {
              final email = _email.text.trim();
              final password = _password.text;

              try {
                await AuthService.firebase().createUser(
                  email: email,
                  password: password,
                );

                await AuthService.firebase().sendEmailVerification();

                if (context.mounted) {
                  Navigator.of(context).pushNamed(verifyEmailRoute);
                }
              } on InvalidEmailAuthException {
                if (context.mounted) {
                  await showErrorDialog(
                    context,
                    "Invalid email address.",
                  );
                }
              } on WeakPasswordAuthException {
                if (context.mounted) {
                  await showErrorDialog(
                    context,
                    "Password should be at least 6 characters.",
                  );
                }
              } on EmailAlreadyInUseAuthException {
                if (context.mounted) {
                  await showErrorDialog(
                    context,
                    "The email address is already in use.",
                  );
                }
              } on NetworkRequestedFailedAuthException {
                if (context.mounted) {
                  await showErrorDialog(
                    context,
                    "Network error. Make sure you have stable connection and try again.",
                  );
                }
              } on GenericAuthException {
                if (context.mounted) {
                  await showErrorDialog(
                    context,
                    "Failed to register. Try again.",
                  );
                }
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Already on Shinda?"),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (route) => false,
                  );
                },
                child: const Text("Login"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
