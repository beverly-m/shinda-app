import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shinda_app/firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void refreshUser(User? user) async {
    await user?.reload();
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              User? user = FirebaseAuth.instance.currentUser;
              refreshUser(user);
              user = FirebaseAuth.instance.currentUser;
              print(user);
              if (user?.emailVerified ?? false) {
                print('You are a verified user.');
              } else {
                print('You need to verify your email.');
                return const EmailVerificationView();
              }
              return const Center(
                child: Text('Done'),
              );

            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }
}

class EmailVerificationView extends StatefulWidget {
  const EmailVerificationView({super.key});

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text("Please verify your email address."),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              try {
                await user?.sendEmailVerification();
                print("Sent");
              } on FirebaseAuthException catch (e) {
                if (e.code == "network-request-failed") {
                  print(
                      "Oops! Failed to send due to network connectivity. Try again.");
                } else {
                  print(e.code);
                }
              }
            },
            child: const Text("Send Email Verification"),
          )
        ],
      ),
    );
  }
}
