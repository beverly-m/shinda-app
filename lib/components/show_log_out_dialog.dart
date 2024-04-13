import 'package:flutter/material.dart';
import 'package:shinda_app/components/buttons.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: const Color.fromRGBO(241, 249, 249, 1),
          title: const Text("Log out"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextAppButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                labelText: "Cancel"),
            FilledAppButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              labelText: "Log out",
            ),
          ],
        );
      }).then((value) => value ?? false);
}
