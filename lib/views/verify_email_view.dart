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
      appBar: AppBar(
        title: const Text("Verify Email"),
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
                "We've sent you a email verification link to your registered email address. Please verify your account to proceed using the application features."),
            const SizedBox(
              height: 16,
            ),
            const Text("Haven't received the email verification link?"),
            TextButton(
              onPressed: () async {
                try {
                  await AuthService.firebase().sendEmailVerification();
                } on NetworkRequestedFailedAuthException {
                  if (context.mounted) {
                    await showErrorDialog(
                      context,
                      "Oops! Failed to send due to network connectivity. Try again.",
                    );
                  }
                } on GenericAuthException {
                  if (context.mounted) {
                    await showErrorDialog(
                      context,
                      "Error occurred. Try again.",
                    );
                  }
                }
              },
              child: const Text("Send Email Verification"),
            ),
            const SizedBox(
              height: 16,
            ),
            const Text("Already verified?"),
            TextButton(
              onPressed: () async {
                try {
                  await AuthService.firebase().logOut();
                  if (context.mounted) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                  }
                } on NetworkRequestedFailedAuthException {
                  if (context.mounted) {
                    await showErrorDialog(
                      context,
                      "Oops! Failed to send due to network connectivity. Try again.",
                    );
                  }
                } on GenericAuthException {
                  if (context.mounted) {
                    await showErrorDialog(
                      context,
                      "Error occurred. Try again.",
                    );
                  }
                }
              },
              child: const Text("Restart"),
            ),
          ],
        ),
      ),
    );
  }
}
