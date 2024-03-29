import 'package:flutter/material.dart';
import 'package:shinda_app/constants/routes.dart';
import 'package:shinda_app/services/auth/auth_exceptions.dart';
import 'package:shinda_app/services/auth/auth_service.dart';
import 'package:shinda_app/utilities/show_error_dialog.dart';
import 'package:shinda_app/responsive/responsive_layout.dart';

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

        if (context.mounted) {
          Navigator.of(context).pushNamed(loginRoute);
        }
      } on EmailAlreadyInUseAuthException {
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          await showErrorDialog(
            context,
            "Email already in use by another account.",
          );
        }
      } on UserNotLoggedInAuthException {
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          Navigator.of(context).pushNamed(loginRoute);
        }
      } on InvalidEmailAuthException {
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          await showErrorDialog(
            context,
            "Invalid email address.",
          );
        }
      } on GenericAuthException {
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
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
                children: [
                  const Text(
                    "Register",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 48.0),
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
                    controller: _fullName,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
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
                      hintText: 'Enter your full name',
                      labelText: 'Full name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name.';
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
                    style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            Color.fromRGBO(0, 121, 107, 1))),
                    onPressed: _isLoading ? null : _signUp,
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2.0,
                            ),
                          )
                        : const Text(
                            'Register',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already on Shinda?",
                        style: TextStyle(fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            loginRoute,
                            (route) => false,
                          );
                        },
                        child: const Text(
                          "Login",
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
