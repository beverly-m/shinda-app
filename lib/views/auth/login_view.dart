import 'package:flutter/material.dart';
import 'package:shinda_app/components/textfields.dart';
import 'package:shinda_app/constants/routes.dart';
import 'package:shinda_app/constants/text_syles.dart';
import 'package:shinda_app/services/auth/auth_exceptions.dart';
import 'package:shinda_app/services/auth/auth_service.dart';
import 'package:shinda_app/utilities/show_error_dialog.dart';
import 'package:shinda_app/responsive/responsive_layout.dart';

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
  bool _obscureText = true;

  void _logIn() async {
    final isValid = _formKey.currentState?.validate();

    if (isValid != null && isValid) {
      setState(() {
        _isLoading = true;
      });

      final email = _email.text.trim();
      final password = _password.text;

      _email.clear();
      _password.clear();

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
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil(
            homeRoute,
            (route) => false,
          );
        } else {
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil(
            verifyEmailRoute,
            (route) => false,
          );
        }
      } on UnverifiedUserAuthException {
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          Navigator.of(context).pushNamed(verifyEmailRoute);
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
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          vertical: 24.0,
          horizontal: 16.0,
        ),
        child: Center(
          child: SizedBox(
            width: Responsive.isMobile(context)
                ? MediaQuery.of(context).size.width
                : MediaQuery.of(context).size.width * 0.6,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 48.0),
                  NormalTextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'Enter your email',
                    labelText: 'Email',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24.0),
                  PasswordTextFormField(controller: _password),
                  const SizedBox(height: 48.0),
                  FilledButton(
                    onPressed: _isLoading ? null : _logIn,
                    style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            Color.fromRGBO(0, 121, 107, 1))),
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 24.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "New to Shinda?",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            registerRoute,
                            (route) => false,
                          );
                        },
                        child: const Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromRGBO(0, 121, 107, 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
