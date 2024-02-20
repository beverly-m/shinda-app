import 'package:flutter/material.dart';
import 'package:shinda_app/constants/routes.dart';
import 'package:shinda_app/services/auth/auth_exceptions.dart';
import 'package:shinda_app/services/auth/auth_service.dart';
import 'package:shinda_app/utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  late final TextEditingController _email;
  late final TextEditingController _password;

  bool _isLoading = false;

  void _logIn() async {
    final isValid = _formKey.currentState?.validate();

    if (isValid != null && isValid) {
      setState(() {
        _isLoading = true;
      });

      final email = _email.text.trim();
      final password = _password.text;
      try {
        await AuthService.supabase().logInEmailPassword(
          email: email,
          password: password,
        );

        final user = AuthService.supabase().currentUser;

        setState(() {
          _isLoading = false;
        });

        if (user?.isEmailVerified ?? false) {
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              homeRoute,
              (route) => false,
            );
          }
        } else {
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              verifyEmailRoute,
              (route) => false,
            );
          }
        }
      } on InvalidCredentialAuthException {
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          await showErrorDialog(
            context,
            "Wrong email or password.",
          );
        }
      } on GenericAuthException {
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          await showErrorDialog(
            context,
            "An error occured. Try again.",
          );
        }
      }
    }

    // try {
    //   await AuthService.firebase().logInEmailPassword(
    //     email: email,
    //     password: password,
    //   );

    //   final user = AuthService.firebase().currentUser;

    //   if (user?.isEmailVerified ?? false) {
    //     if (context.mounted) {
    //       Navigator.of(context).pushNamedAndRemoveUntil(
    //         homeRoute,
    //         (route) => false,
    //       );
    //     }
    //   } else {
    //     if (context.mounted) {
    //       Navigator.of(context).pushNamedAndRemoveUntil(
    //         verifyEmailRoute,
    //         (route) => false,
    //       );
    //     }
    //   }
    // } on InvalidCredentialAuthException {
    //   if (context.mounted) {
    //     await showErrorDialog(
    //       context,
    //       "Wrong email or password.",
    //     );
    //   }
    // } on InvalidEmailAuthException {
    //   if (context.mounted) {
    //     await showErrorDialog(
    //       context,
    //       "Invalid email address.",
    //     );
    //   }
    // } on NetworkRequestedFailedAuthException {
    //   if (context.mounted) {
    //     await showErrorDialog(
    //       context,
    //       "Network error. Make sure you have stable connection and try again.",
    //     );
    //   }
    // } on GenericAuthException {
    //   if (context.mounted) {
    //     await showErrorDialog(
    //       context,
    //       "Authentication error. Try again.",
    //     );
    //   }
    // }
  }

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          vertical: 24.0,
          horizontal: 16.0,
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.always,
          child: Column(
            children: [
              TextFormField(
                controller: _email,
                textInputAction: TextInputAction.next,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColorDark,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 12.0,
                  ),
                  hintText: 'Enter your email',
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              TextFormField(
                controller: _password,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.next,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColorDark,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 12.0,
                  ),
                  hintText: 'Enter your password',
                  labelText: 'Password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password required.';
                  } else if (value.length < 8) {
                    return 'Password length must be more than 8 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 48.0),
              FilledButton(
                onPressed: _isLoading ? null : _logIn,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : const Text('Login'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("New to Shinda?"),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        registerRoute,
                        (route) => false,
                      );
                    },
                    child: const Text("Register"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
