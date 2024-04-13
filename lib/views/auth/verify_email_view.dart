import 'package:flutter/material.dart';
import 'package:shinda_app/components/buttons.dart' show TextAppButton;
import 'package:shinda_app/constants/routes.dart' show loginRoute;
import 'package:shinda_app/constants/text_syles.dart' show surface3;
import 'package:shinda_app/responsive/responsive_layout.dart' show Responsive;
import 'package:shinda_app/services/auth/auth_exceptions.dart'
    show GenericAuthException, UserNotLoggedInAuthException;
import 'package:shinda_app/services/auth/auth_service.dart' show AuthService;
import 'package:shinda_app/utilities/show_error_dialog.dart'
    show showErrorDialog;

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
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
            child: Column(
              children: [
                const Text(
                  "Verify Your Account",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24.0),
                const Icon(
                  Icons.emoji_objects_outlined,
                  size: 180,
                  color: surface3,
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
                const SizedBox(height: 24.0),
                TextAppButton(
                  onPressed: () async {
                    try {
                      await AuthService.supabase().logOut();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            loginRoute, (route) => false);
                      }
                    } on UserNotLoggedInAuthException {
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            loginRoute, (route) => false);
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
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            loginRoute, (route) => false);
                      }
                    }
                  },
                  labelText: "Proceed to Login",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
