import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shinda_app/views/auth/login_view.dart';
import 'package:shinda_app/views/auth/register_view.dart';
import 'package:shinda_app/views/auth/verify_email_view.dart';

void main() {
  group("Widget Testing", () {
    testWidgets("Verify that two input fields are in the login page",
        (widgetTester) async {
      await widgetTester.pumpWidget(const MaterialApp(
        home: LoginView(),
      ));

      final textfieldFinder = find.byType(TextFormField);

      expect(textfieldFinder, findsNWidgets(2));
    });

    testWidgets(
        "Verify that the login page has login button of type filled and register button of type text",
        (widgetTester) async {
      await widgetTester.pumpWidget(const MaterialApp(
        home: LoginView(),
      ));

      final loginButtonFinder = find.byType(FilledButton);
      final registerButtonFinder = find.byType(TextButton);

      expect(loginButtonFinder, findsOneWidget);
      expect(registerButtonFinder, findsOneWidget);
    });

    testWidgets("Verify that three input fields are in the register page",
        (widgetTester) async {
      await widgetTester.pumpWidget(const MaterialApp(
        home: RegisterView(),
      ));

      final textfieldFinder = find.byType(TextFormField);

      expect(textfieldFinder, findsNWidgets(3));
    });

    testWidgets(
        "Verify that the register page has login button of type text and register button of type filled",
        (widgetTester) async {
      await widgetTester.pumpWidget(const MaterialApp(
        home: RegisterView(),
      ));

      final loginButtonFinder = find.byType(TextButton);
      final registerButtonFinder = find.byType(FilledButton);

      expect(loginButtonFinder, findsOneWidget);
      expect(registerButtonFinder, findsOneWidget);
    });

    testWidgets("Verify that the verification page has a text button to log in",
        (widgetTester) async {
      await widgetTester.pumpWidget(const MaterialApp(
        home: VerifyEmailView(),
      ));

      final loginButtonFinder = find.byType(TextButton);
      expect(loginButtonFinder, findsOneWidget);
    });
  });
}