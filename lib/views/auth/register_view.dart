import 'package:flutter/material.dart';
import 'package:shinda_app/components/buttons.dart'
    show FilledAppButton, TextAppButton;
import 'package:shinda_app/components/linear_progress_indicator.dart'
    show AppLinearProgressIndicator;
import 'package:shinda_app/components/textfields.dart'
    show NormalTextFormField, PasswordTextFormField;
import 'package:shinda_app/constants/routes.dart' show loginRoute;
import 'package:shinda_app/services/auth/auth_exceptions.dart'
    show
        EmailAlreadyInUseAuthException,
        GenericAuthException,
        InvalidEmailAuthException,
        UserNotLoggedInAuthException;
import 'package:shinda_app/services/auth/auth_service.dart' show AuthService;
import 'package:shinda_app/utilities/show_error_dialog.dart'
    show showErrorDialog;
import 'package:shinda_app/responsive/responsive_layout.dart' show Responsive;

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _fullName;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
    _fullName = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _fullName.dispose();
    super.dispose();
  }

  void _signUp() async {
    final isValid = _formKey.currentState?.validate();

    if (isValid != null && isValid) {
      setState(() {
        _isLoading = true;
      });

      final email = _email.text.trim();
      final password = _password.text;
      final fullName = _fullName.text;

      _email.clear();
      _password.clear();
      _fullName.clear();

      try {
        await AuthService.supabase().createUser(
          email: email,
          password: password,
          data: {
            "full_name": fullName,
          },
        );

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          Navigator.of(context).pushNamed(loginRoute);
        }
      } on EmailAlreadyInUseAuthException {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          await showErrorDialog(
            context,
            "Email already in use by another account.",
          );
        }
      } on UserNotLoggedInAuthException {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          Navigator.of(context).pushNamed(loginRoute);
        }
      } on InvalidEmailAuthException {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          await showErrorDialog(
            context,
            "Invalid email address.",
          );
        }
      } on GenericAuthException {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          await showErrorDialog(
            context,
            "Failed to register. Try again.",
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0.0, scrolledUnderElevation: 0.0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Center(
          child: SizedBox(
            width: Responsive.isMobile(context)
                ? MediaQuery.of(context).size.width
                : MediaQuery.of(context).size.width * 0.6,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (_isLoading)
                    const Center(
                      child: Padding(
                          padding: EdgeInsets.only(bottom: 24.0),
                          child: AppLinearProgressIndicator()),
                    ),
                  const Text(
                    "Register",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 48.0),
                  NormalTextFormField(
                    controller: _email,
                    hintText: 'Enter your email',
                    labelText: 'Email',
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24.0),
                  NormalTextFormField(
                    controller: _fullName,
                    keyboardType: TextInputType.text,
                    hintText: 'Enter your full name',
                    labelText: 'Full name',
                    enableSuggestions: false,
                    autocorrect: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24.0),
                  PasswordTextFormField(controller: _password),
                  const SizedBox(height: 52.0),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: FilledAppButton(
                        onPressed: _signUp, labelText: 'Register'),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already on Shinda?",
                        style: TextStyle(fontSize: 16),
                      ),
                      TextAppButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            loginRoute,
                            (route) => false,
                          );
                        },
                        labelText: "Login",
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
