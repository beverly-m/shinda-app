import 'dart:developer' as devtools show log;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
            const Text("Please verify your email address."),
            TextButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                try {
                  await user?.sendEmailVerification();
                } on FirebaseAuthException catch (e) {
                  if (e.code == "network-request-failed") {
                    devtools.log(
                        "Oops! Failed to send due to network connectivity. Try again.");
                  } else {
                    devtools.log(e.code);
                  }
                }
              },
              child: const Text("Send Email Verification"),
            )
          ],
        ),
      ),
    );
  }
}