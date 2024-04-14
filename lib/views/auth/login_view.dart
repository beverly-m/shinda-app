import 'package:flutter/material.dart';
import 'package:shinda_app/components/buttons.dart'
    show FilledAppButton, TextAppButton;
import 'package:shinda_app/components/linear_progress_indicator.dart'
    show AppLinearProgressIndicator;
import 'package:shinda_app/components/textfields.dart'
    show NormalTextFormField, PasswordTextFormField;
import 'package:shinda_app/constants/routes.dart'
    show homeRoute, registerRoute, verifyEmailRoute;
import 'package:shinda_app/services/auth/auth_exceptions.dart'
    show
        GenericAuthException,
        InvalidCredentialAuthException,
        UnverifiedUserAuthException;
import 'package:shinda_app/services/auth/auth_service.dart' show AuthService;
import 'package:shinda_app/utilities/show_error_dialog.dart'
    show showErrorDialog;
import 'package:shinda_app/responsive/responsive_layout.dart' show Responsive;

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
      if (!mounted) return;
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

        if (!mounted) return;
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
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          Navigator.of(context).pushNamed(verifyEmailRoute);
        }
      } on InvalidCredentialAuthException {
        if (!mounted) return;
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
        if (!mounted) return;
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
      appBar: AppBar(elevation: 0.0, scrolledUnderElevation: 0.0),
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
                  if (_isLoading)
                    const Center(
                      child: Padding(
                          padding: EdgeInsets.only(bottom: 24.0),
                          child: AppLinearProgressIndicator()),
                    ),
                  const Text(
                    "Login",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
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
                  const SizedBox(height: 52.0),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child:
                        FilledAppButton(onPressed: _logIn, labelText: 'Login'),
                  ),
                  const SizedBox(height: 24.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "New to Shinda?",
                        style: TextStyle(fontSize: 16),
                      ),
                      TextAppButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            registerRoute,
                            (route) => false,
                          );
                        },
                        labelText: "Register",
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
