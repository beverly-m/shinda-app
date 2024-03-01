import 'package:flutter/material.dart';
import 'package:shinda_app/constants/routes.dart';
import 'package:shinda_app/services/auth/auth_exceptions.dart';
import 'package:shinda_app/services/auth/auth_service.dart';
import 'package:shinda_app/utilities/show_error_dialog.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            const Text(
              "Verify Your Account",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24.0),
            const Icon(
              Icons.emoji_objects_outlined,
              size: 200,
              color: Color.fromRGBO(219, 240, 239, 1),
            ),
            const SizedBox(height: 48.0),
            const Text(
              "We've sent you a verification link to your registered email address or phone number. Please verify your account to proceed using the application features.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 48.0),
            const Text(
              "Already verified?",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 48.0),
            TextButton(
              onPressed: () async {
                try {
                  await AuthService.supabase().logOut();
                  if (context.mounted) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                  }
                } on UserNotLoggedInAuthException {
                  if (context.mounted) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                  }
                } on GenericAuthException {
                  if (context.mounted) {
                    await showErrorDialog(
                      context,
                      "Error occurred. Try again.",
                    );
                  }
                } catch (_) {
                  if (context.mounted) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                  }
                }
              },
              child: const Text("Proceed to Login",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(0, 121, 107, 1),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
